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
itablno   table   7, 3                                     ; select first wavetable number for this
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

f93 0 16384 -17 0 0 86 1 129 2 194 3 291 4 436 5                              ; bassoon wavetables
f94 0 64 -2 95 96 97 11.900 98 99 100 18.823 101 102 103 18.635 104 105 106 5.404 107 108 109 5.624 110 111 4 2.081
f95 0 4097 -9 2 1.339 0 3 1.324 0
f96 0 4097 -9 4 1.567 0 5 1.602 0 6 1.777 0 7 1.143 0
f97 0 4097 -9 8 0.746 0 9 1.231 0 10 1.618 0 11 0.823 0 12 0.572 0 13 0.282 0 14 0.421 0 15 0.419 0 16 0.470 0 17 0.126 0 18 0.722 0 19 0.609 0 20 0.402 0 21 0.273 0 22 0.272 0 23 0.351 0 24 0.152 0 25 0.087 0 26 0.067 0 27 0.189 0 28 0.172 0 29 0.227 0 30 0.152 0 31 0.114 0 32 0.060 0 33 0.059 0 34 0.069 0 35 0.084 0 36 0.073 0 37 0.054 0 38 0.025 0 39 0.038 0 40 0.070 0 41 0.064 0 42 0.055 0 43 0.032 0 44 0.027 0 45 0.051 0 46 0.034 0 47 0.041 0 48 0.056 0 49 0.026 0 53 0.024 0
f98 0 4097 -9 2 1.348 0 3 2.896 0
f99 0 4097 -9 4 4.100 0 5 6.159 0 6 3.342 0 7 0.109 0
f100 0 4097 -9 8 1.577 0 9 0.756 0 10 0.745 0 11 0.781 0 12 1.175 0 13 1.204 0 14 0.572 0 15 1.003 0 16 0.430 0 17 0.166 0 18 0.488 0 19 0.212 0 20 0.142 0 21 0.077 0 22 0.047 0 23 0.059 0 24 0.094 0 25 0.048 0 26 0.041 0 27 0.035 0 28 0.022 0 29 0.062 0 30 0.167 0 31 0.200 0 32 0.100 0 33 0.037 0 34 0.023 0 36 0.061 0 37 0.030 0 38 0.100 0 39 0.125 0 40 0.098 0 41 0.053 0 42 0.073 0 43 0.073 0 44 0.063 0 45 0.046 0 47 0.030 0 48 0.042 0
f101 0 4097 -9 2 6.037 0 3 6.737 0
f102 0 4097 -9 4 6.752 0 5 1.300 0 6 0.536 0 7 0.339 0
f103 0 4097 -9 8 1.719 0 9 1.347 0 10 0.866 0 11 0.753 0 12 0.238 0 13 0.346 0 14 0.169 0 15 0.190 0 16 0.063 0 17 0.084 0 18 0.258 0 19 0.181 0 20 0.076 0 21 0.069 0 22 0.087 0 23 0.085 0 24 0.116 0 25 0.107 0 26 0.195 0 27 0.096 0 28 0.086 0 29 0.093 0 30 0.036 0 31 0.074 0 32 0.052 0 33 0.052 0 34 0.040 0 35 0.046 0 36 0.039 0
f104 0 4097 -9 2 3.912 0 3 1.245 0
f105 0 4097 -9 4 0.301 0 5 0.537 0 6 0.827 0 7 0.161 0
f106 0 4097 -9 8 0.258 0 9 0.205 0 10 0.129 0 11 0.060 0 12 0.080 0 13 0.131 0 14 0.094 0 15 0.054 0 16 0.057 0 17 0.061 0 18 0.054 0 19 0.026 0 20 0.021 0 21 0.024 0 22 0.024 0
f107 0 4097 -9 2 4.071 0 3 1.026 0
f108 0 4097 -9 4 0.618 0 5 0.186 0 6 0.153 0 7 0.026 0
f109 0 4097 -9 8 0.056 0 9 0.070 0 10 0.040 0 11 0.026 0 12 0.026 0
f110 0 4097 -9 2 0.759 0 3 0.568 0
f111 0 4097 -9 4 0.374 0 5 0.052 0

;reverb--------------------------------------------------------------------------------
;p1    p2      p3     p4        p5        p6
;      start   dur    revtime   %reverb   gain
i194   0     360000    1       .05        1.0
;i2 0 360000
end
</CsScore>
</CsoundSynthesizer>
