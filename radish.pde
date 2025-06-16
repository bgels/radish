import processing.sound.*;
import java.util.HashMap;      // for SongMap

AudioIn    in;               // mic fix
MainMenu   mainMenu;
Play       play;
SoundFile  MenuSong;
SoundFile  endMusic;
SongMap    songMap;          // song‐map selector

enum gameState { MENU, SELECT, PLAYING, END }
gameState currentState = gameState.SELECT;  // start in song‐map
EndScreen  endScreen;

float musicVol = 1;   // 0–1
float sfxVol   = 1;   // 0–1

// 
void setup() {
  fullScreen(P3D);
  in = new AudioIn(this, 0);
  in.stop();

  // build song list & selector map
  mainMenu = new MainMenu("ost");             // gathers entries
  songMap = new SongMap(this, mainMenu.entries);  // layout selector
  currentState = gameState.SELECT;

  MenuSong = new SoundFile(this, "menu.wav");
  MenuSong.play();
  MenuSong.amp(musicVol);

  endMusic = new SoundFile(this, "hit/end.wav");
}

// -
void draw() {
  // game states
  switch (currentState) {
    case MENU:
      mainMenu.update();
      fill(255); textSize(18);
      text("Music [1/2]: " + nf(musicVol,1,2)
         + "   SFX [3]/[4]: " + nf(sfxVol,1,2),
         500, height-50);
      break;

    case SELECT:
      songMap.update();
      break;

    case PLAYING:
      MenuSong.stop();
      if (play != null) {
        play.update();
        if (play.isFinished()) {
          play.stopSong();
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

  // pixelation filter
  final int pixelSize = 2;
  loadPixels();
  for (int y = 0; y < height; y += pixelSize) {
    for (int x = 0; x < width;  x += pixelSize) {
      int loc = x + y * width;
      int c   = pixels[loc];
      for (int dy = 0; dy < pixelSize; dy++) {
        for (int dx = 0; dx < pixelSize; dx++) {
          int xx = x + dx;
          int yy = y + dy;
          if (xx < width && yy < height) {
            pixels[xx + yy * width] = c;
          }
        }
      }
    }
  }
  updatePixels();
}


// 
void keyPressed() {
  // SELECT: map navigation & selection
  if (currentState == gameState.SELECT) {
    switch (key) {
      case 'w': songMap.move(0, -1); break;
      case 's': songMap.move(0,  1); break;
      case 'a': songMap.move(-1, 0); break;
      case 'd': songMap.move( 1, 0); break;
      case ' ':  // lock in song
        SongEntry sel = songMap.getSelected();
        if (sel != null) {
          play = new Play(this, sel, musicVol, sfxVol);
          currentState = gameState.PLAYING;
          MenuSong.stop();
        }
        break;
    }
    return;
  }

  // adjust volumes
  if (currentState == gameState.MENU) {
    switch (key) {
      case '1': case '+': 
        musicVol = constrain(musicVol+0.05, 0,1); 
        MenuSong.amp(musicVol);
        break;
      case '2': case '-': 
        musicVol = constrain(musicVol-0.05, 0,1); 
        MenuSong.amp(musicVol);
        break;
      case '3': case ']': 
        sfxVol   = constrain(sfxVol+0.05, 0,1); 
        break;
      case '4': case '[': 
        sfxVol   = constrain(sfxVol-0.05, 0,1); 
        break;
    }
    return;
  }

  // only process shield and special during playing
  if (currentState == gameState.PLAYING) {
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
}

// 
void mousePressed() {
  if (currentState == gameState.END) {
    if (endScreen.onButton()) {
      endMusic.stop();
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
  }
}
