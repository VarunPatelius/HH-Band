#include <Arduino.h>

#define SAMPLING_RESISTOR	10000//the sampling resistor is 10k ohm
#define NTC_R25 10000//the resistance of the NTC at 25'C is 10k ohm
#define NTC_B   3950


class Temperature {
    uint8_t _pin;
public:
	Temperature(uint8_t sensor_pin){_pin = sensor_pin;}
 
    float getTemperature()
    {
    	float temperature,resistance;
    	int a;
      analogReadResolution(12);
    	a = analogRead(_pin);
    	resistance   = (float)a*SAMPLING_RESISTOR/(4096-a); //Calculate the resistance of the thermistor
    	/*Calculate the temperature according to the following formula.*/
    	temperature  = 1/(log(resistance/NTC_R25)/NTC_B+1/298.15)-273.15;
		temperature = ( (float)( (int)( (temperature + 0.05) * 10 ) ) ) / 10;//Rounded to one decimal place
    	return (temperature * 1.4) + 32;
    }

};