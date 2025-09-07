# Bare ATmega328P @ 3.3 V, 8 MHz — Arduino + Atmel-ICE + Raspberry Pi UART (multi-node) Quickstart

This repo shows the *minimum-parts* way to run **ATmega328P** chips on a breadboard using the **internal 8 MHz RC** oscillator at **3.3 V**, program them with an **Atmel-ICE** *directly from the Arduino toolchain*, and talk to them from a **Raspberry Pi UART**. It includes a tiny serial echo sketch and a bash script to batch-flash multiple chips.

---

## Contents

```
sketches/
  serial_echo/
    serial_echo.ino     # "hello"/echo UART test sketch (38400 baud)

scripts/
  program_all.sh        # Compile once, burn fuses, upload to N chips
  pi_test.sh            # Convenience script to poke the UART from a Pi

README.md
LICENSE
.gitignore
```

---

## Hardware you need

* ATmega328P-PU (DIP-28) x N
* **Atmel-ICE** (AVR) and a 2×3 ISP cable
* Breadboard + jumper wires
* Power: **3.3 V** to VCC/AVCC, common **GND**
* (Strongly recommended) **0.1 µF** decoupler near VCC; tie **AVCC → VCC**; optional 0.1 µF on AREF→GND if using ADC
* Raspberry Pi with 40-pin header (for `/dev/serial0`) if you plan to test over UART

> **No external crystal/caps** required. We use the internal 8 MHz oscillator.

---

## Arduino CLI Setup (MiniCore)

```bash
arduino-cli config init
arduino-cli config set board_manager.additional_urls \
  https://mcudude.github.io/MiniCore/package_MCUdude_MiniCore_index.json

arduino-cli core update-index
arduino-cli core install MiniCore:avr
```

Board name:

```bash
FQBN='MiniCore:avr:328:clock=8MHz_internal,BOD=2v7,bootloader=no_bootloader'
```

Programmer:

```bash
PROG='atmel_ice'   # or 'atmelice_isp' depending on your system
```

---

## Wiring Setup

### USART and LED Connection

A Raspberry Pi is used as the UART device. Hookup guide:

| Component   | ATmega328P Pin | Pi / USB-UART |
| ----------- | -------------- | ------------- |
| TX          | PD1 (pin 3)    | Pi RX         |
| RX          | PD0 (pin 2)    | Pi TX         |
| GND         | GND (pin 8/22) | Pi GND        |

### ISP Programming Using Atmel-ICE

| Atmel-ICE AVR port pin | ATmega328P Pin      |
| ---------------------- | ------------------- |
| Pin 1 (TCK)            | Pin 19 (PB5 / SCK)  |
| Pin 2 (GND)            | Pin 8 (GND)         |
| Pin 3 (TDO)            | Pin 18 (PB4 / MISO) |
| Pin 4 (VTG)            | Pin 7 (VCC)         |
| Pin 6 (nSRST)          | Pin 1 (PC6 / RESET) |
| Pin 9 (TDI)            | Pin 17 (PB3 / MOSI) |

### ATmega328P Pinout

![ATmega328P Pinout Diagram](images/Atmega328P_Pinout.jpg)

---

## Quick start (Arduino CLI + Atmel-ICE)

```bash
arduino-cli burn-bootloader -b "$FQBN" -P "$PROG" --verbose
arduino-cli compile -b "$FQBN" sketches/serial_echo
arduino-cli upload -b "$FQBN" -P "$PROG" sketches/serial_echo
```

Swap chips and repeat the upload step as needed.

---

## Raspberry Pi UART Test

```bash
chmod +x scripts/pi_test.sh
scripts/pi_test.sh /dev/serial0
```

Expected device output on boot: `READY`

* Send `h` → replies `hello`
* Send `t` → prints millis()
* Any other byte → echoes back

---

## Power Considerations

* Power the ATmega328P at **3.3 V** if wiring directly to the Pi (safe levels).
* Tie **AVCC → VCC**, decouple with 0.1 µF.
* If you run at 5 V, you’ll need level shifting for Pi RX.