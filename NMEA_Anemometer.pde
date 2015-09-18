//NMEA_Anemometer - $WIMWV
//
//2014.09.09
//
//2014.09.24 True/Relative button added.
//
//takano.

public class Constants{
  //
  // Constants definition
  //
  // Following Items are Cnstants definited.
  //    @ Com port No.
  //    @ Sentence transmit interbal
  //    @ Talker ID  
  //
  //==================================================
  //Please enter the Number of Com port to be used here
  //by referring your PC's Device Manager.
  //
  //Example: If you would like to use Com port 1,
  //        Wirte down  COM_PORT = "COM1"; .
 
    public static final String COM_PORT = "COM1";
 
  //=================================================
  //Please enter the interbal time of NMEA sentence
  //sending in [ms] here.
  //
  //Default value 1000[ms] 
 
    public static final int REFLESH_RATE = 500;

  //=================================================

    public static final String TALKER_ID = "WI";

  //=================================================
}



import processing.serial.*;
Serial comPort;

import controlP5.*;
ControlP5 cp5;





float wind_direction = 0;
float wind_speed = 0;

int chksum = 0x00;
int i = 0; //for roop
float k = 0.0;

String nmea_MWV_sentence = "$WIMWV,";
String float2string_direction;
String float2string_speed;

char wind_direction_mode = 'R';
String wind_direction_mode_text= "Relative";

char wind_speed_unit = 'N';
String wind_speed_unit_text = "[knots]";



char[] sentence_for_cheksum;




void setup(){ 

  size(250,280);
  randomSeed(hour()*minute()*second()); 
  
  comPort = new Serial(this, Constants.COM_PORT, 4800);
  comPort.clear();
  
  k = random(5);
  
//=======BUTTONS==============

  cp5 = new ControlP5(this);
    cp5.addButton("True")
     .setValue('T')
     .setPosition(20,240)
     .setSize(40,30)
     ;
  
    cp5.addButton("Relative")
     .setValue('R')
     .setPosition(80,240)
     .setSize(50,30)
     ;
  

    cp5.addButton("knots")
     .setValue('N')
     .setPosition(150,240)
     .setSize(30,30)
     ;

    cp5.addButton("m/s")
     .setValue('M')
     .setPosition(200,240)
     .setSize(30,30)
     ;


  
//=============================
  

}

void draw(){
 
 nmea_MWV_send(); //serial communication

//window
 background(0); 
 textSize(16);
 text("Wind Direction",10,20);
 textSize(48);
 text(nf(wind_direction,1,1),10,70);
 textSize(16);
 text("[deg]",160,70);
 text("Wind Speed",10,110);
 textSize(48);
 text(nf(wind_speed,1,1),10,155);
 textSize(16);
 text(wind_speed_unit_text,160,155);

 textSize(14);
 text(nmea_MWV_sentence,10,180);
 
 textSize(12);
 text(Constants.COM_PORT,200,195); 

 textSize(18);
 text(wind_direction_mode_text,20,230); 

 textSize(18);
 text(wind_speed_unit_text,150,230); 


//window

  


  delay(Constants.REFLESH_RATE); 

}


void nmea_MWV_send(){

 wind_direction = wind_direction + 0.1;
 if (wind_direction >= 360.0){wind_direction = 0.0;}
 
 wind_speed = abs( 50.0*sin(0.5*k));
 k = k+0.1;
 

 // For cheksum debug.
 //wind_direction = 111.1;
 //wind_speed = 11.1;

  nmea_MWV_sentence =  Constants.TALKER_ID + "MWV,"
                       + nf(wind_direction,1,1)  
                       + ','
                       + wind_direction_mode
                       + ','
                       + nf(wind_speed,1,1)
                       + ','
                       + wind_speed_unit
                       + ",A"
                       ;

  sentence_for_cheksum = nmea_MWV_sentence.toCharArray();

  for (i = 0; i <= nmea_MWV_sentence.length()-1; i++){
  
       chksum ^= sentence_for_cheksum[i];
      //print(sentence_for_cheksum[i]);  
  }

  nmea_MWV_sentence = "$" + nmea_MWV_sentence
                          + "*"+hex(chksum,2);

  chksum = 0;

  comPort.write(nmea_MWV_sentence);
  comPort.write("\r\n");



  println(nmea_MWV_sentence);
  
}



public void controlEvent(ControlEvent theEvent) {
 
  
  if(theEvent.getController().getName() == "True"){

    wind_direction_mode = 'T';
    wind_direction_mode_text= "True"; 
   
  }
    else if(theEvent.getController().getName() == "Relative"){
      wind_direction_mode = 'R';
      wind_direction_mode_text= "Relative"; 
}

     else if(theEvent.getController().getName() == "knots"){
       wind_speed_unit = 'N';
       wind_speed_unit_text = "[knots]";

}

     else if(theEvent.getController().getName() == "m/s"){
       wind_speed_unit = 'M';
       wind_speed_unit_text = "[m/s]";

}



}

