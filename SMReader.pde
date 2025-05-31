ArrayList<NoteEvent> parseSM(File sm, float bpm){
  ArrayList<NoteEvent> list = new ArrayList<NoteEvent>();
  String[] lines = loadStrings(sm);
  boolean inChart=false;
  float beat=0;
  int linesInCurrentBeat =0;
  int divPerBeat =0;

  for(String raw : lines){
    String s = trim(raw);
    if(s.startsWith("#NOTES:")) { inChart=true; continue; }
    if(!inChart) continue;
    if(s.equals(";")) break;      // end chart

    if(s.equals(",")){            // beat boundary
      beat+=1; linesInCurrentBeat=0; divPerBeat=0;
      continue;
    }
    if(s.length()!=8) continue;   // skip blanks

    // first non-empty line after last comma decides subdivision
    if(divPerBeat==0) divPerBeat = 1;
    else              divPerBeat++;

    boolean special = s.equals("11111111");
    for(int i=0;i<8;i++){
      if(s.charAt(i)=='1'){
        float frac = (float)linesInCurrentBeat/divPerBeat;
        list.add(new NoteEvent(i, beat+frac, special));
      }
    }
    linesInCurrentBeat++;
  }
  // sort by beat just in case
  list.sort((a,b)->Float.compare(a.beat, b.beat));
  return list;
}
