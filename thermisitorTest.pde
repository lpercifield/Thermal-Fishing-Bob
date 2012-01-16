// which analog pin to connect
#define THERMISTORPIN A0         
// resistance at 25 degrees C
#define THERMISTORNOMINAL 10000      
// temp. for nominal resistance (almost always 25 C)
#define TEMPERATURENOMINAL 25   
// how many samples to take and average, more takes longer
// but is more 'smooth'
#define NUMSAMPLES 5
// The beta coefficient of the thermistor (usually 3000-4000)
#define BCOEFFICIENT 3950
// the value of the 'other' resistor
#define SERIESRESISTOR 10000    


////////////////////////////////////////////
//CHANGE THESE NUMBERS FOR THE TEMPERATURE RANGE//
const float MAXTEMP= 18.0;

const float MINTEMP= 10.0;
////////////////////////////////////////////
 
int samples[NUMSAMPLES];
 
void setup(void) {
  Serial.begin(9600);
  pinMode(9,OUTPUT);
  pinMode(10,OUTPUT);
  pinMode(11,OUTPUT);
  analogReference(EXTERNAL);
}
 
void loop(void) {
  uint8_t i;
  float average;
 
  // take N samples in a row, with a slight delay
  for (i=0; i< NUMSAMPLES; i++) {
   samples[i] = analogRead(THERMISTORPIN);
   delay(10);
  }
 
  // average all the samples out
  average = 0;
  for (i=0; i< NUMSAMPLES; i++) {
     average += samples[i];
  }
  average /= NUMSAMPLES;
 
  Serial.print("Average analog reading "); 
  Serial.println(average);
 
  // convert the value to resistance
  average = 1023 / average - 1;
  average = SERIESRESISTOR / average;
  Serial.print("Thermistor resistance "); 
  Serial.println(average);
 
  float steinhart;
  steinhart = average / THERMISTORNOMINAL;     // (R/Ro)
  steinhart = log(steinhart);                  // ln(R/Ro)
  steinhart /= BCOEFFICIENT;                   // 1/B * ln(R/Ro)
  steinhart += 1.0 / (TEMPERATURENOMINAL + 273.15); // + (1/To)
  steinhart = 1.0 / steinhart;                 // Invert
  steinhart -= 273.15;                         // convert to C
 
  Serial.print("Temperature "); 
  Serial.print(steinhart);
  Serial.println(" *C");
  Serial.print("Mapped "); 
  Serial.println(mapfloat(steinhart,MINTEMP,MAXTEMP,0.0,255.0));
  //int hue = map(int(Thermister(analogRead(0))),-15,0,0,360);
if(steinhart>MINTEMP && steinhart < MAXTEMP){
  analogWrite(11,mapfloat(steinhart,MINTEMP,MAXTEMP,0.0,255.0)); //Red pin attached to 9
  analogWrite(10,255);
  analogWrite(9,255.0-mapfloat(steinhart,MINTEMP,MAXTEMP,0.0,255.0)); //Red pin attached
//  analogWrite(11,map(int(steinhart),MINTEMP,MAXTEMP,0,255)); //Red pin attached to 9
//  analogWrite(10,255);
//  analogWrite(9,255-map(int(steinhart),MINTEMP,MAXTEMP,0,255)); //Red pin attached  
}else if(steinhart>MAXTEMP){
  analogWrite(11,255);
  analogWrite(10,255);
  analogWrite(9,0);
}else if(steinhart<MINTEMP){
  analogWrite(11,0);
  analogWrite(10,255);
  analogWrite(9,255);
}
//  analogWrite(9,0);
//  analogWrite(10,255);
//  analogWrite(11,255);
//  delay(1000);
//  analogWrite(11,255);
//  analogWrite(10,0);
//  analogWrite(9,255);
//  delay(1000);
//  analogWrite(11,0);
//  analogWrite(10,255);
//  analogWrite(9,255);
//  delay(1000);
  delay(1000);
}
float mapfloat(float x, float in_min, float in_max, float out_min, float out_max)
{
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}
