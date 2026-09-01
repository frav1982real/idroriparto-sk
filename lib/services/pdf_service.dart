import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/models.dart';
import '../utils/format.dart';

/// Porting dei token e delle superfici di sk-ui (variante light) nel motore
/// PDF: gradienti, bordi, raggi, pill e well. La libreria `pdf` non supporta
/// ombre portate, riflessi e texture SVG: la profondità è resa con gradienti
/// verticali e bordi tinteggiati, come nello stile sk-ui su carta.
class _Sk {
  _Sk._();

  // Inchiostri
  static const ink = PdfColor.fromHex('1A1A1A');
  static const ink2 = PdfColor.fromHex('4A4A4A');
  static const ink3 = PdfColor.fromHex('6A7383');

  // Superficie di base (skill)
  static const bgTop = PdfColor.fromHex('F8FAFC');
  static const bgMid = PdfColor.fromHex('E9EEF5');
  static const bgBottom = PdfColor.fromHex('CFD7E4');

  // Superfici rilevate (raised)
  static const raisedHi = PdfColor.fromHex('FDFEFE');
  static const raisedMid = PdfColor.fromHex('EEF2F7');
  static const raisedLo = PdfColor.fromHex('DDE4EE');

  // Pozzo (well)
  static const wellTop = PdfColor.fromHex('C4CDD9');
  static const wellMid = PdfColor.fromHex('DBE2EA');
  static const wellLo = PdfColor.fromHex('E7ECF2');

  // Bordi e fili
  static const edge = PdfColor.fromHex('4F5D7A');
  static const highlight = PdfColor.fromHex('FFFFFF');

  // Accent — hsl(220, 80%, 51%)
  static const accent = PdfColor.fromHex('2264E2');
  static const accentHi = PdfColor.fromHex('5B8DFF');
  static const accentLo = PdfColor.fromHex('1C4FB8');
  static const accentInk = PdfColor.fromHex('0F3EA6');

  // Semantiche
  static const success = PdfColor.fromHex('23875A');
  static const warn = PdfColor.fromHex('C07C1D');
  static const warnInk = PdfColor.fromHex('7A4E10');
  static const danger = PdfColor.fromHex('C84343');

  // Raggi — base 8px
  static const rSm = 8.0;
  static const rMd = 12.0;
  static const rLg = 18.0;
  static const rPill = 999.0;

  /// `.sk-surface` — gradiente skill con bordo edge.
  static pw.BoxDecoration surface({double radius = rLg, PdfColor? bordo}) {
    return pw.BoxDecoration(
      gradient: pw.LinearGradient(
        colors: [bgTop, bgMid, bgBottom],
        begin: pw.Alignment.topCenter,
        end: pw.Alignment.bottomCenter,
      ),
      borderRadius: pw.BorderRadius.circular(radius),
      border: pw.Border.all(
        color: (bordo ?? edge).withOpacity(0.4),
        width: 0.8,
      ),
    );
  }

  /// `.sk-well` — pozzo incassato (campi, vassoi, totali).
  static pw.BoxDecoration well({double radius = rMd}) {
    return pw.BoxDecoration(
      gradient: pw.LinearGradient(
        colors: [wellTop, wellMid, wellLo],
        begin: pw.Alignment.topCenter,
        end: pw.Alignment.bottomCenter,
      ),
      borderRadius: pw.BorderRadius.circular(radius),
      border: pw.Border.all(
        color: edge.withOpacity(0.35),
        width: 0.8,
      ),
    );
  }

  /// Testata tabella — `.sk-table thead` (nav raised).
  static pw.BoxDecoration thead() {
    return pw.BoxDecoration(
      gradient: pw.LinearGradient(
        colors: [raisedHi, raisedMid, raisedLo],
        begin: pw.Alignment.topCenter,
        end: pw.Alignment.bottomCenter,
      ),
      border: pw.Border(
        bottom: pw.BorderSide(color: edge.withOpacity(0.5), width: 0.8),
      ),
    );
  }

  /// `.sk-badge` — pastiglia in rilievo tinta.
  static pw.Widget badge(
    pw.TextStyle Function(double, {bool b, PdfColor? c}) st,
    String label, {
    PdfColor? tinta,
    PdfColor? testo,
  }) {
    final t = tinta ?? accent;
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [raisedHi, raisedMid, raisedLo],
          begin: pw.Alignment.topCenter,
          end: pw.Alignment.bottomCenter,
        ),
        borderRadius: pw.BorderRadius.circular(rPill),
        border: pw.Border.all(color: t.withOpacity(0.55), width: 0.8),
      ),
      child: pw.Text(
        label.toUpperCase(),
        style: st(6.8, c: testo ?? accentInk),
      ),
    );
  }

  /// Linea "cucita": filo accent a tratteggio (evoca lo stitch sk sulla pelle).
  static pw.Widget stitch({PdfColor? filo}) {
    final f = filo ?? accent;
    pw.Widget t() => pw.Container(
      width: 22,
      height: 2,
      decoration: pw.BoxDecoration(
        color: f.withOpacity(0.5),
        borderRadius: pw.BorderRadius.circular(1),
      ),
    );
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [t(), pw.SizedBox(width: 5), t(), pw.SizedBox(width: 5), t()],
    );
  }
}

class PdfService {
  static Future<pw.Font> _regular() async {
    final data = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    return pw.Font.ttf(data);
  }

  static Future<pw.Font> _bold() async {
    final data = await rootBundle.load('assets/fonts/NotoSans-SemiBold.ttf');
    return pw.Font.ttf(data);
  }

  static Future<void> shareRiparto({
    required Condominio condominio,
    required Bolletta bolletta,
    required RisultatoRiparto riparto,
  }) async {
    final bytes = await buildRiparto(
      condominio: condominio,
      bolletta: bolletta,
      riparto: riparto,
    );
    final name =
        'Riparto_acqua_${fileSafe(condominio.nome)}_'
        '${dateShort.format(bolletta.periodoDal)}_'
        '${dateShort.format(bolletta.periodoAl)}.pdf';
    await Printing.sharePdf(bytes: bytes, filename: name);
  }

  static Future<void> printRiparto({
    required Condominio condominio,
    required Bolletta bolletta,
    required RisultatoRiparto riparto,
  }) async {
    await Printing.layoutPdf(
      onLayout: (_) => buildRiparto(
        condominio: condominio,
        bolletta: bolletta,
        riparto: riparto,
      ),
    );
  }

  static Future<Uint8List> buildRiparto({
    required Condominio condominio,
    required Bolletta bolletta,
    required RisultatoRiparto riparto,
  }) async {
    final regular = await _regular();
    final bold = await _bold();

    pw.TextStyle st(double size, {bool b = false, PdfColor? c}) => pw.TextStyle(
      font: b ? bold : regular,
      fontSize: size,
      color: c ?? _Sk.ink,
    );

    final doc = pw.Document(
      title: 'Prospetto riparto acqua — ${condominio.nome}',
      author: 'IdroRiparto',
    );

    final headers = [
      'Int.',
      'Intestatario',
      'Mill.',
      'm³',
      'Fissa',
      'Consumo',
      'Comuni',
      'IVA/altro',
      'Totale',
      '%',
    ];

    final data = riparto.righe
        .map(
          (r) => [
            r.interno,
            r.proprietario,
            mill(r.millesimi),
            mcNum(r.consumoMc),
            euro(r.quotaFissa),
            euro(r.quotaConsumo),
            euro(r.quotaComune),
            euro(r.quotaExtra),
            euro(r.totale),
            pctFormat.format(r.percentuale),
          ],
        )
        .toList();

    data.add([
      '',
      'TOTALE',
      mill(riparto.righe.fold<double>(0, (a, r) => a + r.millesimi)),
      mcNum(riparto.sommaConsumi),
      euro(riparto.totaleFisso),
      euro(riparto.totaleConsumo),
      euro(riparto.totaleComune),
      euro(riparto.totaleExtra),
      euro(riparto.totaleGenerale),
      '100',
    ]);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(26, 24, 26, 30),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Blocco logo sk: barra accent.
                pw.Container(
                  width: 9,
                  height: 40,
                  decoration: pw.BoxDecoration(
                    color: _Sk.accent,
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'IDRORIPARTO · PROSPETTO DI RIPARTIZIONE',
                        style: st(8, c: _Sk.ink3),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Spese idriche condominiali',
                        style: st(16, b: true),
                      ),
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('IdroRiparto', style: st(11, b: true, c: _Sk.accent)),
                    pw.Text(
                      'Generato il ${dateIt.format(riparto.calcolatoIl)}',
                      style: st(8, c: _Sk.ink3),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Container(height: 1, color: _Sk.edge.withOpacity(0.3)),
            pw.SizedBox(height: 3),
            _Sk.stitch(),
            pw.SizedBox(height: 10),
          ],
        ),
        footer: (ctx) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 6),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(color: _Sk.edge.withOpacity(0.3), width: 0.8),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Documento di lavoro interno, non sostituisce la bolletta del gestore.',
                style: st(7.5, c: _Sk.ink3),
              ),
              pw.Text(
                'Pagina ${ctx.pageNumber} di ${ctx.pagesCount}',
                style: st(7.5, c: _Sk.ink3),
              ),
            ],
          ),
        ),
        build: (ctx) => [
          _cardCondominio(st, condominio, bolletta, riparto),
          pw.SizedBox(height: 12),
          _cardSintesi(st, bolletta, riparto),
          pw.SizedBox(height: 12),
          _cardRiparto(st, headers, data, riparto),
          pw.SizedBox(height: 18),
          _tagliandi(st, condominio, bolletta, riparto),
          pw.SizedBox(height: 22),
          _firma(st),
          pw.SizedBox(height: 16),
          pw.Text(
            'Nota giuridica. In presenza di sottocontatori individuali la prassi e la giurisprudenza '
            'privilegiano il criterio del consumo effettivo. In mancanza si applica l’art. 1123 c.c. '
            '(millesimi), salvo diverso regolamento contrattuale o delibera assembleare. '
            'IdroRiparto è uno strumento di calcolo: verificare sempre il regolamento del condominio.',
            style: st(7, c: _Sk.ink3),
          ),
        ],
      ),
    );

    return doc.save();
  }

  // ---------------------------------------------------------------------------
  // Sezioni sk-ui
  // ---------------------------------------------------------------------------

  static pw.Widget _cardCondominio(
    pw.TextStyle Function(double, {bool b, PdfColor? c}) st,
    Condominio condominio,
    Bolletta bolletta,
    RisultatoRiparto riparto,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: _Sk.surface(),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _kv(st, [
                  ('Condominio', condominio.nome),
                  ('Indirizzo', condominio.indirizzoCompleto),
                  ('Amministratore', condominio.amministratore),
                  (
                    'Fornitore',
                    bolletta.fornitore.isEmpty
                        ? condominio.fornitore
                        : bolletta.fornitore,
                  ),
                ]),
              ),
              pw.Expanded(
                child: _kv(st, [
                  ('Periodo', periodLabel(bolletta.periodoDal, bolletta.periodoAl)),
                  ('Documento', bolletta.numero.isEmpty ? '—' : bolletta.numero),
                  ('Imponibile', euro(bolletta.totale)),
                  ('Fatturato', '${mcNum(bolletta.mcFatturati)} m³'),
                ]),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Container(height: 1, color: _Sk.edge.withOpacity(0.25)),
          pw.SizedBox(height: 10),
          pw.Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Sk.badge(st, bolletta.metodo.titolo, tinta: _Sk.accent),
              _Sk.badge(
                st,
                'Fissa: ${riparto.criterioFissa.label}',
                tinta: _Sk.edge,
                testo: _Sk.ink3,
              ),
              _Sk.badge(
                st,
                'Comuni: ${riparto.criterioComune.label}',
                tinta: _Sk.edge,
                testo: _Sk.ink3,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _cardSintesi(
    pw.TextStyle Function(double, {bool b, PdfColor? c}) st,
    Bolletta bolletta,
    RisultatoRiparto riparto,
  ) {
    final voci = <(String, String, String)>[
      ('Quota fissa / canone', euro(bolletta.quotaFissa),
          'Ripartita a ${riparto.criterioFissa.label.toLowerCase()}'),
      ('Acquedotto', euro(bolletta.acquedotto), ''),
      ('Fognatura', euro(bolletta.fognatura), ''),
      ('Depurazione', euro(bolletta.depurazione), ''),
      ('IVA', euro(bolletta.iva), 'Spalmata sul subtotale'),
      ('Altro', euro(bolletta.altro), ''),
    ];

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: _Sk.well(),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Sintesi importi', style: st(10.5, b: true)),
          pw.SizedBox(height: 8),
          pw.Table(
            columnWidths: const {
              0: pw.FlexColumnWidth(2.2),
              1: pw.FlexColumnWidth(1.2),
              2: pw.FlexColumnWidth(2.6),
            },
            children: [
              pw.TableRow(
                decoration: _Sk.thead(),
                children: [
                  _th(st, 'Voce'),
                  _th(st, 'Importo', right: true),
                  _th(st, 'Note'),
                ],
              ),
              for (final v in voci)
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(
                        color: _Sk.edge.withOpacity(0.18),
                        width: 0.4,
                      ),
                    ),
                  ),
                  children: [
                    _td(st, v.$1, bold: true),
                    _td(st, v.$2, right: true),
                    _td(st, v.$3, color: _Sk.ink3),
                  ],
                ),
              pw.TableRow(
                decoration: _Sk.well(radius: 0),
                children: [
                  _td(st, 'TOTALE BOLLETTA', bold: true),
                  _td(st, euro(bolletta.totale), right: true, bold: true),
                  _td(
                    st,
                    '${mcNum(bolletta.mcFatturati)} m³ fatturati',
                    color: _Sk.ink3,
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              pw.Text(
                'Consumi individuali ${mcNum(riparto.sommaConsumi)} m³',
                style: st(8, c: _Sk.ink2),
              ),
              pw.Text(
                'Parti comuni e perdite ${mcNum(riparto.consumoComune)} m³',
                style: st(8, c: _Sk.ink2),
              ),
              pw.Text(
                'Prezzo medio ${euro(riparto.prezzoMedioMc)} / m³',
                style: st(8, c: _Sk.ink2),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text(riparto.noteCalcolo, style: st(8, c: _Sk.ink3)),
          if (riparto.avvisi.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: _Sk.warn.withOpacity(0.08),
                borderRadius: pw.BorderRadius.circular(_Sk.rSm),
                border: pw.Border.all(
                  color: _Sk.warn.withOpacity(0.45),
                  width: 0.8,
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Avvertenze', style: st(8.5, b: true, c: _Sk.warnInk)),
                  pw.SizedBox(height: 3),
                  for (final a in riparto.avvisi)
                    pw.Text('• $a', style: st(7.5, c: _Sk.warnInk)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _cardRiparto(
    pw.TextStyle Function(double, {bool b, PdfColor? c}) st,
    List<String> headers,
    List<List<String>> data,
    RisultatoRiparto riparto,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Riparto per unità immobiliare', style: st(11, b: true)),
        pw.SizedBox(height: 8),
        pw.ClipRRect(
          borderRadius: pw.BorderRadius.circular(_Sk.rSm),
          child: pw.Table(
            columnWidths: const {
              0: pw.FlexColumnWidth(1.0),
              1: pw.FlexColumnWidth(4.4),
              2: pw.FlexColumnWidth(1.7),
              3: pw.FlexColumnWidth(1.6),
              4: pw.FlexColumnWidth(2.0),
              5: pw.FlexColumnWidth(2.0),
              6: pw.FlexColumnWidth(2.0),
              7: pw.FlexColumnWidth(2.1),
              8: pw.FlexColumnWidth(2.2),
              9: pw.FlexColumnWidth(1.3),
            },
            children: [
              pw.TableRow(
                decoration: _Sk.thead(),
                children: [
                  for (var i = 0; i < headers.length; i++)
                    _th(st, headers[i], right: i >= 2),
                ],
              ),
              for (var i = 0; i < data.length; i++)
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: i.isOdd
                        ? _Sk.bgTop
                        : _Sk.highlight.withOpacity(0.9),
                    border: pw.Border(
                      bottom: pw.BorderSide(
                        color: _Sk.edge.withOpacity(0.15),
                        width: 0.4,
                      ),
                    ),
                  ),
                  children: [
                    for (var c = 0; c < data[i].length; c++)
                      _td(
                        st,
                        data[i][c],
                        right: c >= 2,
                        bold: i == data.length - 1,
                        color: i == data.length - 1 ? _Sk.ink : _Sk.ink2,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _tagliandi(
    pw.TextStyle Function(double, {bool b, PdfColor? c}) st,
    Condominio condominio,
    Bolletta bolletta,
    RisultatoRiparto riparto,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Prospetti individuali (da staccare)', style: st(11, b: true)),
        pw.SizedBox(height: 8),
        pw.Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final r in riparto.righe)
              pw.Container(
                width: 248,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [_Sk.raisedHi, _Sk.raisedMid, _Sk.raisedLo],
                    begin: pw.Alignment.topCenter,
                    end: pw.Alignment.bottomCenter,
                  ),
                  borderRadius: pw.BorderRadius.circular(_Sk.rMd),
                  border: pw.Border.all(
                    color: _Sk.accent.withOpacity(0.45),
                    width: 0.8,
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            condominio.nome,
                            maxLines: 1,
                            overflow: pw.TextOverflow.ellipsis,
                            style: st(7.5, b: true),
                          ),
                        ),
                        _Sk.badge(st, 'int. ${r.interno}', tinta: _Sk.accent),
                      ],
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(r.proprietario, style: st(8, c: _Sk.ink2)),
                    pw.Text(
                      'Acqua ${periodLabel(bolletta.periodoDal, bolletta.periodoAl)}',
                      style: st(6.8, c: _Sk.ink3),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Container(height: 1, color: _Sk.edge.withOpacity(0.25)),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Consumo ${mc(r.consumoMc)}', style: st(7)),
                        pw.Text('Mill. ${mill(r.millesimi)}', style: st(7)),
                      ],
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Fissa ${euro(r.quotaFissa)}  ·  Consumo ${euro(r.quotaConsumo)}',
                      style: st(7),
                    ),
                    pw.Text(
                      'Comuni ${euro(r.quotaComune)}  ·  IVA/altro ${euro(r.quotaExtra)}',
                      style: st(7),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Container(
                      padding: const pw.EdgeInsets.only(top: 5),
                      decoration: pw.BoxDecoration(
                        border: pw.Border(
                          top: pw.BorderSide(
                            color: _Sk.edge.withOpacity(0.3),
                            width: 0.6,
                          ),
                        ),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('DOVUTO', style: st(7.5, b: true, c: _Sk.ink3)),
                          pw.Text(
                            euro(r.totale),
                            style: st(9.5, b: true, c: _Sk.accentInk),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _firma(
    pw.TextStyle Function(double, {bool b, PdfColor? c}) st,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 180,
              height: 1,
              decoration: pw.BoxDecoration(color: _Sk.edge.withOpacity(0.5)),
            ),
            pw.SizedBox(height: 4),
            pw.Text('L’amministratore', style: st(8, c: _Sk.ink3)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 180,
              height: 1,
              decoration: pw.BoxDecoration(color: _Sk.edge.withOpacity(0.5)),
            ),
            pw.SizedBox(height: 4),
            pw.Text('Data', style: st(8, c: _Sk.ink3)),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Celle e righe
  // ---------------------------------------------------------------------------

  static pw.Widget _th(
    pw.TextStyle Function(double, {bool b, PdfColor? c}) st,
    String label, {
    bool right = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: pw.Text(
        label,
        textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
        style: st(6.8, b: true),
      ),
    );
  }

  static pw.Widget _td(
    pw.TextStyle Function(double, {bool b, PdfColor? c}) st,
    String label, {
    bool right = false,
    bool bold = false,
    PdfColor? color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3.5),
      child: pw.Text(
        label,
        textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
        style: st(7, b: bold, c: color ?? _Sk.ink2),
      ),
    );
  }

  static pw.Widget _kv(
    pw.TextStyle Function(double, {bool b, PdfColor? c}) st,
    List<(String, String)> rows,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (final r in rows)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(text: '${r.$1}: ', style: st(8, b: true, c: _Sk.ink3)),
                  pw.TextSpan(
                    text: r.$2.isEmpty ? '—' : r.$2,
                    style: st(8),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class CsvService {
  static String ripartoCsv(RisultatoRiparto r) {
    final b = StringBuffer();
    b.writeln(
      'Interno;Proprietario;Millesimi;Occupanti;Sfitto;Consumo_mc;Quota_fissa;Quota_consumo;Quota_comune;IVA_altro;Totale;Percentuale',
    );
    for (final x in r.righe) {
      b.writeln(
        [
          x.interno,
          x.proprietario,
          mill(x.millesimi),
          x.occupanti,
          x.sfitto ? 'sì' : 'no',
          mcNum(x.consumoMc),
          euro(x.quotaFissa),
          euro(x.quotaConsumo),
          euro(x.quotaComune),
          euro(x.quotaExtra),
          euro(x.totale),
          pctFormat.format(x.percentuale),
        ].join(';'),
      );
    }
    return b.toString();
  }
}
