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
iatt      =       0.03                                      ; attack time
idec      =       0.05                                      ; decay time
ibrite    tablei  9, 2                                      ; lowpass filter cutoff frequency
itablno   table   13, 3                                     ; select first wavetable number for this
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

f1 0 8193 -9 1 1.000 0                                                        ; sine wave
f2 0 16 -2 40 40 80 160 320 640 1280 2560 5120 10240 10240                    ; filter cutoff table
f3 0 64 -2 0 11 22 29 42 57 76 93 111 131 152 171 191 211 239 258 275 297 311 ; instr wt# table
f4 0 5 -9 1 0.0 0                                                             ; zero-amp sine wave

f211 0 16384 -17 0 0 49 1 78 2 114 3 152 4 203 5 272 6 363 7 484 8            ; trombone wavetables
f212 0 64 -2 213 214 215 1097.095 216 217 218 333.625 219 220 221 52.730 222 223 224 44.207 225 226 227 16.212 228 229 230 11.992 231 232 233 10.655 234 235 236 2.527 237 238 4 1.441
f213 0 4097 -9 2 6.250 0 3 9.625 0
f214 0 4097 -9 4 15.625 0 5 16.500 0 6 19.875 0 7 18.125 0
f215 0 4097 -10 0 0 0 0 0 0 0 16.875 46.500 48.000 66.125 74.375 47.125 44.500 32.625 45.000 54.750 56.500 47.875 47.500 36.625 39.750 44.500 37.875 33.875 32.625 23.875 29.125 29.500 28.125 29.625 22.250 24.750 38.125 36.625 30.375 23.125 19.625 18.750 16.750 19.750 15.875 14.250 13.875 12.000 13.000 11.125 13.000 9.875 9.750 9.000 8.875 9.000 7.125 7.875 7.625 6.500 5.375 6.000 6.000 4.250 4.625 4.625 4.375 3.750 4.000 3.875 3.125 3.250 3.500 3.125 3.000 2.875 3.125 2.625 2.750 2.500 2.750 2.750 2.125 1.625 1.750 2.125 1.875 1.875 1.875 1.625 1.500 1.500 1.500 1.375 1.375 1.250 1.250
f216 0 4097 -9 2 2.483 0 3 3.763 0
f217 0 4097 -9 4 6.934 0 5 8.465 0 6 10.877 0 7 12.769 0
f218 0 4097 -10 0 0 0 0 0 0 0 24.484 11.435 22.587 22.086 22.754 26.312 19.037 18.337 19.727 15.371 16.113 10.108 11.592 14.140 14.021 12.964 17.916 16.845 17.381 10.054 7.988 7.321 5.230 4.326 4.511 3.824 3.549 3.398 3.250 2.375 1.952 2.044 1.147 1.710 0.725 0.694 0.712 0.343 0.667 0.334 0.172 0.174 0.198 0.284 0.419 0.504 0.506 0.581 0.538 0.626 0.699 0.780 0.698 0.941 0.818 0.754 0.771 0.820 0.929 0.861 0.854 0.910 0.932 0.769 0.921 0.818 0.966 0.924 0.848 0.867 0.782 0.770 0.809 0.737 0.799 0.682 0.651 0.630 0.657 0.608 0.635 0.573 0.547 0.596 0.545 0.499
f219 0 4097 -9 2 2.288 0 3 3.627 0
f220 0 4097 -9 4 3.741 0 5 6.847 0 6 4.659 0 7 6.059 0
f221 0 4097 -10 0 0 0 0 0 0 0 5.318 4.141 4.906 3.447 2.506 3.988 2.800 4.306 2.447 2.200 1.376 1.541 1.647 1.035 1.106 0.765 0.682 0.718 0.553 0.435 0.459 0.259 0.282 0.141 0.224 0.188 0.188 0.141 0.153 0.106  0.099 0.082 0.072 0.059 0.074 0.048 0.042 0.041 0.038 0 0.026 0.027 0 0.021 0.021
f222 0 4097 -9 2 2.336 0 3 3.832 0
f223 0 4097 -9 4 5.788 0 5 4.676 0 6 5.923 0 7 5.964 0
f224 0 4097 -10 0 0 0 0 0 0 0 4.695 2.915 3.063 4.612 3.124 2.738 2.422 1.780 1.378 1.392 1.441 0.867 0.811 0.646 0.554 0.337 0.437 0.385 0.303 0.287 0.236 0.149 0.166 0.148 0.126 0.095 0.099 0.082 0.072 0.059 0.074 0.048 0.042 0.041 0.038 0 0.026 0.027 0 0.021 0.021
f225 0 4097 -9 2 2.109 0 3 3.239 0
f226 0 4097 -9 4 2.557 0 5 3.340 0 6 1.898 0 7 1.943 0
f227 0 4097 -10 0 0 0 0 0 0 0 1.743 1.664 1.013 0.708 0.691 0.628 0.412 0.371 0.292 0.262 0.249 0.196 0.150 0.134 0.124 0.097 0.075 0.071 0.061 0.059 0.047 0.044 0.040 0.031 0.027 0.025 0.021
f228 0 4097 -9 2 1.701 0 3 2.444 0
f229 0 4097 -9 4 2.824 0 5 1.432 0 6 1.976 0 7 1.645 0
f230 0 4097 -10 0 0 0 0 0 0 0 1.270 0.745 0.567 0.533 0.346 0.184 0.201 0.153 0.108 0.097 0.086 0.075 0.059 0.048 0.043 0.038 0.030
f231 0 4097 -9 2 1.978 0 3 4.767 0
f232 0 4097 -9 4 2.309 0 5 1.417 0 6 1.233 0 7 0.801 0
f233 0 4097 -10 0 0 0 0 0 0 0 0.493 0.382 0.301 0.178 0.163 0.151 0.095 0.074 0.062 0.041 0.035 0.033 0.026
f234 0 4097 -9 2 1.020 0 3 0.700 0
f235 0 4097 -9 4 0.441 0 5 0.292 0 6 0.240 0 7 0.139 0
f236 0 4097 -10 0 0 0 0 0 0 0 0.087 0.084 0.062 0.045 0.032 0.030 0.025
f237 0 4097 -9 2 0.567 0 3 0.251 0
f238 0 4097 -9 4 0.108 0 5 0.030 0

;reverb--------------------------------------------------------------------------------
;p1    p2      p3     p4        p5        p6
;      start   dur    revtime   %reverb   gain
i194   0     360000    1       .05        1.0
;i2 0 360000
end
</CsScore>
</CsoundSynthesizer>
