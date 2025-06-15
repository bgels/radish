import processing.sound.*;

AudioIn  in;               // mic fix
MainMenu mainMenu;
Play     play;
SoundFile MenuSong;
SoundFile endMusic;


enum gameState { MENU, PLAYING, END }
gameState currentState = gameState.MENU;
EndScreen endScreen;

float musicVol = 0.80;   // 0–1
float sfxVol   = 0.80;   // 0–1


// ------------------------------------------------------------
void setup() {
  fullScreen(P3D);
  in = new AudioIn(this, 0);
  in.stop();

  mainMenu = new MainMenu("ost");
  MenuSong = new SoundFile(this, "menu.wav");
  MenuSong.play();
  MenuSong.amp(musicVol);

  endMusic = new SoundFile(this, "hit/end.wav");

}

// ------------------------------------------------------------
void draw() {
  switch (currentState) {
    case MENU:
      mainMenu.update();
      // display volumes
      fill(255); textSize(18);
      text("Music [1/2]: " + nf(musicVol,1,2) +
           "   SFX [3]/[4]: " + nf(sfxVol,1,2),
           500, height-50);
      break;
    
    case PLAYING:
      MenuSong.stop();
      if (play != null) {
        play.update();
        if (play.isFinished()) {
          // stop song + any SFX managed by Play
          play.stopSong();
          // play end-screen music
          endMusic.play();
          endMusic.amp(musicVol);

          endScreen = new EndScreen(play);
          currentState = gameState.END;
        }
      }
    break;
    case END:
      endScreen.draw();
      break;
  }
}

// ------------------------------------------------------------
void mousePressed() {
  if (currentState == gameState.END) {
    if (endScreen.onButton()) {
      endMusic.stop();   //stop the end‐screen track here
      currentState = gameState.MENU;
      MenuSong.play();
      MenuSong.amp(musicVol);
    }
    return;
  }

  if (currentState == gameState.MENU) {
    mainMenu.mousePressed();
    if (mainMenu.isSongSelected()) {
      SongEntry entry = mainMenu.getSelectedEntry();
      play = new Play(this, entry, musicVol, sfxVol);
      currentState = gameState.PLAYING;
    }
    return;
  }

}


// ------------------------------------------------------------
void keyPressed() {
  // MENU: adjust volumes
  if (currentState == gameState.MENU) {
    switch (key) {
      case '1': case '+': musicVol = constrain(musicVol+0.05, 0,1); MenuSong.amp(musicVol); break;
      case '2': case '-': musicVol = constrain(musicVol-0.05, 0,1); MenuSong.amp(musicVol); break;
      case '3': case ']': sfxVol   = constrain(sfxVol+0.05,   0,1); break;
      case '4': case '[': sfxVol   = constrain(sfxVol-0.05,   0,1); break;
    }
    return;
  }

  // only process shield & special during PLAYING 
  if (currentState != gameState.PLAYING) return;

  // shield hotkeys
  int lane = -1;
  switch (key) {
    case 'a': lane = 0; break;  // LEFT
    case 'x': lane = 1; break;  // BOTTOM
    case 'w': lane = 2; break;  // TOP
    case 'd': lane = 3; break;  // RIGHT
    case 'q': lane = 4; break;  // TOP-LEFT
    case 'z': lane = 5; break;  // BOTTOM-LEFT
    case 'e': lane = 6; break;  // TOP-RIGHT
    case 'c': lane = 7; break;  // BOTTOM-RIGHT
  }
  if (lane != -1) {
    play.moveShieldTo(lane);
    return;
  }

  // space for special
  if (key == ' ' || key == 's') {
    play.trySpecialHit();
  }
}
