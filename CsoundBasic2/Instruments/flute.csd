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
idec      =       0.05                                      ; decay time
ibrite    tablei  5, 2                                     ; lowpass filter cutoff frequency
itablno   table   2, 3                                     ; select first wavetable number for this
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

f22 0 16384 -17 0 0 611 1 1050 2                                              ; flute wavetables
f23 0 64 -2 24 25 4 1.026 26 27 4 0.953 28 4 4 0.992
f24 0 4097 -9 2 0.260 0 3 0.118 0
f25 0 4097 -9 4 0.085 0 5 0.017 0 6 0.014 0
f26 0 4097 -9 2 0.090 0 3 0.078 0
f27 0 4097 -9 4 0.010 0 5 0.013 0
f28 0 4097 -9 2 0.029 0 3 0.011 0

;reverb--------------------------------------------------------------------------------
;p1    p2      p3     p4        p5        p6
;      start   dur    revtime   %reverb   gain
i194   0     360000    1       .05        1.0
;i2 0 360000
end
</CsScore>
</CsoundSynthesizer>
