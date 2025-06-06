  // ───────────────────────────────────────────────────────────────
// SMReader.pde – single-BPM StepMania chart reader
// ───────────────────────────────────────────────────────────────
class SMChart {
  float offsetSec = 0;
  float bpm       = 120;                 // fallback
  ArrayList<NoteEvent> events = new ArrayList<NoteEvent>();
}

SMChart readSM(File sm) {

  SMChart chart = new SMChart();
  String[] lines = loadStrings(sm);

/* ── 1. HEADER ──────────────────────────────────────────────── */
  for (String raw : lines) {
    String s = trim(raw);

    if (s.startsWith("#OFFSET:")) {
      try { chart.offsetSec = float(s.substring(8, s.length()-1)); }
      catch(Exception ignore) {}
    }
    else if (s.startsWith("#BPMS:")) {
      // take first “=<value>” only
      try {
        String val = s.substring(s.indexOf('=')+1, s.length()-1);
        chart.bpm  = float(val);
      } catch(Exception ignore) {}
    }

    if (s.startsWith("#NOTES:")) break;   // done with header
  }

/* ── 2. BODY  (one measure = rows until next comma) ─────────── */
  boolean            inChart      = false;
  int                measureStart = 0;          // beat index (0,4,8,…)
  ArrayList<String>  measureRows  = new ArrayList<String>();

  for (String raw : lines) {
    String s = trim(raw);

    if (s.startsWith("#NOTES:")) { inChart = true; continue; }
    if (!inChart)                 continue;
    if (s.equals(";"))            break;         // end of chart

    /* accumulate rows of the current measure */
    if (!s.equals(",")) {
      if (s.length()==8) measureRows.add(s);     // only note rows
      continue;
    }

    /* ----- we have hit a comma → process one full measure ----- */
    int rows = measureRows.size();               // e.g. 4,8,12,16 …

    if (rows == 0) {                             // totally empty measure
      measureStart += 4;                         // skip 4 beats
      continue;
    }

    for (int r = 0; r < rows; r++) {
      String row  = measureRows.get(r);
      float  beat = measureStart + 4f * r / rows;

      if (row.equals("11111111")) {
        // special “wave” – ONE event, lane = -1
        chart.events.add(new NoteEvent(-1, beat, true));
      } else {
        // ordinary slice rows
        for (int lane = 0; lane < 8; lane++) {
          if (row.charAt(lane) == '1') {
            chart.events.add(new NoteEvent(lane, beat, false));
          }
        }
      }
    }

    measureRows.clear();
    measureStart += 4;                           // next measure
  }

  chart.events.sort((a,b)->Float.compare(a.beat, b.beat));
  return chart;
}
