/*
  ATmega328P @ 3.3V, 8 MHz internal RC (MiniCore target)
  UART test: prints "READY", echoes bytes, and replies:
    'h' or 'H' -> "hello"
    't' or 'T' -> prints millis()
  Wiring to Raspberry Pi:
    Pi TXD -> ATmega D0 (RX, pin 2)
    Pi RXD <- ATmega D1 (TX, pin 3)
    GND <-> GND
  Baud: 38400 (robust for internal RC).
*/
#ifndef F_CPU
#define F_CPU 8000000UL
#endif

void setup() {
  Serial.begin(38400);
  delay(50);              // settle after reset
  Serial.println(F("READY"));
}

void loop() {
  if (Serial.available()) {
    int c = Serial.read();
    switch (c) {
      case 'h': case 'H':
        Serial.println(F("hello"));
        break;
      case 't': case 'T':
        Serial.println(millis());
        break;
      default:
        Serial.write((uint8_t)c); // raw echo
    }
  }
}
