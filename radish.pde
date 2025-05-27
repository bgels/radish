  import processing.sound.*;
  
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
          pushMatrix();
          play.update();
          popMatrix();
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
