  import processing.sound.*;
  
  AudioIn             in; // Fix mic issue
  MainMenu            mainMenu;
  Play                play;
  SoundFile           MenuSong;
  
  enum gameState {
    MENU,
    PLAYING
  }
  
  gameState currentState = gameState.MENU;
  
  void setup() {
    fullScreen(P3D);
    in = new AudioIn(this, 0);
    in.stop();
    mainMenu = new MainMenu("ost");
    MenuSong = new SoundFile(this, "menu.wav");
    MenuSong.play();
  }
    
  void draw() {
    switch (currentState) {
      case MENU:
        mainMenu.update();
        break;
  
      case PLAYING:
      MenuSong.stop();
        if (play != null) {
          play.update();
        }
          break;
    }
  }

  
  void mousePressed(){          
    if(currentState == gameState.MENU){
      mainMenu.mousePressed();
      if(mainMenu.isSongSelected()){
        SongEntry entry = mainMenu.getSelectedEntry();
        play = new Play(this, entry);
        currentState = gameState.PLAYING;
      }
    }
  }


  void keyPressed() {
    if (currentState != gameState.PLAYING) return;

    int lane = -1;
    switch (key){
      case 'a': lane = 0; break;   // LEFT
      case 'x': lane = 1; break;   // BOTTOM
      case 'w': lane = 2; break;   // TOP
      case 'd': lane = 3; break;   // RIGHT
    
      case 'q': lane = 4; break;   // TOP-LEFT
      case 'z': lane = 5; break;   // BOTTOM-LEFT
      case 'e': lane = 6; break;   // TOP-RIGHT
      case 'c': lane = 7; break;   // BOTTOM-RIGHT
    
      case 's': handleSpecial(); return; 
      case ' ': handleSpecial(); return;   // SPECIAL note
    }


    if (lane != -1) {
      handleHit(lane);
    }
  }


void handleHit(int lane) {
  float songSec = play.song.position() / 1000.0; // Assuming song.position() returns milliseconds
  for (Note n : play.live) {
    if (n.evt.lane == lane && !n.evt.special && !n.hit && !n.missed) {
      float timingError = abs(songSec - n.hitSec);
      if (timingError <= HIT_WINDOW_LATE) {
        n.hit = true;
        play.laneUI[lane].pulse(true); // Visual feedback for hit
        if (timingError <= HIT_WINDOW_PERF) {
          println("Perfect Hit!"); // Replace with scoring logic
        } else if (timingError <= HIT_WINDOW_GOOD) {
          println("Good Hit!");
        } else {
          println("Late Hit!");
        }
      }
      return; // Hit the first eligible note only
    }
  }
  play.laneUI[lane].pulse(false); // Visual feedback for miss
}


void handleSpecial() {
  float songSec = play.song.position() / 1000.0; // Assuming song.position() returns milliseconds
  for (Note n : play.live) {
    if (n.evt.special && n.evt.special && !n.hit && !n.missed) {
      float timingError = abs(songSec - n.hitSec);
      if (timingError <= HIT_WINDOW_LATE) {
        n.hit = true;
        if (timingError <= HIT_WINDOW_PERF) {
          println("Perfect Hit!"); // Replace with scoring logic
        } else if (timingError <= HIT_WINDOW_GOOD) {
          println("Good Hit!");
        } else {
          println("Late Hit!");
        }
      }
      return; // Hit the first eligible note only
    }
  }
}