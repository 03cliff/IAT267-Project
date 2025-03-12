#include <Servo.h>
//#include <SparkFun_TB6612.h>

enum analogSensorPins {ROT_SENSOR_PIN, FWD_BCK_SLIDER_PIN, WHGHT_SENSOR_PIN};

//Digital 
const int REEL_BUTTON_PIN = 2;

//Pins for the DC motor
const int REEL_MOTOR_AI1 = 4; //direction control 1
const int REEL_MOTOR_AI2 = 7; //direction control 2
const int REEL_MOTOR_STBY = 8; //standby mode control
const int REEL_MOTOR_PWMA = 3; //speed of motor

Servo armRotator;
Servo armFwdBk;

bool lineReelDown = true;
int reelTime = 0;
const int REEL_TIME_MAX = 50;

int buttonInputTimer = 0;
const int BUTTON_INPUT_TIMER_DELAY_MAX = 100;

void setup() {
  Serial.begin(9600);

  pinMode(REEL_BUTTON_PIN, INPUT);
  
  pinMode(REEL_MOTOR_AI1, OUTPUT);
  pinMode(REEL_MOTOR_AI2, OUTPUT);
  pinMode(REEL_MOTOR_STBY, OUTPUT);
}

void loop() {
//  Serial.println(ROT_SENSOR_PIN);
  
  armRotator.write(AnalogInToDegrees180(ROT_SENSOR_PIN));
  armFwdBk.write(AnalogInToDegrees180(FWD_BCK_SLIDER_PIN));

  if(digitalRead(REEL_BUTTON_PIN) == HIGH && buttonInputTimer == 0){
    if(lineReelDown == true){
      lineReelDown = false;
      Serial.println("reel up");
    }else if(lineReelDown == false){
      lineReelDown = true;
      Serial.println("reel down");
    }
    buttonInputTimer = BUTTON_INPUT_TIMER_DELAY_MAX;
    reelTime = 0;
  }

  if(buttonInputTimer > 0){buttonInputTimer -= 1;}

  if(lineReelDown == true && reelTime < REEL_TIME_MAX){
    Serial.println("reelingDown");
    reelTime++;
    
    //Spin Clockwise at speed 150
    digitalWrite(REEL_MOTOR_STBY, HIGH);
    analogWrite(REEL_MOTOR_PWMA, 150);
    digitalWrite(REEL_MOTOR_AI1, HIGH); 
    digitalWrite(REEL_MOTOR_AI2, LOW); 
    if(reelTime >= REEL_TIME_MAX){
      Serial.println("switch to false");
      lineReelDown == false;
    }
  }
  else if(lineReelDown == false && reelTime < REEL_TIME_MAX){
    Serial.println("reelingUp");
    reelTime++;
    
    //Spin Counter-Clockwise at speed 150
    digitalWrite(REEL_MOTOR_STBY, HIGH);
    analogWrite(REEL_MOTOR_PWMA, 150);
    digitalWrite(REEL_MOTOR_AI1, LOW); 
    digitalWrite(REEL_MOTOR_AI2, HIGH); 
    if(reelTime >= REEL_TIME_MAX){
      Serial.println("switch to true");
      lineReelDown == true;
    }
  }else{
    digitalWrite(REEL_MOTOR_STBY, LOW);
    analogWrite(REEL_MOTOR_PWMA, 0);
  }
  
  delay(15);
}

int AnalogInToDegrees180(int analogIn){
  int rotVal = analogRead(analogIn);
  rotVal = map(rotVal, 0, 1023, 0, 180);
  return rotVal;
}
