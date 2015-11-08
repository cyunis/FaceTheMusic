import processing.serial.*; //import port library to read from Arduino

public class Shield {
  
  public String currentmsg;
  public long currentval;
  public long clampedval;
  
  Serial connection;
  
  public void Shield () { // Open connection on Shield.new
    String portName = Serial.list()[1]; // serial connection to Arduino
    connection = new Serial (this, portName, 9600); 
  }
  
  public void update () // Reads from the Spikershield and updates currentmsg, currentval, clampedval
  {
    try 
    {
      while (connection.available() > 0) {  // Check for open connection.
        currentmsg = connection.readStringUntil('\n'); //  Pull message.  
        if ((msg != null) && (msg != "")) 
        {
          nummsg = Long.parseLong(msg.trim());
          clampedmsg = Math.max(0, Math.min(480, nummsg)); //final voltages: 0 .. ~480)
        } //end if      
      } //end while
    } //end try
       
    catch (NumberFormatException nfe) // If the incoming data is encoded incorrectly, catch.
    {
      System.out.println("NumberFormatException: " + nfe.getMessage());
    }
  }
} 
    
