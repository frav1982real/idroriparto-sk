import '../models/models.dart';
import '../utils/ids.dart';

/// Motore di ripartizione delle spese idriche condominiali.
///
/// Metodi:
/// - millesimi / consumo / teste: l'importo complessivo è un unico paniere
/// - misto: quota fissa, consumi individuali, parti comuni/perdite, IVA e altro
/// - contatori: consumi individuali a m³, differenza fatturato − contatori
///   (perdite e parti comuni) a millesimi, quota fissa a parti uguali
///
/// Gli importi vengono arrotondati al centesimo. L'eventuale resto
/// (positivo o negativo) viene attribuito all'unità con la quota più alta,
/// così la somma delle righe coincide sempre con la bolletta.
class RipartoEngine {
  static RisultatoRiparto calcola({
    required Bolletta bolletta,
    required List<UnitaImmobiliare> unita,
    Map<String, double>? consumiOverride,
    String? id,
    DateTime? ora,
  }) {
    final elenco = [...unita]..sort((a, b) {
      final o = a.ordine.compareTo(b.ordine);
      if (o != 0) return o;
      return a.interno.compareTo(b.interno);
    });

    final avvisi = <String>[];
    if (elenco.isEmpty) {
      return _vuoto(bolletta, avvisi..add('Nessuna unità immobiliare.'), id, ora);
    }

    final consumi = <String, double>{};
    for (final u in elenco) {
      final raw = consumiOverride?[u.id] ?? bolletta.consumi[u.id] ?? 0;
      if (raw < 0) {
        avvisi.add('Interno ${u.interno}: consumo negativo portato a zero.');
      }
      consumi[u.id] = raw < 0 ? 0 : raw;
    }

    // Nel metodo "contatori" i criteri sono fissi per costruzione:
    // quota fissa a parti uguali, differenza (perdite e parti comuni) a millesimi.
    final critFissa = bolletta.metodo == MetodoRiparto.contatori
        ? CriterioQuota.partiUguali
        : bolletta.criterioFissa;
    final critComune = bolletta.metodo == MetodoRiparto.contatori
        ? CriterioQuota.millesimi
        : bolletta.criterioComune;

    final sommaConsumi = consumi.values.fold<double>(0, (a, b) => a + b);
    final mcFatt = bolletta.mcFatturati > 0
        ? bolletta.mcFatturati
        : bolletta.mcGenerale;
    final mcRif = mcFatt > 0 ? mcFatt : sommaConsumi;
    var consumoComune = mcRif - sommaConsumi;
    if (consumoComune < -0.0005) {
      avvisi.add(
        'La somma dei sottocontatori (${_n(sommaConsumi)} m³) supera i m³ di riferimento (${_n(mcRif)}). '
        'La differenza viene azzerata: verifica le letture.',
      );
      consumoComune = 0;
    } else if (consumoComune < 0) {
      consumoComune = 0;
    }

    if (mcRif > 0 && consumoComune / mcRif > 0.20) {
      avvisi.add(
        'Parti comuni e perdite: ${_n(consumoComune)} m³ '
        '(${(consumoComune / mcRif * 100).toStringAsFixed(1)} % del fatturato). '
        'Controlla letture mancanti o perdite in rete.',
      );
    }

    final senzaContatore = elenco.where((u) => !u.haContatore).toList();
    if (senzaContatore.isNotEmpty &&
        (bolletta.metodo == MetodoRiparto.consumo ||
            bolletta.metodo == MetodoRiparto.misto ||
            bolletta.metodo == MetodoRiparto.contatori)) {
      avvisi.add(
        '${senzaContatore.length} unità senza contatore: il consumo risulta 0. '
        'Nel metodo misto e contatori pagano comunque la quota fissa e le parti comuni.',
      );
    }

    final zeroConsumo = elenco
        .where((u) => (consumi[u.id] ?? 0) == 0)
        .toList();
    if (bolletta.metodo == MetodoRiparto.consumo && zeroConsumo.isNotEmpty) {
      avvisi.add(
        '${zeroConsumo.length} unità con consumo 0 non partecipano al riparto a solo consumo.',
      );
    }
    if (bolletta.metodo == MetodoRiparto.contatori && zeroConsumo.isNotEmpty) {
      avvisi.add(
        '${zeroConsumo.length} unità con consumo 0: pagano solo la quota fissa e le parti comuni.',
      );
    }

    final millSum = elenco.fold<double>(0, (a, u) => a + u.millesimi);
    if ((millSum - 1000).abs() > 0.05 &&
        (bolletta.metodo == MetodoRiparto.millesimi ||
            bolletta.metodo == MetodoRiparto.contatori ||
            critFissa == CriterioQuota.millesimi ||
            critComune == CriterioQuota.millesimi)) {
      avvisi.add(
        'I millesimi sommano ${millSum.toStringAsFixed(2)} invece di 1.000. '
        'Il riparto usa la somma effettiva.',
      );
    }

    final occupantiSum = elenco.fold<int>(0, (a, u) => a + (u.sfitto ? 0 : u.occupanti));
    if (occupantiSum == 0 &&
        (bolletta.metodo == MetodoRiparto.teste ||
            critFissa == CriterioQuota.teste)) {
      avvisi.add(
        'Nessun occupante dichiarato: il criterio per teste cade sulle parti uguali.',
      );
    }

    if (bolletta.totale <= 0) {
      avvisi.add('L’importo della bolletta è zero.');
    }

    final n = elenco.length;
    final fissa = List<double>.filled(n, 0);
    final cons = List<double>.filled(n, 0);
    final comune = List<double>.filled(n, 0);
    final extra = List<double>.filled(n, 0);

    String note;
    switch (bolletta.metodo) {
      case MetodoRiparto.millesimi:
        note = 'Intera bolletta ripartita in base ai millesimi di proprietà.';
        _riempi(fissa, _split(bolletta.quotaFissa, _pesi(elenco, CriterioQuota.millesimi)));
        _riempi(cons, _split(bolletta.variabile, _pesi(elenco, CriterioQuota.millesimi)));
        _riempi(extra, _split(bolletta.extra, _pesi(elenco, CriterioQuota.millesimi)));
      case MetodoRiparto.consumo:
        note = 'Intera bolletta ripartita in base ai metri cubi consumati.';
        final p = elenco.map((u) => consumi[u.id] ?? 0).toList();
        if (p.every((x) => x <= 0)) {
          avvisi.add('Nessun consumo: fallback sui millesimi.');
          note =
              'Nessun consumo rilevato: fallback automatico sui millesimi di proprietà.';
          _riempi(fissa, _split(bolletta.quotaFissa, _pesi(elenco, CriterioQuota.millesimi)));
          _riempi(cons, _split(bolletta.variabile, _pesi(elenco, CriterioQuota.millesimi)));
          _riempi(extra, _split(bolletta.extra, _pesi(elenco, CriterioQuota.millesimi)));
        } else {
          _riempi(fissa, _split(bolletta.quotaFissa, p));
          _riempi(cons, _split(bolletta.variabile, p));
          _riempi(extra, _split(bolletta.extra, p));
        }
      case MetodoRiparto.teste:
        note = 'Intera bolletta ripartita in base agli occupanti.';
        _riempi(fissa, _split(bolletta.quotaFissa, _pesi(elenco, CriterioQuota.teste)));
        _riempi(cons, _split(bolletta.variabile, _pesi(elenco, CriterioQuota.teste)));
        _riempi(extra, _split(bolletta.extra, _pesi(elenco, CriterioQuota.teste)));
      case MetodoRiparto.misto:
        note =
            'Quota fissa: ${bolletta.criterioFissa.label.toLowerCase()}. '
            'Consumi individuali: m³. '
            'Parti comuni e perdite: ${bolletta.criterioComune.label.toLowerCase()}. '
            'IVA e altre voci: in proporzione al subtotale.';
        _riempi(fissa, _split(bolletta.quotaFissa, _pesi(elenco, bolletta.criterioFissa)));
        _riempiVariabile(
          variabile: bolletta.variabile,
          extra: bolletta.extra,
          consumoComune: consumoComune,
          pCons: elenco.map((u) => consumi[u.id] ?? 0).toList(),
          pesiComune: _pesi(elenco, bolletta.criterioComune),
          pesiFallback: _pesi(elenco, CriterioQuota.millesimi),
          fissa: fissa,
          cons: cons,
          comune: comune,
          extraOut: extra,
          avvisi: avvisi,
        );
      case MetodoRiparto.contatori:
        note =
            'Quota fissa: parti uguali. '
            'Consumi individuali: m³ al prezzo della bolletta. '
            'Differenza tra consumo effettivo e fatturato (perdite e parti comuni): millesimi. '
            'IVA e altre voci: in proporzione al subtotale.';
        _riempi(
          fissa,
          _split(bolletta.quotaFissa, _pesi(elenco, CriterioQuota.partiUguali)),
        );
        _riempiVariabile(
          variabile: bolletta.variabile,
          extra: bolletta.extra,
          consumoComune: consumoComune,
          pCons: elenco.map((u) => consumi[u.id] ?? 0).toList(),
          pesiComune: _pesi(elenco, CriterioQuota.millesimi),
          pesiFallback: _pesi(elenco, CriterioQuota.millesimi),
          fissa: fissa,
          cons: cons,
          comune: comune,
          extraOut: extra,
          avvisi: avvisi,
        );
    }

    final tot = List<double>.generate(
      n,
      (i) => fissa[i] + cons[i] + comune[i] + extra[i],
    );
    final grand = bolletta.totale;
    final totAdj = allocateRounded(tot, grand);
    // Adatta le componenti di ciascuna riga al totale arrotondato.
    for (var i = 0; i < n; i++) {
      final raw = [fissa[i], cons[i], comune[i], extra[i]];
      final adj = allocateRounded(raw, totAdj[i]);
      fissa[i] = adj[0];
      cons[i] = adj[1];
      comune[i] = adj[2];
      extra[i] = adj[3];
    }

    final totGen = totAdj.fold<double>(0, (a, b) => a + b);
    final righe = <RigaRiparto>[];
    for (var i = 0; i < n; i++) {
      final u = elenco[i];
      final t = fissa[i] + cons[i] + comune[i] + extra[i];
      righe.add(
        RigaRiparto(
          unitaId: u.id,
          interno: u.interno,
          proprietario: u.proprietario,
          millesimi: u.millesimi,
          occupanti: u.sfitto ? 0 : u.occupanti,
          sfitto: u.sfitto,
          consumoMc: consumi[u.id] ?? 0,
          quotaFissa: fissa[i],
          quotaConsumo: cons[i],
          quotaComune: comune[i],
          quotaExtra: extra[i],
          totale: t,
          percentuale: totGen > 0 ? t / totGen * 100 : 0,
        ),
      );
    }

    final prezzoMedio = mcRif > 0 ? bolletta.totale / mcRif : 0.0;

    return RisultatoRiparto(
      id: id ?? newId('rip'),
      bollettaId: bolletta.id,
      calcolatoIl: ora ?? DateTime.now(),
      righe: righe,
      sommaConsumi: sommaConsumi,
      consumoComune: consumoComune,
      mcRiferimento: mcRif,
      prezzoMedioMc: prezzoMedio,
      totaleFisso: fissa.fold(0, (a, b) => a + b),
      totaleConsumo: cons.fold(0, (a, b) => a + b),
      totaleComune: comune.fold(0, (a, b) => a + b),
      totaleExtra: extra.fold(0, (a, b) => a + b),
      totaleGenerale: totGen,
      metodo: bolletta.metodo,
      criterioFissa: critFissa,
      criterioComune: critComune,
      avvisi: avvisi,
      noteCalcolo: note,
    );
  }

  static Map<MetodoRiparto, RisultatoRiparto> confronta({
    required Bolletta bolletta,
    required List<UnitaImmobiliare> unita,
    Map<String, double>? consumiOverride,
  }) {
    final out = <MetodoRiparto, RisultatoRiparto>{};
    for (final m in MetodoRiparto.values) {
      out[m] = calcola(
        bolletta: bolletta.copyWith(metodo: m),
        unita: unita,
        consumiOverride: consumiOverride,
      );
    }
    return out;
  }

  static List<double> _pesi(List<UnitaImmobiliare> unita, CriterioQuota c) {
    switch (c) {
      case CriterioQuota.millesimi:
        return unita.map((u) => u.millesimi).toList();
      case CriterioQuota.partiUguali:
        return List<double>.filled(unita.length, 1);
      case CriterioQuota.teste:
        final t = unita
            .map((u) => (u.sfitto ? 0 : u.occupanti).toDouble())
            .toList();
        if (t.every((x) => x <= 0)) {
          return List<double>.filled(unita.length, 1);
        }
        return t;
    }
  }

  static List<double> _split(double amount, List<double> weights) {
    if (weights.isEmpty) return const [];
    if (amount == 0) return List<double>.filled(weights.length, 0);
    final sumW = weights.fold<double>(0, (a, b) => a + b);
    if (sumW <= 0) {
      return allocateRounded(
        List<double>.filled(weights.length, amount / weights.length),
        amount,
      );
    }
    final raw = weights.map((w) => amount * w / sumW).toList();
    return allocateRounded(raw, amount);
  }

  static void _riempi(List<double> dest, List<double> src) {
    for (var i = 0; i < dest.length && i < src.length; i++) {
      dest[i] = src[i];
    }
  }

  /// Divide la quota variabile tra consumi individuali (a m³) e parti comuni
  /// (perdite e differenze), poi spalma IVA e altre voci sul subtotale di ogni
  /// riga. Usata dai metodi misto e contatori (che differiscono solo per i
  /// criteri fissi di quota fissa e parti comuni).
  static void _riempiVariabile({
    required double variabile,
    required double extra,
    required double consumoComune,
    required List<double> pCons,
    required List<double> pesiComune,
    required List<double> pesiFallback,
    required List<double> fissa,
    required List<double> cons,
    required List<double> comune,
    required List<double> extraOut,
    required List<String> avvisi,
  }) {
    final n = fissa.length;
    if (n == 0) return;
    // Il prezzo al m³ si ricava dai m³ di riferimento (fatturati o da lettura
    // generale); quando i sottocontatori superano il riferimento la differenza
    // è azzerata e il prezzo cade sui soli m³ individuali.
    final mcRif = pCons.fold<double>(0, (a, b) => a + b) + consumoComune;
    final prezzoMc = mcRif > 0 ? variabile / mcRif : 0.0;
    final costoComune = prezzoMc * consumoComune;
    final costoInd = (variabile - costoComune).clamp(0, variabile);
    if (costoInd > 0 && pCons.any((x) => x > 0)) {
      _riempi(cons, _split(costoInd.toDouble(), pCons));
    } else if (variabile > 0 && consumoComune <= 0) {
      avvisi.add(
        'Nessun consumo individuale: la quota variabile è stata trattata come comune.',
      );
      _riempi(comune, _split(variabile, pesiComune));
    }
    if (costoComune > 0) {
      _riempi(comune, _split(costoComune, pesiComune));
    }
    if (extra > 0) {
      final base = List<double>.generate(
        n,
        (i) => fissa[i] + cons[i] + comune[i],
      );
      if (base.every((x) => x <= 0)) {
        _riempi(extraOut, _split(extra, pesiFallback));
      } else {
        _riempi(extraOut, _split(extra, base));
      }
    }
  }

  static RisultatoRiparto _vuoto(
    Bolletta b,
    List<String> avvisi,
    String? id,
    DateTime? ora,
  ) {
    return RisultatoRiparto(
      id: id ?? newId('rip'),
      bollettaId: b.id,
      calcolatoIl: ora ?? DateTime.now(),
      righe: const [],
      sommaConsumi: 0,
      consumoComune: 0,
      mcRiferimento: b.mcFatturati,
      prezzoMedioMc: 0,
      totaleFisso: 0,
      totaleConsumo: 0,
      totaleComune: 0,
      totaleExtra: 0,
      totaleGenerale: 0,
      metodo: b.metodo,
      criterioFissa: b.metodo == MetodoRiparto.contatori
          ? CriterioQuota.partiUguali
          : b.criterioFissa,
      criterioComune: b.metodo == MetodoRiparto.contatori
          ? CriterioQuota.millesimi
          : b.criterioComune,
      avvisi: avvisi,
    );
  }

  static String _n(double v) {
    if ((v - v.round()).abs() < 0.0005) return v.round().toString();
    return v.toStringAsFixed(3).replaceAll('.', ',');
  }
}

/// Arrotonda una lista di importi al centesimo facendo coincidere
/// la somma con [target] (resto al valore più alto).
List<double> allocateRounded(List<double> parts, double target) {
  if (parts.isEmpty) return const [];
  final cents = parts.map((p) => (p * 100).round()).toList();
  final targetCents = (target * 100).round();
  var sum = cents.fold<int>(0, (a, b) => a + b);
  var drift = targetCents - sum;
  if (drift != 0) {
    var idx = 0;
    for (var i = 1; i < parts.length; i++) {
      if (parts[i] > parts[idx]) idx = i;
    }
    cents[idx] += drift;
  }
  return cents.map((c) => c / 100.0).toList();
}
