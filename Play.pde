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

  // --- Level config data (colors, shapes, etc.)
  JSONObject          config;

  // --- Note timing data (from .sm file)
  File                smFile;
  ArrayList<Float>    noteTimings = new ArrayList<Float>();

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
    pg     = parent.createGraphics(parent.width, parent.height, P3D); // Add this line
  
    if (config.hasKey("songName")) {
      bgAnim.setSongName(config.getString("songName"));
    }
    bgAnim.applyConfig(config);
  
    smFile = entry.smFile;
  }


  void update() {
    beat.tick();
    bgAnim.update();
    // TODO: render note objects based on noteTimings
  }
}
