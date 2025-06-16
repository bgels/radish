// SMReader.pde

import java.io.File;
import java.util.ArrayList;

class SMChart {
  float offsetSec = 0;
  float bpm       = 120;                // fallback
  String difficulty = "Unknown";        // ← new field
  ArrayList<NoteEvent> events = new ArrayList<NoteEvent>();
}

SMChart readSM(File sm) {
  SMChart chart = new SMChart();
  String[] lines = loadStrings(sm);

  // —— parse header (OFFSET, BPMS, then NOTES:) ——
  for (int i = 0; i < lines.length; i++) {
    String s = trim(lines[i]);
    if (s.startsWith("#OFFSET:")) {
      try {
        chart.offsetSec = float(s.substring(8, s.length() - 1));
        println("SMReader | offset:", chart.offsetSec, "s");
      } catch (Exception ignore) {}
    }
    else if (s.startsWith("#BPMS:")) {
      try {
        String val = s.substring(s.indexOf('=') + 1, s.length() - 1);
        println("SMReader | bpm:", val);
        chart.bpm = float(val);
      } catch (Exception ignore) {}
    }
    else if (s.startsWith("#NOTES:")) {
      // the SM format lists five colon-terminated lines after #NOTES:
      //   1) chart type, 2) description, 3) difficulty, 4) meter, 5) radar values
      int diffLineIndex = i + 3;
      if (diffLineIndex < lines.length) {
        String diffLine = trim(lines[diffLineIndex]);
        if (diffLine.endsWith(":")) {
          chart.difficulty = diffLine.substring(0, diffLine.length() - 1);
          println("SMReader | difficulty:", chart.difficulty);
        }
      }
      break;  // done with header
    }
  }

  // —— now parse the note‐data chart exactly as before —— 
  boolean inChart = false;
  int measureStart = 0;
  ArrayList<String> measureRows = new ArrayList<String>();

  for (String raw : lines) {
    String s = trim(raw);

    if (s.startsWith("#NOTES:")) { inChart = true; continue; }
    if (!inChart)                 continue;
    if (s.equals(";"))            break;  // end of chart

    if (!s.equals(",")) {
      if (s.length() == 8) measureRows.add(s);
      continue;
    }

    int rows = measureRows.size();
    if (rows == 0) {
      measureStart += 4;
      continue;
    }

    for (int r = 0; r < rows; r++) {
      String row = measureRows.get(r);
      float beat = measureStart + 4f * r / rows;
      if (row.equals("11111111")) {
        chart.events.add(new NoteEvent(-1, beat, true));
      } else {
        for (int lane = 0; lane < 8; lane++) {
          if (row.charAt(lane) == '1') {
            chart.events.add(new NoteEvent(lane, beat, false));
          }
        }
      }
    }

    measureRows.clear();
    measureStart += 4;
  }

  chart.events.sort((a,b) -> Float.compare(a.beat, b.beat));
  return chart;
}
