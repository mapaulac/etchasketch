//PROCESSING CODE 

//SERIAL COMMUNICATION 
import processing.serial.*;
Serial myPort;
PImage img;

//CREATING LAYERS + ARRAYS
boolean layer1 = true;
boolean layer2 = false;
boolean layer3 = false;

//DEFINING MODE VARIABLES
boolean restartDrawing = false;
boolean drawing = true;
boolean currentData = false;
boolean saveButton = false;
boolean previousData = false;
boolean clearLayer2 = false;

//DISPLAY VARIABLES  
boolean display1 = false;
boolean display2 = false;
boolean display3 = false;

//CREATING ARRAYS, WILL CONTAIN 3 POSSIBLE DRAWINGS  
int[] xlayer1 = {};
int[] ylayer1 = {};

int[] xlayer2 = {};
int[] ylayer2 = {};

int[] xlayer3 = {};
int[] ylayer3 = {};

int led;
int led2; 

int xPos = 0;
int yPos = 0;

void setup(){
 printArray(Serial.list()); 
 //CHOOSING SERIAL PORT FROM LIST 
 String portname = Serial.list()[2];
 println(portname);
 
 //SERIAL COMMUNICATION 
 myPort = new Serial(this,portname,9600);
 myPort.clear(); 
 myPort.bufferUntil('\n'); 
 
 size(700,573);
 background(255,255,255);
 img = loadImage("blanksketch2.png");
}

void draw(){
 image(img, 0, 0);
 ellipse(xPos,yPos,1,1);
 
  //CHECKS FOR RESTARTING OF SCREEN
 if (restartDrawing == true){
 background(255,255,255);
 image(img, 0, 0);
 println("RESTARTED DRAWING");
 restartDrawing = false;
 }
 
 //CHECKS IF PERSON IS IN DRAWING MODE (ON OR OFF), STARTS DRAWING
 if (drawing == true){
   println("ENTERING DRAWING LOOP");
   
   //DRAWS FIRST LAYER 
   if (layer1 == true){
     println("DRAWING LAYER 1");
     int Xcoordinate = xPos;
     int Ycoordinate = yPos;
     xlayer1 = append(xlayer1, Xcoordinate);
     ylayer1 = append(ylayer1, Ycoordinate);
     
     //DRAWS POINTER
     if ( (100 < xPos && xPos < 590) && (100 < yPos && yPos < 450)){ 
     ellipse(xPos,yPos,1,1);
     }
   }
 
   //DRAWS SECOND LAYER 
   if (layer2 == true){
     println("DRAWING LAYER 2");
     if (clearLayer2 == true){
     background(255);
     image(img, 0, 0);
     clearLayer2 = false;
     }
     
     int Xcoordinate = xPos;
     int Ycoordinate = yPos;
     xlayer2 = append(xlayer2, Xcoordinate);
     ylayer2 = append(ylayer2, Ycoordinate);
     
     //DRAWS POINTER
     if ( (100 < xPos && xPos < 590) && (100 < yPos && yPos < 450)){ 
     ellipse(xPos,yPos,1,1);
     }
   }
 
 }
 
 //DISPLAYS DRAWING DEPENDING ON BUTTONS THAT ARE ON
 if (drawing == false){
   background(255);
 
   //IF BUTTON 1 IS PRESSED, SHOW FIRST DRAWING 
   if (display1 == true){
     println("first layer visible");
     for (int i = 0; i < (xlayer1.length - 1); i++){
     line(xlayer1[i],ylayer1[i],xlayer1[i+1],ylayer1[i+1]); 
   }
   //restartDrawing = false;
   }
   
   //IF BUTTON 2 IS PRESSED, SHOW SECOND DRAWING 
   else if (display2 == true){
     println("second layer visible");
     for (int i = 0; i < (xlayer2.length - 1); i++){
     line(xlayer2[i],ylayer2[i],xlayer2[i+1],ylayer2[i+1]); 
   }
   //restartDrawing = false;
   }
   
   println("showing image in display");
   image(img, 0, 0);
 }

 //CHECKING FOR SAVE/button press 
 if (saveButton == true){
   if (layer1 == true){
     drawing = true;
     layer1 = false;
     layer2 = true;
     clearLayer2 = true;
     println("CHANGE TO LAYER 2");
   }
   else if (layer2 == true){
     layer1 = false;
     layer2 = false;
     drawing = false;
     println("CHANGE TO DRAWING PHASE");
   }
 }
}

//SERIAL EVENT 
void serialEvent(Serial myPort){
 String s = myPort.readStringUntil('\n');
 s = trim(s); 
 println(s);
 
 if (s!=null){
   int value[] = int(split(s,',')); //taking string and splitting it at ','
   
   if (value.length == 7){
     xPos = (int)map(value[0],0,1023,0,width);
     yPos = (int)map(value[1],0,1023,0,height);
     
     //CHECKING FOR DISPLAY OF FIRST DRAWING 
     if (value[3] == 1 && value[4] == 0){
       println("VALUE 1 TRUE, GOING TO DISPLAY 1");
       display1 = true;
     }
     else {
       println("VALUE 1 FALSE");
       display1 = false;
     }
     
     //CHECKING FOR DISPLAY OF SECOND DRAWING 
     if (value[4] == 1 && value[3]==0){
       println("VALUE 2 TRUE, GOING TO DISPLAY 2");
       display2 = true;
     }
     else{
       println("VALUE 2 FALSE");
       display2 = false;
     }
     
     //CHECKING FOR SAVED STATE
     if (value[6] == 1){
       saveButton = true;
       println("SAVE DATA TRUE");
     }
     else if (value[6] == 0){
       saveButton = false;
       println("SAVE DATA FALSE");
     }
   
   }
   myPort.write(led+","+led2+"\n"); //will send a byte once it receives one
 }
}