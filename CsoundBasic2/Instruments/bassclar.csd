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


kvibd     =       abs(kvibr*kfreq/100.0)                   ; vibrato depth relative to fund. freq
iatt      =       0.05                                      ; attack time
idec      =       0.1                                      ; decay time
ibrite    tablei  9, 2                                     ; lowpass filter cutoff frequency
itablno   table   6, 3                                     ; select first wavetable number for this
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

f76 0 16384 -17 0 0 70 1 99 2 140 3 198 4                                     ; bassclar wavetables
f77 0 64 -2 78 79 80 5.293 81 82 83 3.726 84 85 86 4.229 87 88 89 1.620 90 91 92 1.347
f78 0 4097 -9 3 1.148 0
f79 0 4097 -9 4 0.027 0 5 1.620 0 6 0.023 0 7 0.545 0
f80 0 4097 -9 8 0.056 0 9 1.113 0 10 0.033 0 11 0.866 0 12 0.038 0 13 0.324 0 14 0.086 0 15 0.219 0 16 0.127 0 17 0.057 0 18 0.026 0 19 0.029 0 20 0.081 0 21 0.133 0 22 0.123 0 23 0.157 0 24 0.232 0 25 0.077 0 26 0.064 0 27 0.241 0 28 0.187 0 29 0.244 0 30 0.202 0 31 0.116 0 32 0.023 0 34 0.081 0 35 0.157 0 36 0.106 0 37 0.158 0 38 0.036 0 39 0.095 0 41 0.117 0 43 0.048 0 44 0.025 0
f81 0 4097 -9 2 0.024 0 3 0.985 0
f82 0 4097 -9 4 0.039 0 5 0.740 0 7 0.178 0
f83 0 4097 -9 9 0.093 0 10 0.050 0 11 0.285 0 12 0.083 0 13 0.317 0 14 0.137 0 15 0.400 0 16 0.047 0 17 0.476 0 18 0.128 0 19 0.370 0 20 0.054 0 21 0.093 0 22 0.083 0 23 0.110 0 24 0.030 0 25 0.061 0 26 0.056 0 27 0.113 0 28 0.225 0 29 0.050 0 30 0.091 0 31 0.022 0 32 0.034 0 34 0.055 0 35 0.039 0
f84 0 4097 -9 3 0.492 0
f85 0 4097 -9 5 0.730 0 6 0.061 0 7 0.678 0
f86 0 4097 -9 8 0.217 0 9 1.125 0 10 0.131 0 11 0.383 0 12 0.092 0 13 0.314 0 14 0.104 0 15 0.139 0 16 0.135 0 17 0.218 0 18 0.044 0 19 0.135 0 20 0.283 0 21 0.046 0 22 0.150 0 24 0.059 0 25 0.029 0 26 0.047 0 29 0.029 0 30 0.044 0 31 0.050 0 32 0.041 0
f87 0 4097 -9 3 0.084 0
f88 0 4097 -9 4 0.025 0 5 0.359 0 6 0.072 0 7 0.440 0
f89 0 4097 -9 9 0.271 0 10 0.087 0 11 0.095 0 12 0.079 0 13 0.061 0 14 0.093 0 15 0.058 0 16 0.045 0 18 0.026 0 19 0.027 0 22 0.023 0
f90 0 4097 -9 2 0.040 0 3 0.354 0
f91 0 4097 -9 5 0.178 0 6 0.058 0 7 0.294 0
f92 0 4097 -9 8 0.081 0 9 0.073 0 10 0.230 0 11 0.048 0 12 0.052 0 13 0.067 0 16 0.028 0

;reverb--------------------------------------------------------------------------------
;p1    p2      p3     p4        p5        p6
;      start   dur    revtime   %reverb   gain
i194   0     360000    1       .05        1.0
;i2 0 360000
end
</CsScore>
</CsoundSynthesizer>
