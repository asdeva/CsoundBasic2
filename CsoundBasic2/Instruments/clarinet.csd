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
iatt      =       0.1                                      ; attack time
idec      =       0.1                                      ; decay time
ibrite    tablei  7, 2                                     ; lowpass filter cutoff frequency
itablno   table   5, 3                                     ; select first wavetable number for this
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

f57 0 16384 -17 0 0 181 1 259 2 363 3 501 4 685 5                             ; clarinet wavetables
f58 0 64 -2 59 60 61 1.933 62 63 64 1.546 65 66 67 2.965 68 69 70 3.096 71 72 73 1.019 74 75 4 1.221
f59 0 4097 -9 3 0.389 0
f60 0 4097 -9 4 0.029 0 5 0.226 0 6 0.034 0 7 0.449 0
f61 0 4097 -9 8 0.168 0 9 0.480 0 10 0.089 0 11 0.099 0 12 0.040 0 13 0.061 0 14 0.031 0 15 0.079 0 16 0.040 0 17 0.062 0 18 0.063 0 20 0.026 0 21 0.022 0 22 0.044 0 24 0.034 0 26 0.020 0
f62 0 4097 -9 3 0.560 0
f63 0 4097 -9 4 0.035 0 5 0.304 0 6 0.122 0 7 0.397 0
f64 0 4097 -9 8 0.055 0 9 0.141 0 10 0.038 0 11 0.052 0 12 0.022 0 13 0.027 0 14 0.026 0 16 0.038 0 17 0.076 0 18 0.046 0 19 0.029 0
f65 0 4097 -9 2 0.061 0 3 0.628 0
f66 0 4097 -9 4 0.231 0 5 1.161 0 6 0.201 0 7 0.328 0
f67 0 4097 -9 8 0.154 0 9 0.072 0 10 0.186 0 11 0.133 0 12 0.309 0 13 0.071 0 14 0.098 0 15 0.114 0 16 0.027 0 17 0.057 0 18 0.022 0 19 0.042 0 20 0.023 0
f68 0 4097 -9 2 0.045 0 3 1.408 0
f69 0 4097 -9 4 0.842 0 5 0.574 0 6 0.124 0 7 0.158 0
f70 0 4097 -9 8 0.079 0 9 0.185 0 10 0.076 0 11 0.047 0 12 0.059 0 13 0.039 0 14 0.033 0
f71 0 4097 -9 2 0.206 0 3 0.302 0
f72 0 4097 -9 4 0.052 0 5 0.069 0 6 0.072 0 7 0.032 0
f73 0 4097 -9 8 0.031 0
f74 0 4097 -9 2 0.155 0 3 0.305 0
f75 0 4097 -9 4 0.322 0 5 0.048 0 6 0.061 0 7 0.025 0


;reverb--------------------------------------------------------------------------------
;p1    p2      p3     p4        p5        p6
;      start   dur    revtime   %reverb   gain
i194   0     360000    1       .05        1.0
;i2 0 360000
end
</CsScore>
</CsoundSynthesizer>
