  import processing.sound.*;
  
  AudioIn             in;
  SoundFile           song;
  MainMenu            mainMenu;
  Play                play;
  SoundFile MenuSong;
  
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


  void keyPressed(){
  if(currentState!=gameState.PLAYING) return;
  int lane=-1;
  switch(key){
    case 'a': lane=0; break;
    case 'x': lane=1; break;
    case 'w': lane=2; break;
    case 'd': lane=3; break;
    case 'q': lane=4; break;
    case 'z': lane=5; break;
    case 'e': lane=6; break;
    case 'c': lane=7; break;
    case ' ': handleSpecial(); return;
  }
  if(lane!=-1) handleHit(lane);
}

void handleHit(int lane){
  float songSec=play.song.position();
  float window=HIT_WINDOW;
  for(Note n : play.live){
    if(n.evt.lane==lane && !n.evt.special && abs(songSec-n.hitSec)<window){
      n.hit=true;
      play.laneUI[lane].pulse(true);
      return;
    }
  }
  play.laneUI[lane].pulse(false);  // miss flash
}

void handleSpecial(){
  float songSec=play.song.position();
  float window=HIT_WINDOW;
  for(Note n : play.live){
    if(n.evt.special && abs(songSec-n.hitSec)<window){
      n.hit=true;
      play.specialUI.pulse(true);
      return;
    }
  }
  play.specialUI.pulse(false);
}

