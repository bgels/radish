import processing.sound.*;
import processing.data.JSONObject;
import processing.core.PApplet;
import java.io.File;
import java.util.ArrayList;

// Play handles gameplay: background, audio, JSON config, and note timings
class Play {
  // --- The selected song entry from MainMenu
  SongEntry           entry;
  SoundFile           song;
  BeatClock beat;
  

  // --- Background
  PGraphics pg;
  BackgroundAnimator  bgAnim;

  // --- LANE UI elements
  LaneUI[] laneUI = new LaneUI[LANES];
  SpecialUI specialUI = new SpecialUI();

  

  // --- Level config data (colors, shapes, etc.)
  JSONObject          config;

  // --- Note timing data (from .sm file)
  File                smFile;
  ArrayList<Float>    noteTimings = new ArrayList<Float>();

  ArrayList<NoteEvent> chart;
  ArrayList<Note>      live = new ArrayList<>();



  PApplet             parent;

  Play(PApplet parent, SongEntry entry) {
    this.parent = parent;
    this.entry  = entry;
  
    // ---------- JSON
    config = parent.loadJSONObject(entry.jsonFile.getAbsolutePath());
    if (config == null) {
      println("ERROR | bad JSON:", entry.jsonFile);
      config = new JSONObject();
    }
     
    // ---------- SONG
    try {
      float bpmVal    = config.hasKey("bpm")    ? config.getFloat("bpm")    : 120;
      float offsetSec = config.hasKey("offset") ? config.getFloat("offset") : 0;
      
      song = new SoundFile(parent, entry.audioFile.getAbsolutePath());
      
      // POSITIVE offset → visuals lead audio → jump into the track
      if (offsetSec > 0) {
        int cueSample = int(offsetSec * song.sampleRate());
        song.cue(cueSample);
        song.play();
      
      // NEGATIVE offset → audio leads visuals → delay the play()
      } else if (offsetSec < 0) {
        int delayMs = int(-offsetSec * 1000);
        new java.util.Timer().schedule(
          new java.util.TimerTask() {
            public void run() { song.play(); }
          }, delayMs
        );
      
      // zero offset → play immediately
      } else {
        song.play();
      }
      
      beat = new BeatClock(bpmVal, song);
    } catch (Exception e) {
      println("ERROR | can't load audio:", entry.audioFile, e);
      song = null;
    }
  
    bgAnim = new BackgroundAnimator(beat, entry.folderName);
    pg     = parent.createGraphics(parent.width, parent.height, P3D);
  
    if (config.hasKey("songName")) {
      bgAnim.setSongName(config.getString("songName"));
    }

    bgAnim.applyConfig(config); // apply background and shapes config
    for(int i=0;i<LANES;i++) laneUI[i]=new LaneUI(i); // Initialize lane UI
    chart = parseSM(smFile, beat.getBPM()); // Parse the .sm file

  
    smFile = entry.smFile;
  }


  void update(){
    float songSec = song.position();
    beat.tick();
    bgAnim.update();

    // --- spawn
    float beatLen = 60.0/beat.getBPM();
    while(chart.size()>0 && songSec + LEAD_SEC >= chart.get(0).beat*beatLen){
      live.add(new Note(chart.remove(0), beatLen));
    }

    // --- draw notes
    for(int i=live.size()-1;i>=0;i--){
      live.get(i).updateAndDraw(songSec);
      if(live.get(i).missed||live.get(i).hit) live.remove(i);
    }

    // --- UI overlays
    for(LaneUI ui : laneUI) ui.draw();
    specialUI.draw();
  }

}
