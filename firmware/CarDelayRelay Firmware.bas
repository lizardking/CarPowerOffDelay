'************************************************************************************
'** Car delay relay firmware
'************************************************************************************
'To set the desired turn off delay,do the following:
'- Put the trimmer on the board to a value which is well above the desired
'  target time. Max. time is when the timer is fully at the 5V end
'- Start the timer with a 12V pulse on the sense input
'- Let the time you want the timer to run elapse,
'- Now turn the trimer back towards the GND end till the timer stops/relay turns off.
'Bingo! You have set the desired turn off delay time.
'
'The code below is has been written for Bascom. Dead ugly, but working ;)
'Tom 23.1.2021


'Just some general settings
$regfile = "attiny13.dat"
$crystal = 1200000
$hwstack = 16
$swstack = 5
$framesize = 16


'Relay
Relay alias PORTB.3
config PORTB.3=OUTPUT
Relay=1


'Digital input for power sense
Sense alias PINB.1
config PORTB.1=input
PORTB.1=1


'Analog input for trimmer
config portb.4=input  'Poti
const adcchannel=2

Config Adc = Single , Prescaler = Auto
Start Adc


'Variables

dim ElapsedTime as Word
dim AdcValue as Word
ElapsedTime=0


'loop

do
   if sense=0 then
     'As long as power is sensed time does not elapse
     ElapsedTime=0
     Relay=1
   else
      'No power is sensed
      'Compare elapsed time to value from ADC.
      'ADC returns 0 - 1023 which is multiplied by 8 giving a usable range from 0 - 8184 seconds (approx.136 minutes).
      Adcvalue=GetAdc(adcchannel)
      SHIFT Adcvalue, LEFT,3
      if adcValue<=ElapsedTime then
         'Elapsed time is greater than the value calculated from ADC.
         'Turn the relay power off. This will disconnect the output and the timer circuit,
         'so zero power is used after the timer has elapsed.
         Relay=0
      end if
      'Just wait a second before checking again
      waitms 1000
   end if
loop