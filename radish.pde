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
