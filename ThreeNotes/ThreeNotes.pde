import processing.serial.*; //import port library to read from Arduino
import arb.soundcipher.*; //import sound library

Serial myPort;
SoundCipher sc = new SoundCipher(this);


//GLOBAL VARIABLES
float pitch = 0; //changing voltage from the EMG

int check; //variables to set note duration
int timer = 0;
boolean foo = true;

float threshold1 = 8; //thresholds to distinguish btwn three notes
float threshold2 = 100; //can be scaled during calibration
float threshold3 = 350;


void setup()
{
  String portName = Serial.list()[1]; //serial connection to Arduino
  myPort = new Serial (this, portName, 9600); 
}


void draw()
{
  String msg; //variables for EMG
  long nummsg;
  long clampedmsg; //final EMG values, from 0, ~480
  float duration = random(100,1500); //of note, in ms 
  
  try 
    {
      
      while (myPort.available() > 0) { //COD FOR GETTING VOLTAGES
        msg = myPort.readStringUntil('\n');
        if ((msg != null) && (msg != "")) {
          nummsg = Long.parseLong(msg.trim()); 
          
          clampedmsg = Math.max(0, Math.min(480, nummsg)); //final voltages, (0, ~480)
          println(clampedmsg);
          
          //CODE FOR REFRESHING TO SET NOTE DURATION
          int ms = millis(); //refresh ms every try loop
          check = ms-timer; //change condition for foo
          
          if (check>duration){
            foo = true; //switch foo on after the length of duration (in ms)
          }
                      
          //CODE TO PLAY SOUNDS
          pitch = map(clampedmsg, 0, 500, 35, 125); //map voltage to pitch in soundcipher
 
           if (clampedmsg<threshold1 & foo){
             sc.playNote(0, 0, 2.0); //silent note, relaxed eyebrows
             timer = ms;
             foo = false;
           }
           else if (clampedmsg < threshold2 & clampedmsg > threshold1 & foo) {
             sc.playNote(60, 100, 2.0); //middle C, small eyebrow raise
             timer = ms; 
             foo = false; //flag
           } 
           else if (clampedmsg < threshold3 & clampedmsg > threshold2 & foo) {
             sc.playNote(62, 100, 2.0); //D, medium eyebrow raise
             timer = ms;
             foo = false;
           }
           else if (clampedmsg > threshold3 & foo) {
             sc.playNote(64, 100, 2.0); //E, high eyebrow raise
             timer = ms;
             foo = false;
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

class ThreeNotes{
  ThreeNotes(float temppitch, int tempcheck, int temptimer, boolean tempfoo, float tempthreshold1, float tempthreshold2, float tempthreshold3){
    pitch = temppitch;
    check = tempcheck;
    timer = temptimer;
    foo = tempfoo;
    threshold1 = tempthreshold1;
    threshold2 = tempthreshold2;
    threshold3 = tempthreshold3;
  }

}
