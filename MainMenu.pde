import java.io.File;
class SongEntry {
  String folderName;
  File   audioFile;
  File   jsonFile;     // the .json setup file
  File   smFile;       // the .sm note file

  SongEntry(String folderName, File audioFile, File jsonFile, File smFile) {
    this.folderName = folderName;
    this.audioFile  = audioFile;
    this.jsonFile   = jsonFile;
    this.smFile     = smFile;
  }
}


class MainMenu{
    ArrayList<SongEntry> entries = new ArrayList<SongEntry>();
    int               buttonWidth = 200, buttonHeight = 50, margin = 20;
    SongEntry         selected = null;

    public MainMenu(String path){
        File dir = new File(dataPath(path)); // Gets path to ost folder
        if(dir.exists() && dir.isDirectory()){ // Check if the directory exists
            for(File folder : dir.listFiles()){ // For each subfolder in ost
                if(!folder.isDirectory()){ // if subfolder is not a directory, skip it
                    continue;
                }
                println(" Found folder:", folder.getName());

                for (File f : folder.listFiles()) { // Print subfiles in the subfolder
                    println("   Contains:", f.getName());
                }
                // setup the song entry by looking for .ogg, .json, and .sm files and setting them
                File wavFile = null;
                File jsonFile = null;
                File smFile = null;
                for(File subFile : folder.listFiles()){
                    String name = subFile.getName().toLowerCase();
                    if (name.endsWith(".wav") || name.endsWith(".mp3"))  wavFile  = subFile;
                    else if (name.endsWith(".json")) jsonFile = subFile;
                    else if (name.endsWith(".sm"))   smFile   = subFile;
                }
                
                // If all required files are found for a song, combine and create a SongEntry
                // and add it to the list
                if(wavFile != null && jsonFile != null && smFile != null){
                    entries.add(new SongEntry(folder.getName(), wavFile, jsonFile, smFile));
                    println("Added song: " + folder.getName());
                }
            }
        }

    }

    void update() {
        background(30); // Clear background to dark gray
        textAlign(CENTER, CENTER);
        textSize(24);
        fill(255);
        text("Select a Song", width/2, margin + 20);

        // Each button with proper spacing
        for (int i = 0; i < entries.size(); i++) {
        int x = width/2 - buttonWidth/2;
        int y = margin*2 + 60 + i*(buttonHeight + margin);
        String name = entries.get(i).folderName; // name of song is the subfolder name
        // Truncate name if too long
        if (name.length() > 20) {
            name = name.substring(0, 20) + "...";
        }

        // Hover effect
        if (over(x, y, buttonWidth, buttonHeight)){
            fill(100);
        }
        else{
            fill(70);
        }

        // Draw the actual button
        rect(x, y, buttonWidth, buttonHeight, 8);

        fill(255);
        textSize(20);
        text(name, x + buttonWidth/2, y + buttonHeight/2); // Center name of song in button
        }
    }

    // Handle clicks to any song
    void mousePressed() {
        for (int i = 0; i < entries.size(); i++) {
        int x = width/2 - buttonWidth/2;
        int y = margin*2 + 60 + i*(buttonHeight + margin);
        if (over(x, y, buttonWidth, buttonHeight)) { // If mouse is over corresponding button
            selected = entries.get(i);
            break;
        }
        }
    }

    // Hit-test helper
    boolean over(int x, int y, int w, int h) {
        return mouseX >= x && mouseX <= x + w
            && mouseY >= y && mouseY <= y + h;
    }

    boolean isSongSelected() {
        return selected != null;
    }

    SongEntry getSelectedEntry() {
        return selected;
    }

}
