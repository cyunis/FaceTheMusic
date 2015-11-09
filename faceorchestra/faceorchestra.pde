import processing.serial.*; //import port library to read from Arduino
import arb.soundcipher.*; //import sound library

Serial myPort;
SoundCipher[] ciphers = {new SoundCipher(this), new SoundCipher(this), new SoundCipher(this)};

//GLOBAL VARIABLES
long[] EMGarray = new long[10]; //array for measuring spikes

float[] pitches = {84, 76, 67};
float[] insts = {ciphers[0].XYLOPHONE, ciphers[0].WOODBLOCKS, ciphers[0].PIPES, 
                  ciphers[0].VIOLIN, ciphers[0].VIOLA, ciphers[0].CELLO,
                  ciphers[0].SEA, ciphers[0].OCARINA, ciphers[0].DRUM};
int orchestrationOffset = 0;

int check; //variables to set note duration
int timer = 0;
boolean foo = true;
int count = 0;
float threshold1 = 350;
float threshold2 = 100;
float threshold3 = 200;
float threshold4 = 30;

void setup()
{
  String portName = Serial.list()[1]; //serial connection to Arduino
  myPort = new Serial (this, portName, 9600); 
  for (int i=0; i<EMGarray.length;i++){
    EMGarray[i]=0;
  }
}


void draw()
{ 
  String msg; //variables for EMG
  long nummsg;
  long clampedmsg; //final EMG values, from 0, ~480
  float duration = 1000; //of note, in ms 
  
  count += 1;
  try 
    {
      while (myPort.available() > 0) { //CODE FOR GETTING VOLTAGES
        msg = myPort.readStringUntil('\n');
        if ((msg != null) && (msg != "")) {
          nummsg = Long.parseLong(msg.trim()); 
          
          clampedmsg = Math.max(0, Math.min(480, nummsg)); //final voltages, (0, ~480)
          //println(clampedmsg);
          
          //[0] most recent voltage value, push values to the end of the array
          EMGarray[9]=EMGarray[8];
          EMGarray[8]=EMGarray[7];
          EMGarray[7]=EMGarray[6];
          EMGarray[6]=EMGarray[5];
          EMGarray[5]=EMGarray[4];
          EMGarray[4]=EMGarray[3];
          EMGarray[3]=EMGarray[2];
          EMGarray[2]=EMGarray[1];
          EMGarray[1]=EMGarray[0];          
          EMGarray[0]=clampedmsg;

          //CODE FOR REFRESHING TO SET NOTE DURATION
          int ms = millis(); //refresh ms every try loop
          check = ms-timer; //change condition for foo
          
          if (check>duration){
            foo = true; //switch foo on after the length of duration (in ms)
          }
                      
          //CODE TO PLAY SOUNDS
          if (foo){
            timer = ms;
            foo = false;
            float slope = EMGarray[0]-EMGarray[3]; //calculating slope of the spike.
            float longslope = EMGarray[0]-EMGarray[9];
            float posslope = abs(slope);
            float poslongslope = abs(longslope);
            println(posslope, poslongslope, clampedmsg);
            
            //CODE FOR DIFF SOUNDS FOR DIFF GESTURES
            if(posslope>320 & clampedmsg>threshold1){ //smiling big
              orchestrationOffset = 0;
              play(0);  
            }
            if(posslope>20 & posslope<50 & clampedmsg>threshold2 & clampedmsg<threshold3){ //raising eyebrows
              orchestrationOffset = 3;
              play(0);
            }
            if(posslope>90 & clampedmsg>threshold3){ //open jaw quickly
              orchestrationOffset = 0;
              play(1);
            }
            if(posslope<20 & posslope>6 & clampedmsg<threshold4){ //puff cheeks
              orchestrationOffset = 0;
              play(2);
            }
            if(poslongslope<50 & clampedmsg>threshold3 & clampedmsg<threshold1){ //scrunch face
              orchestrationOffset = 6;
              play(2);
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
}  


void play(int i) {
  ciphers[i].instrument = insts[i + orchestrationOffset];
    ciphers[i].playNote(pitches[i],random(70, 120), 3);
  pitches[i] = modeQuantize(pitches[i] - 3, ciphers[i].PENTATONIC, 0);
  if (pitches[i] <48) pitches[i] = 84 - i*12;
}

  //a method reused from the minorRiff program in the Scale tutorial
  float modeQuantize(float pitch, float[] mode, int keyOffset) {
    pitch = round(pitch);
    boolean inScale = false;
    while(!inScale){
      for(int i=0; i<mode.length; i++) {
        if ((pitch - keyOffset)%12 == mode[i]) inScale =true;
      }
      if(!inScale) pitch++;
    }
    return pitch;
  }
