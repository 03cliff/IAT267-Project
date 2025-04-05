import processing.serial.*;
import ddf.minim.*;
Serial myPort; // serial port object
String[] portList = Serial.list();
final int PORT_NUM = 4;
//PortHandler portHandler;

final int GAME_TITLE = 0;
final int PLAYMODE = 1;
final int GAME_END = 2;
final int GAMEINSTRUCTION = 3;

  byte[] inBuffer;       // buffer of fish
  String myString;       // buffer string
  String[] f;            // fish packet
  String[] c;               // fish color
  String[] w;               // fish weight
  int weightL;           // Lower weight bound
  int weightM;           // middle weight bound
  int tweightU;          // Upper weight bound

StartScreen ss;
Intro in;
Minim minim;
AudioPlayer backSound, click;

boolean spacePressed = false;
ArrayList<Fish> fish = new ArrayList<Fish>();
PImage fishImg;
PImage deadFishImg;
PImage winFishImg;

int gameState = GAME_TITLE;   // Begin gamestate at game title screen
int gameTimeMax = 60000;      // Max play time in ms
int gameTimeStart = 0;        // Time of game start
int time = 0;                 // Time remaining
int score = 0;                // Player score
int timeCountDown = 10 * 60;  // Start count down after the game ends and starts the game again
int numberFish = 5;           // Number of the fish

void setup()
{
  size(1000, 716);
  loadAssets();
  for (int i = 0; i < numberFish; i ++) {
    fish.add(new Fish(new PVector(random(width), random(50, 650)), new PVector(random(-6, -1), 0), fishImg, random(1, 3)));
  }
  
  println(Serial.list());
  myPort = new Serial (this, Serial.list()[PORT_NUM], 9600);
  //portHandler = new PortHandler(myPort);
      inBuffer = new byte[255];
    
    // TO DO : Change to values reflecting actual weight
    weightL = 10; 
    weightM = 20; 
    tweightU = 30; 
}

void draw()
{
  println(gameState);
  switch (gameState)
  {
  case GAME_TITLE :
    gameTitle();
    break;

  case GAMEINSTRUCTION :
    displayHowToPlayScreen();
    gameTimeStart = millis();
    break;

  case PLAYMODE :
    playMode();
    break;

  case GAME_END :
    gameEnd();
    break;
  }
}

void gameTitle()
{
  //background(0);
  println("game title");
  displayStartScreen();
  score = 0;
  checkBuffer();
}

//hello world
void playMode()
{
  println("play mode");
  background(160, 214, 217);
  text("" + (gameTimeMax - time)/1000, width/2, height/4);  // Show time remaining in seconds
  text("" + score, width/2, height/2);                      // Show score in screen centre

  checkBuffer();

  time = millis() - gameTimeStart;          // total time in play mode
  if (time >= gameTimeMax)
  {
    gameState = GAME_END;
  }
}

void gameEnd()
{
  println("game end");
  //background(160,214,217);
  fill(255);
  if (score <= 2) {
    ifLose();
    text("Hm...", width/3, height/4);
    text("Your score is " + score, width/3, height/4+60);
  } else if (score >= 3) {
    ifWin();
    text("Yahoooo! Get some sushi ??", width/3-30, height/4);
    text("Your score is " + score, width/3+30, height/4+60);
  }
  //text(score, width/2, height/2);
  reStart();
  checkBuffer();
}

void reStart() {
  println(timeCountDown = timeCountDown - 1, "countdown is working");
  text("Going back to the main screen in " + timeCountDown/50, width/3-80, height/2+ 100);
  text("Click on screen to go back now", width/3-50, height/2 + 150);
  if (timeCountDown <= 0) {
    gameState = GAME_TITLE;
    timeCountDown = 10 *60;
  }
}

void displayStartScreen() {
  ss.drawMe();
  spawnFish();
  textSize(100);
  PFont font = loadFont("Skia-Regular_Black-Condensed-48.vlw");
  textFont(font);
  textSize(100);
  text("Welcome", width/2-150, height/2); // Display Title screen
  textSize(40);
  text("Click on screen to Start", width/3, height/2+300);
}

void displayHowToPlayScreen() {
  in.drawMe();
  textSize(40);
  text("This game is about ... ", width/8, height/2-80);
  text("Click on screen to start timer ", width/8, height/2);
  spawnFish();
  checkBuffer();
}

void loadAssets() {
  fishImg = loadImage("fish.png");
  deadFishImg = loadImage("dead.png");
  winFishImg = loadImage("winFish.png");
  ss = new StartScreen(loadImage("start.png"));
  in = new Intro(loadImage("intro.png"));
  minim = new Minim(this);
  backSound = minim.loadFile("backSound.mp3");
  backSound.loop();
  click = minim.loadFile("click.mp3");
}

void spawnFish() {
  for (int i = 0; i < fish.size(); i++) {
    Fish fishes = fish.get(i);
    fishes.update();
  }
}

void ifLose() {
  background(233);
  image(deadFishImg, width/2 -40, height/2-20, 180, 65);
}

void ifWin() {
  background(147, 194, 245);
  image(winFishImg, width/2 -40, height/2-60, 100, 108);
}

  void checkBuffer()
  {
    println("checking buffer");
    if (myPort.available() > 0) 
    {
      myPort.readBytesUntil('&', inBuffer);
      if (inBuffer != null) {
        println("in buffer " + inBuffer);
        println("check buffer");
        myString = new String(inBuffer);
        //String[] useableString = splitTokens(myString, "&");
        println("buffer string " + myString);
        f = splitTokens(myString, "&");
        c = splitTokens(f[0], "C"); // Convert string value to integer
        w = splitTokens(f[0], "W"); // Convert string value to integer
        r = splitTokens(c[0], "R"); // Grab RED color value
        g = splitTokens(c[0], "G"); // Grab GREEN color value
        b = splitTokens(c[0], "B"); // Grab BLUE color value
      }
      switch (gameState) 
      {
        case GAME_TITLE :
        println("case: game title");
        println("received: "  + f[0]);
          if (f[0] == "3") 
          {
            println("change game state to game instruction");
            gameState = GAMEINSTRUCTION;
            myPort.write(gameState);
          }
          else
          {
            println("No change in game state: Title Screen");
          }
          myPort.clear();
          //inBuffer = new byte[255];
          //myString =  "";
        break;
          
        case GAMEINSTRUCTION :
        println("case: game instruction " + f[0]);
        println("received: "  + f[0]);
          if (Integer.parseInt(f[0]) == 1) 
          { 
            println("change game state to play mode");
            gameState = PLAYMODE;
            myPort.write(gameState);
          }
          else 
          {
            println("No change in game state: Game Instruction");
          }
          myPort.clear();
          //inBuffer = new byte[255];
          //myString =  "";
          
        break;
         
        case PLAYMODE :
        int s = 0;
        println("case: playmode");
        // Checking Color
        println("color: " +Integer.parseInt(r[0])+ ", " +Integer.parseInt(g[0])+ ", " +Integer.parseInt(b[0]));
        //  if ((Integer.parseInt(r[0]) < gameR + int && Integer.parseInt(r[0]) > gameR - int) &&
        //      (Integer.parseInt(g[0]) < gameG + int && Integer.parseInt(g[0]) > gameG - int) &&
        //      (Integer.parseInt(b[0]) < gameB + int && Integer.parseInt(b[0]) > gameB - int) ) { 
        //      s += 3; 
        //  } else {s+=1;}
        println("weight: " + w[0]);
          // Check info received about fish
          if (Integer.parseInt(w[0]) >= weightL && Integer.parseInt(w[0]) < weightM) 
          {
            s += 1;
          }
          else if (Integer.parseInt(w[0]) >= weightM && Integer.parseInt(w[0]) < weightL)
          {
            s += 2;
          }
          else if (Integer.parseInt(w[0]) >= weightL)
          {
            s += 3;
          }  
          else
          {
            println("No change to score from weight");
          }  
          score += s;
        break;
        
        case GAME_END :
        println("case: game instruction" + f[0]);
        println("received: "  + f[0]);      
          if (f[0] == "0") 
          {
            println("change game state to game title");
            gameState = GAME_TITLE;
            myPort.write(gameState);
          }      
        break;
        
        default :
        println("nothing happened");
        break;
      }
    }
  }
