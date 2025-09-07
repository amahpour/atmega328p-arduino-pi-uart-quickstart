# Bare ATmega328P @ 3.3V, 8 MHz — Arduino + Atmel‑ICE + Raspberry Pi UART (multi-node) Quickstart

This repo shows the *minimum‑parts* way to run **ATmega328P** chips on a breadboard using the **internal 8 MHz RC** oscillator at **3.3 V**, program them with an **Atmel‑ICE** *directly from the Arduino toolchain*, and talk to them from a **Raspberry Pi UART**. It includes a tiny serial echo sketch and a bash script to batch‑flash multiple chips.

> Why this setup?  
> • No crystal/caps, no level shifter (Pi is 3.3 V).  
> • Correct fuses/BOD in one click.  
> • Quiet startup (no bootloader chatter).  
> • Arduino code and libraries still “just work” compiled for `F_CPU=8 MHz`.

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
- ATmega328P‑P U (DIP‑28) x N
- **Atmel‑ICE** (AVR) and a 2×3 ISP cable
- Breadboard + jumper wires
- Power: **3.3 V** to VCC/AVCC, common **GND**
- (Strongly recommended) **0.1 µF** decoupler near VCC; tie **AVCC → VCC**; optional 0.1 µF on AREF→GND if using ADC
- Raspberry Pi with 40‑pin header (for `/dev/serial0`) if you plan to test over UART

> **No external crystal/caps** required. We use the internal 8 MHz oscillator.

---

## Software you need
- **Arduino CLI** (or Arduino IDE)
- **MiniCore** Arduino core for ATmega328 (installs via Arduino CLI in the script)

---

## Quick start (Arduino CLI + Atmel‑ICE)

> If your Atmel‑ICE programmer ID is different on your OS, set `PROG=...` when calling the script (see “Programmer selection” below).

1) **Connect Atmel‑ICE ISP** to the chip on a breadboard:  
   - RESET ↔ pin 1  
   - VCC ↔ pin 7 (and also power **AVCC** pin 20)  
   - GND ↔ pins 8/22  
   - MOSI ↔ pin 17 (PB3)  
   - MISO ↔ pin 18 (PB4)  
   - SCK  ↔ pin 19 (PB5)

2) **Batch‑flash** (defaults to 3 chips, change with `-n`):  
   ```bash
   cd atmega328p-arduino-pi-uart-quickstart
   chmod +x scripts/program_all.sh
   scripts/program_all.sh -n 3
   ```

What the script does:
- Installs **MCUdude:avr (MiniCore)**
- Sets fuses for **8 MHz internal RC** + **BOD 2.7 V** (`Burn Bootloader` step)
- Compiles `sketches/serial_echo`
- Uploads the sketch **N** times; after each upload, swap the chip and hit Enter

### Programmer selection
By default the script uses `PROG=atmel_ice`. To list available programmer IDs for your platform:
```bash
arduino-cli board details -b MCUdude:avr:ATmega328 | sed -n '/Programmers:/,/^$/p'
```
Override at runtime:
```bash
PROG=atmelice_isp scripts/program_all.sh -n 3
```

---

## Wiring for Raspberry Pi UART test
Use 3.3 V power and a common ground. Cross the UART lines:

- **Pi TXD (GPIO14, header pin 8)** → **ATmega D0 / RX (pin 2)**
- **Pi RXD (GPIO15, header pin 10)** ← **ATmega D1 / TX (pin 3)**
- **GND ↔ GND**

Enable the Pi’s UART (`/boot/config.txt` or `raspi-config`). Then run the included test:

```bash
chmod +x scripts/pi_test.sh
scripts/pi_test.sh /dev/serial0
# In another terminal, try keys: h, t, or type text and press Enter to see echoes.
```

Expected device output on boot: `READY`  
- Send `h` → replies `hello`  
- Send `t` → prints the current `millis()`  
- Any other byte → echoes back

> **Baud:** 38400 (robust with the internal RC clock). If you see framing errors at higher baud, stay at 38400–57600 or calibrate `OSCCAL`.

---

## Notes & troubleshooting
- If uploads fail, verify your **ISP wiring** and that **RESET** is not tied low.  
- Do **not** set the `RSTDISBL` fuse unless you have a high‑voltage programmer.  
- If you want serial uploads later, you can burn **Optiboot @ 8 MHz** with MiniCore and add a way to pulse **RESET** (manual button or small DTR cap). This repo defaults to **no bootloader** for instant, quiet startup.

---

## License
MIT — see `LICENSE`.
