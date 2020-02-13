---
layout: post
title: Getting Started with the Proxmark3 Easy
date: '2018-08-09 17:44:06'
tags:
- proxmark3
---

It took me several hours to get the Proxmark3 Easy up and running the first time. I had no idea what I was doing and couldn't find much information specific to the Proxmark3 Easy.

The one significant difference of the Proxmark3 Easy compared to the previous generations is that the Easy only has half the amount of storage in the microcontroller (256kb instead of 512kb). However, this will not matter if you are using the official Proxmark3 firmware.

![Picture of Proxmark3 Easy](/assets/media/Proxmark3_Easy.jpg)

The first thing you want to do when you get your new Proxmark3 Easy is to download the latest official Proxmark3 client and firmware. Here are some tutorials for common operating systems: [Windows](https://github.com/Proxmark/proxmark3/wiki/Windows), [Ubuntu](https://github.com/Proxmark/proxmark3/wiki/Ubuntu-Linux), [Kali](https://github.com/Proxmark/proxmark3/wiki/Kali-Linux), [Mac OS](https://github.com/Proxmark/proxmark3/wiki/MacOS), [Gentoo](https://github.com/Proxmark/proxmark3/wiki/Gentoo-Linux), and [Android](https://github.com/Proxmark/proxmark3/wiki/android).

When you are flashing your Proxmark3 Easy, make sure you flash both the bootloader and the main firmware. I tried flashing just the main firmware since I already had the newer CDC bootloader, but it caused the Proxmark3 to bootloop.

To flash the bootloader and firmware, you want to hold down the button on the side of the Proxmark3 when you plug it in. This will put the Proxmark3 into a flashable state. It should be obvious that it's in a different mode by the flashing of the LEDs on the Proxmark3 board.

You should always use the latest firmware and client, where possible. At the very least, you should always ensure that the client and the firmware running on the Proxmark3 are the same version.

Once you get it flashed, you can run the client using `client/proxmark3 /dev/ttyACM0` from the proxmark3 folder. You may need to substitute /dev/ttyACM0 with the appropriate TTY device.

To make sure everything works as expected, try `hw tune` to ensure both antennas are working and responding correctly:

```
proxmark3> hw tune

Measuring antenna characteristics, please wait.........
# LF antenna: 21.04 V @ 125.00 kHz
# LF antenna: 18.29 V @ 134.00 kHz
# LF optimal: 21.04 V @ 125.00 kHz
# HF antenna: 22.51 V @ 13.56 MHz
Displaying LF tuning graph. Divisor 89 is 134khz, 95 is 125khz.
```

Now try reading an RFID key using `hf search` if it is 13.56 MHz or `lf search` if it is 125kHz.
