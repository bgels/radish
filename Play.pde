import processing.sound.*;
import processing.data.JSONObject;
import processing.core.PApplet;
import java.io.File;
import java.util.ArrayList;

// Play handles gameplay: background, audio, JSON config, and note timings
class Play {
  // --- The selected song entry from MainMenu
  SongEntry            entry;
  SoundFile            song;
  ArrayList<NoteEvent> chart;
  ArrayList<Note>      live = new ArrayList<>();
  BeatClock            beat;
  
  // --- Note timing data (from .sm file)
  File                smFile;
  PApplet             parent;

  // --- UI and background
  BackgroundAnimator  bgAnim;
  LaneUI[] laneUI = new LaneUI[LANES];
  SpecialUI specialUI = new SpecialUI();
  // --- Level config data (colors, shapes, etc.)
  JSONObject          config;

  Play(PApplet parent, SongEntry entry) {
    this.parent = parent;
    this.entry  = entry;

    // ---------- JSON
    config = parent.loadJSONObject(entry.jsonFile.getAbsolutePath());
    if (config == null) {
      println("ERROR | bad JSON:", entry.jsonFile);
      config = new JSONObject();
    }

    // ---------- SONG + SM parsing
    try {
      SMChart chartData = readSM(entry.smFile);
      float   bpmVal    = chartData.bpm;
      float   offsetSec = chartData.offsetSec;

      song = new SoundFile(parent, entry.audioFile.getAbsolutePath());
      song.play(); // Always start the song from the beginning

      beat  = new BeatClock(bpmVal, offsetSec, song);
      chart = chartData.events;
    } 
    catch (Exception e) {
      println("ERROR | can't load audio:", entry.audioFile, e);
      song  = null;
      chart = new ArrayList<>();
    }


    // ---------- BACKGROUND + UI setup
    bgAnim = new BackgroundAnimator(beat, entry.folderName);

    if (config.hasKey("songName")) {
      bgAnim.setSongName(config.getString("songName"));
    }

    smFile = entry.smFile;

    bgAnim.applyConfig(config);
    for (int i = 0; i < LANES; i++) {
      laneUI[i] = new LaneUI(i);
    }
  }


  void update(){
    float songSec = song.position();
    beat.tick();
    bgAnim.update();

    // --- spawn
    float beatLen = 60.0/beat.getBPM();
    float musicBeat = (songSec - beat.songOffsetSec) / beatLen;
    while (chart.size() > 0 &&
           chart.get(0).beat - musicBeat <= LEAD_SEC / beatLen) {
      live.add(new Note(chart.remove(0), beatLen));
    }


    // --- draw / resolve live notes ------------------------------
    for (int i = live.size () - 1; i >= 0; i--) {
      Note n = live.get(i);
      n.updateAndDraw(songSec);
    
      // ordinary 1/8-slice notes only → lanes 0-7
      if (!n.evt.special && n.evt.lane >= 0) {      //   ← guard!
        if (n.missed)  laneUI[n.evt.lane].pulse(false);
        else if (n.hit) laneUI[n.evt.lane].pulse(true);
      }
    
      if (n.missed || n.hit) live.remove(i);
    }



    // --- UI overlays
    for(LaneUI ui : laneUI) ui.draw();
    specialUI.draw();
  }

  void stopSong(){
    if(song != null && song.isPlaying()) song.stop();
  }


}