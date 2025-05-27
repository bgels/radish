  import processing.sound.*;
  
  SoundFile           song;
  MainMenu            mainMenu;
  Play                play;
  
  enum gameState {
    MENU,
    PLAYING
  }
  
  gameState currentState = gameState.MENU;
  
  void setup() {
    fullScreen(P3D);
    mainMenu = new MainMenu("ost");  
  }
    
  void draw() {
    switch (currentState) {
      case MENU:
        mainMenu.update();
        break;
  
      case PLAYING:
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
