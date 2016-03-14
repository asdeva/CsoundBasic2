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
iatt      =       0.09                                      ; attack time
idec      =       0.09                                      ; decay time
ibrite    tablei  9, 2                                      ; lowpass filter cutoff frequency
itablno   table   9, 3                                     ; select first wavetable number for this
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

f131 0 16384 -17 0 0 77 1 138 2 215 3 308 4 555 5 924 6                       ; sax wavetables
f132 0 64 -2 133 134 135 19.611 136 137 138 7.641 139 140 141 3.196 142 143 144 3.229 145 146 147 1.020 148 149 4 1.044 150 151 4 0.979
f133 0 4097 -9 2 3.615 0 3 2.627 0
f134 0 4097 -9 4 2.292 0 5 1.164 0 6 3.599 0 7 5.725 0
f135 0 4097 -9 8 2.803 0 9 0.581 0 10 0.318 0 11 0.139 0 12 0.654 0 13 0.640 0 14 0.445 0 15 0.605 0 16 0.547 0 17 0.483 0 18 0.222 0 19 0.175 0 20 0.053 0 21 0.165 0 22 0.118 0 23 0.215 0 24 0.150 0 25 0.502 0 26 0.362 0 27 0.472 0 28 0.366 0 29 0.448 0 30 0.608 0 31 0.319 0 32 0.311 0 33 0.316 0 34 0.264 0 35 0.098 0 36 0.233 0 37 0.170 0 38 0.060 0 39 0.206 0 40 0.102 0 41 0.122 0 42 0.043 0 43 0.040 0 46 0.023 0 48 0.022 0 50 0.028 0 51 0.030 0 53 0.035 0 54 0.050 0 57 0.031 0 60 0.024 0 63 0.028 0 69 0.023 0 71 0.025 0
f136 0 4097 -9 2 0.651 0 3 0.478 0
f137 0 4097 -9 4 2.867 0 5 2.561 0 6 0.330 0 7 0.210 0
f138 0 4097 -9 8 0.570 0 9 0.560 0 10 0.428 0 11 0.353 0 12 0.114 0 13 0.092 0 14 0.222 0 15 0.375 0 16 0.484 0 17 0.359 0 18 0.306 0 19 0.243 0 20 0.184 0 21 0.181 0 22 0.189 0 23 0.171 0 24 0.164 0 25 0.103 0 26 0.114 0 27 0.067 0 28 0.055 0 31 0.021 0 38 0.026 0
f139 0 4097 -9 2 1.053 0 3 0.410 0
f140 0 4097 -9 4 0.257 0 5 0.340 0 6 0.199 0 7 0.265 0
f141 0 4097 -9 8 0.396 0 9 0.244 0 10 0.281 0 11 0.405 0 12 0.196 0 13 0.240 0 14 0.131 0 15 0.065 0 16 0.027 0 17 0.039 0 18 0.036 0 19 0.038 0 20 0.049 0 21 0.034 0 22 0.043 0 23 0.045 0 24 0.055 0 25 0.062 0 26 0.048 0 27 0.030 0
f142 0 4097 -9 2 0.266 0 3 0.461 0
f143 0 4097 -9 4 0.203 0 5 0.556 0 6 0.307 0 7 0.358 0
f144 0 4097 -9 8 0.389 0 9 0.612 0 10 0.252 0 11 0.207 0 12 0.053 0 13 0.042 0 14 0.032 0 15 0.061 0 16 0.086 0 17 0.121 0 18 0.132 0 19 0.095 0 20 0.079 0 21 0.042 0 22 0.031 0 23 0.022 0
f145 0 4097 -9 2 0.099 0 3 0.376 0
f146 0 4097 -9 4 0.095 0 5 0.040 0 6 0.094 0 7 0.097 0
f147 0 4097 -9 8 0.045 0 9 0.027 0
f148 0 4097 -9 2 0.041 0 3 0.158 0
f149 0 4097 -9 4 0.227 0 5 0.072 0
f150 0 4097 -9 2 0.168 0 3 0.144 0
f151 0 4097 -9 4 0.096 0

;reverb--------------------------------------------------------------------------------
;p1    p2      p3     p4        p5        p6
;      start   dur    revtime   %reverb   gain
i194   0     360000    1       .05        1.0
;i2 0 360000
end
</CsScore>
</CsoundSynthesizer>
