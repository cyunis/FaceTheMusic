import processing.serial.*; //import port library to read from Arduino
import arb.soundcipher.*; //import sound library

Serial myPort;
SoundCipher sc = new SoundCipher(this);

//GLOBAL VARIABLES
//ArrayList EMGarray = new ArrayList();
long[] EMGarray = new long[4];
//int s = second();

int check; //variables to set note duration
int timer = 0;
boolean foo = true;
int count = 0;

void setup()
{
  String portName = Serial.list()[1]; //serial connection to Arduino
  myPort = new Serial (this, portName, 9600); 
  for (int i=0; i<EMGarray.length;i++){
    EMGarray[i]=0;
  }
  //size(800, 700);
  //background(0);
}


void draw()
{
  //println(count);
  String msg; //variables for EMG
  long nummsg;
  long clampedmsg; //final EMG values, from 0, ~480
  float duration = 1500; //of note, in ms 
  
  count += 1;
  try 
    {
      while (myPort.available() > 0) { //CODE FOR GETTING VOLTAGES
        msg = myPort.readStringUntil('\n');
        if ((msg != null) && (msg != "")) {
          nummsg = Long.parseLong(msg.trim()); 
          
          clampedmsg = Math.max(0, Math.min(480, nummsg)); //final voltages, (0, ~480)
          
          for (int i=EMGarray.length-1; i>0;i--){
            EMGarray[i-1]=EMGarray[i];
          }
          
          EMGarray[0]=clampedmsg;
          //println(EMGarray);
          


//              float plotVar = clampedmsg;
//              stroke(255,0,0);
//              line(frameCount-1,prevY,frameCount, plotVar);
//              prevY=plotVar;

          //CODE FOR REFRESHING TO SET NOTE DURATION
          int ms = millis(); //refresh ms every try loop
          check = ms-timer; //change condition for foo
          
          if (check>duration){
            foo = true; //switch foo on after the length of duration (in ms)
          }
                      
          //CODE TO PLAY SOUNDS
          //pitch = map(clampedmsg, 0, 500, 35, 125); //map voltage to pitch in soundcipher
          
          if (foo){
             sc.playNote(0, 0, 2.0); //silent note, relaxed eyebrows
             timer = ms;
             foo = false;
             //calculating slope of the spike
            float slope = EMGarray[0]-EMGarray[3];
          
            float a = EMGarray[0]-EMGarray[1];
            float b = EMGarray[1]-EMGarray[2];
            float c = EMGarray[2]-EMGarray[3];
          
            float[] ppp = {a, b, c, a+20};
            println(ppp);
            if(slope>100){ //if there's a large slope
              sc.playChord(ppp, 100, 2.0);
            }
           }
         
        } //end if      
      } //end while
    } //end try

  //CODE TO CATCH ERRORS  
  catch (NumberFormatException nfe)
    {
      System.out.println("NumberFormatException: " + nfe.getMessage());
    }  
    
//  for (int i=0;i<EMGarray.size()+1;i++) {
//    line(0,0, i,EMG)
//  }
  
//  noFill();
//  stroke(255,0,0);
//  beginShape();
//  for (int i=0;i<1000;i++) {
//    float I = EMGarray[i];
//    vertex(i, I);
////    if (P.x<0)poop.remove(i);
////    P.x--;
//  }
//  endShape();

}  

