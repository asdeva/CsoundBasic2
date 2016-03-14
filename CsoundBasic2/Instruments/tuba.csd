<CsoundSynthesizer>
<CsOptions>
-o dac -+rtmidi=null -+rtaudio=null -d -+msg_color=0 -M0 -m0
</CsOptions>
<CsInstruments>

;______________________________________________________________________________________________________
; wind.orc - general wavetable wind instrument (in the woodwind and brass subdirectories on the CD-ROM)



sr        =       22050
kr        =       2205
ksmps     =       10
0dbfs     =       1
nchnls    =       2

giseed    =       .5
giwtsin   =       1
garev     init    0
;______________________________________________________________________________________________________
instr 1                                                    ; general wavetable wind instrument
; parameters
; p4 overall amplitude scaling factor
; p5 pitch in Hertz
; p6 percent vibrato depth, recommended values in range [0, 1]
;         0 = no vibrato, 1 = 1% vibrato depth
; p7 attack time in seconds, recommended values in range [.03, .1]
; p8 decay time in seconds, recommended values in range [.04, .2]
; p9 overall brightness / filter cutoff factor 
;         1 -> least bright / lowest filter cutoff frequency (40 Hz)
;         9 -> brightest / highest filter cutoff frequency (10,240Hz)
; p10 wind instrument number (1 = piccolo, 2 = flute, etc.)
;___________________________________________________________; initial variables 


i_instanceNum = p4
S_freq sprintf "freq.%d", i_instanceNum
S_vol  sprintf "vol.%d",  i_instanceNum
S_vib  sprintf "vib.%d",  i_instanceNum
ifreq chnget S_freq
kfreq chnget S_freq
kamp  chnget S_vol
kvibr chnget S_vib


kvibd     =       abs(kvibr*kfreq/100.0)                    ; vibrato depth relative to fund. freq
iatt      =       0.1                                      ; attack time
idec      =       0.1                                      ; decay time
ibrite    tablei  9, 2                                      ; lowpass filter cutoff frequency
itablno   table   18, 3                                     ; select first wavetable number for this
                                                            ; instrument (in table 3)

ivibr1    =       4.5 + giseed
giseed    =       frac(giseed*105.947)
iphase    =       giseed                                    ; use same phase for all wavetables
giseed    =       frac(giseed*105.947)
;___________________________________________________________; range-specific variables
irange    table   ifreq, itablno                            ; frequency range of current note
itabl2    =       itablno + 1
iwt1      =       1                                         ; wavetable numbers
iwt2      table   (irange*4),   itabl2
iwt3      table   (irange*4)+1, itabl2
iwt4      table   (irange*4)+2, itabl2
inorm     table   (irange*4)+3, itabl2                      ; normalization factor
;___________________________________________________________; vibrato block
kvibde    = linsegr(.1, .5, 1, .2, .7)                      ; vibrato envelope
kvibd     = kvibde * kvibd                                  ; vibrato depth
kvib      = oscil(kvibd, ivibr1, 1)
kfreq     = kfreq + kvib

;___________________________________________________________; amplitude envelopes
amp1      = linsegr(0, iatt, 1, idec, 0)
amp2      = amp1 * amp1
amp3      = amp2 * amp1
amp4      = amp3 * amp1
;___________________________________________________________; wavetable lookup
awt1      oscili  amp1, kfreq, iwt1, iphase		
awt2      oscili  amp2, kfreq, iwt2, iphase
awt3      oscili  amp3, kfreq, iwt3, iphase
awt4      oscili  amp4, kfreq, iwt4, iphase
asig      =       (awt1+awt2+awt3+awt4)*kamp/inorm
afilt     tone    asig, ibrite                              ; lowpass filter for brightness control
asig      balance afilt, asig
garev     =       garev + asig                              ; send signal to global reverberator
;         out     asig                                      ; DO NOT OUTPUT asig
          endin
;______________________________________________________________________________________________________
instr 194                                                   ; global reverberation instrument
; parameters
; p4 reverb time				
; p5 % of reverb relative to source signal
; p6 gain to control the final amplitude of the signal
idur      =       p3
irevtime  =       p4                                        ; set duration of reverb time
ireverb   =       p5                                        ; percent for reverberated signal
igain     =       p6                                        ; gain for the final signal amplitude
ireverb   =       (ireverb > .99 ? .99 : ireverb)           ; check limit
ireverb   =       (ireverb < 0 ? 0 : ireverb)               ; check limit
iacoustic =       1 - ireverb                               ; percent for acoustic signal
p3        =       p3 + irevtime + .1                        ; lengthen p3 to include reverb time	

ac1       comb    garev, irevtime, .0297
ac2       comb    garev, irevtime, .0371
ac3       comb    garev, irevtime, .0411
ac4       comb    garev, irevtime, .0437
acomb     =       ac1 + ac2 + ac3 + ac4
ap1       alpass  acomb, .09683, .005
arev      alpass  ap1, .03292, .0017
aout      =       (iacoustic * garev) + (ireverb * arev) * igain   ; mix the signal

          outs    aout, aout                                ; attenuate and output the signal
garev     =       0                                         ; set garev to 0 to prevent feedback
          endin



instr 2
kcutoff = 9000
kresonance = 0

a1 moogladder garev, kcutoff, kresonance

aL, aR reverbsc a1, a1, .5, 10000

outs aL, aR

garev = 0

endin





;______________________________________________________________________________________________________

</CsInstruments>
<CsScore>
; oboe.sco (in the woodwind subdirectory on the CD-ROM)
; Stravinsky - The Rite of Spring
; oboe solo near beginning

f1 0 8193 -9 1 1.000 0                                                        ; sine wave
f2 0 16 -2 40 40 80 160 320 640 1280 2560 5120 10240 10240                    ; filter cutoff table
f3 0 64 -2 0 11 22 29 42 57 76 93 111 131 152 171 191 211 239 258 275 297 311 ; instr wt# table
f4 0 5 -9 1 0.0 0                                                             ; zero-amp sine wave

f311 0 16384 -17 0 0 68 1 90 2 121 3 161 4 216 5                              ; tuba wavetables
f312 0 64 -2 313 314 315 13.556 316 317 318 13.193 319 320 321 2.961 322 323 324 2.392 325 326 4 2.348 327 328 4 1.266
f313 0 4097 -9 2 2.638 0 3 1.176 0
f314 0 4097 -9 4 3.122 0 5 1.523 0 6 2.396 0 7 1.547 0
f315 0 4097 -9 8 1.347 0 9 1.330 0 10 0.766 0 11 0.739 0 12 0.451 0 13 0.387 0 14 0.388 0 15 0.393 0 16 0.298 0 17 0.232 0 18 0.172 0 19 0.152 0 20 0.077 0 21 0.063 0 22 0.097 0 23 0.039 0
f316 0 4097 -9 2 3.183 0 3 3.822 0
f317 0 4097 -9 4 2.992 0 5 2.243 0 6 1.999 0 7 1.053 0
f318 0 4097 -9 8 0.742 0 9 0.501 0 10 0.377 0 11 0.369 0 12 0.288 0 13 0.288 0 14 0.216 0 15 0.130 0 16 0.105 0 17 0.069 0 18 0.021 0
f319 0 4097 -9 2 0.685 0 3 0.741 0
f320 0 4097 -9 4 0.791 0 5 0.395 0 6 0.327 0 7 0.175 0
f321 0 4097 -9 8 0.105 0 9 0.102 0 10 0.074 0 11 0.063 0 12 0.034 0
f322 0 4097 -9 2 0.329 0 3 0.939 0
f323 0 4097 -9 4 0.593 0 5 0.240 0 6 0.100 0 7 0.095 0
f324 0 4097 -9 8 0.082 0 9 0.028 0
f325 0 4097 -9 2 1.072 0 3 0.537 0
f326 0 4097 -9 4 0.351 0 5 0.185 0 6 0.054 0 7 0.024 0
f327 0 4097 -9 2 0.448 0 3 0.183 0
f328 0 4097 -9 4 0.087 0 5 0.028 0

;reverb--------------------------------------------------------------------------------
;p1    p2      p3     p4        p5        p6
;      start   dur    revtime   %reverb   gain
i194   0     360000    1       .05        1.0
;i2 0 360000
end
</CsScore>
</CsoundSynthesizer>
