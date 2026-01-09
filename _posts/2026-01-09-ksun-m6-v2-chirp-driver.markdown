---
layout: post
title: "Developing a CHIRP Driver for the KSUN M6 V2 Radio"
tags:
- radio
- ham-radio
- chirp
- python
- reverse-engineering
---

I recently completed development of a CHIRP driver for the KSUN M6 V2 UHF handheld transceiver. This project involved reverse-engineering the radio's serial protocol, documenting the memory structure, and creating a fully-functional driver for the popular [CHIRP radio programming software](https://chirp.danplanet.com).

The complete driver, protocol documentation, and memory map specifications are available on GitHub: [ksun-m6-v2-chirp-driver](https://github.com/b4ndit/ksun-m6-v2-chirp-driver)

## Background

The KSUN M6 V2 is a compact UHF handheld radio operating in the 400-480 MHz range with 200 memory channels. While KSUN provides Windows-only programming software, there was no support for cross-platform tools like CHIRP. This meant Linux and macOS users were unable to program these radios.

The "V2" designation refers to a 2024+ hardware revision that uses a completely different serial protocol from the original M6. The new revision can be identified by the display text showing "CH001" instead of "CH-01" on the radio. The differences are significant:

| Feature | Original M6 | M6 V2 |
|---------|-------------|-------|
| Baud Rate | 4,800 | 38,400 |
| Block Size | 16 bytes | 128 bytes |
| Checksum Base | 2 | 86 |
| Channels | 80 | 200 |
| Start Address | 0x0050 | 0x0300 |

This meant the existing M6 driver couldn't be used and required creating an entirely new driver from scratch.

## Reverse Engineering the Protocol

The reverse engineering process involved several approaches:

### 1. Serial Port Monitoring

I used serial port sniffing tools to capture communication between the manufacturer's software and the radio. This revealed:

- The radio uses a custom binary protocol (not AT commands)
- Commands are 4 bytes with a checksum appended
- Block reads return 132 bytes (3-byte echo + 128 data bytes + 1 checksum)
- The radio requires multiple connection attempts (reliability issue)

### 2. Memory Dump Analysis

By comparing multiple memory dumps with known radio configurations, I was able to map out the memory structure:

```
0x0000-0x00FF: Configuration (256 bytes)
  - Radio settings (squelch, volume, backlight, etc.)
  - DES-encrypted password protection
  - Menu customization

0x0100-0x19FF: Channel Data (6400 bytes)
  - 200 channels × 32 bytes per channel
  - RX/TX frequencies (10 Hz precision)
  - CTCSS/DCS tones
  - Power, bandwidth, scan settings
```

### 3. Decompiling the Manufacturer's Software

Using .NET decompilers, I analyzed the manufacturer's C# application to understand:

- Checksum algorithm (base 86 instead of the typical base 2)
- Frequency encoding (stored in 10 Hz units as little-endian 32-bit integers)
- Tone encoding (16-bit values with polarity bits)
- The acceptable integer ranges for different features

## Driver Features

The completed driver supports:

**Memory Channels (200)**
- RX/TX frequencies with 10 Hz precision
- Channel names (5 characters)
- CTCSS/DCS tones (separate RX/TX)
- Power level (High 2.0W / Low 0.5W)
- Bandwidth (Wide 25kHz / Narrow 12.5kHz)
- Scan add/skip
- Scrambler, compander, busy lock
- Encryption settings

**Radio Settings**
- Startup text and channel
- Language (Chinese Simplified/Traditional, English)
- Beep, squelch, volume
- Backlight brightness and timeout
- VOX with threshold and delay
- Battery save modes
- Key lock with auto-lock
- Time-out timer (TOT)
- Frequency band limits
- Channel limit (1-200)
- And more...

## Documentation

The project includes comprehensive technical documentation:

- **[PROTOCOL_ANALYSIS.md](https://github.com/b4ndit/ksun-m6-v2-chirp-driver/blob/main/PROTOCOL_ANALYSIS.md)** - Complete serial protocol specification including command set, checksum algorithm, and communication sequences
- **[MEMORY_MAP.md](https://github.com/b4ndit/ksun-m6-v2-chirp-driver/blob/main/MEMORY_MAP.md)** - Detailed memory structure, field encoding, and data format specifications

These documents serve both as developer references and educational resources for anyone interested in radio programming protocols.

## Credits

This driver was developed using the CHIRP framework and builds upon the excellent work of the CHIRP development community. Special thanks to:

- Dan Smith and the CHIRP Project team
- Yuri D'Elia for the original KSUN M6 driver (which provided structural guidance)
- The CHIRP developer documentation and coding standards

## Conclusion

Developing this CHIRP driver was a rewarding exercise in reverse engineering, protocol analysis, and Python development. If you own a KSUN M6 V2 radio and want cross-platform programming support, give this driver a try!

The complete source code, documentation, and installation instructions are available at: [https://github.com/b4ndit/ksun-m6-v2-chirp-driver](https://github.com/b4ndit/ksun-m6-v2-chirp-driver)

Questions, bug reports, and contributions are welcome!

---

**License:** The driver is released under GNU GPL v3 to maintain compatibility with the CHIRP project.
