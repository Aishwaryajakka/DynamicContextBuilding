// Pin definitions
const int trigPin = 12;
const int echoPin = 13;
const int light = 4;//yellow
const int lock = 5;//green
const int fan = 6;//blue
const int alarm = 7;//red
int tempPin = A0;
int gasPin = A1;


int val;
int gas;
long duration;
int distance;
int threshold;
byte Tpack[5] = {0x55,0x00,0x00,0x00,0x00};
byte Rpack[5] = {0x00,0x00,0x00,0x00,0x00};

void Action()
{
  if(Rpack[0] != 0xAB)
  return;

  if(Rpack[1])//light
  {
    digitalWrite(light,HIGH);
  }
  else
  {
    digitalWrite(light,LOW);
  }
  if(Rpack[2])//lock
  {
    digitalWrite(lock,HIGH);
  }
  else
  {
    digitalWrite(lock,LOW);
  }
  if(Rpack[3])//fan
  {
    digitalWrite(fan,HIGH);
  }
  else
  {
    digitalWrite(fan,LOW);
  }
  if(Rpack[4])//alarm
  {
    digitalWrite(alarm,HIGH);
  }
  else
  {
    digitalWrite(alarm,LOW);
  }
  
}


void setup()
{
pinMode(light, OUTPUT); 
pinMode(lock, OUTPUT); 
pinMode(fan, OUTPUT); 
pinMode(alarm, OUTPUT); 
pinMode(trigPin, OUTPUT); // Sets the trigPin as an Output
pinMode(echoPin, INPUT); // Sets the echoPin as an Input
Serial.begin(9600);
Serial.flush();
 
}
void loop()
{


if(Serial.available())
{
Serial.readBytes( Rpack,5);
Action();

}
Serial.flush();
// Clears the trigPin
digitalWrite(trigPin, LOW);
delayMicroseconds(2);

// Sets the trigPin on HIGH state for 10 micro seconds
digitalWrite(trigPin, HIGH);
delayMicroseconds(10);
digitalWrite(trigPin, LOW);

// Reads the echoPin, returns the sound wave travel time in microseconds
duration = pulseIn(echoPin, HIGH);

// Calculating the distance
distance= duration*0.034/2;
 threshold = 20;

// Prints the distance on the Serial Monitor

val = analogRead(tempPin);
gas = analogRead(gasPin);

Tpack[2] = val%64;
Tpack[1] = val/64;
//Serial.println(cel);


if(gas<100)
{
  Tpack[3]=0x01;
  //Serial.println("Detected :)");
}
else
{
  Tpack[3]=0x00;
  //Serial.println("Not Detected :(");
}

if (distance <= threshold){
  Tpack[4]=0x01;
  //Serial.println("Present :)");
}
else{
  Tpack[4]=0x00;
  //Serial.println("Not Present :)");
}
Serial.flush();
 delay(3000); //millis() fetches time since Arduino is running in milliseconds.
 Serial.write(Tpack,5); //executed only every 20secs
 
}


