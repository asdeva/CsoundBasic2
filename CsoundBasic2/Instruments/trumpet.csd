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
idec      =       0.08                                      ; decay time
ibrite    tablei  9, 2                                      ; lowpass filter cutoff frequency
itablno   table   10, 3                                     ; select first wavetable number for this
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

f152 0 16384 -17 0 0 255 1 340 2 457 3 615 4 828 5                            ; trumpet wavetables
f153 0 64 -2 154 155 156 22.202 157 158 159 12.789 160 161 162 5.982 163 164 165 3.638 166 167 168 2.430 169 170 4 1.788
f154 0 4097 -9 2 1.473 0 3 2.461 0
f155 0 4097 -9 4 3.101 0 5 3.579 0 6 4.874 0 7 2.769 0
f156 0 4097 -10 0 0 0 0 0 0 0 2.396 1.557 1.489 1.324 1.162 0.679 0.558 0.461 0.225 0.178 0.105 0.069 0.064 0.053 0.049 0.036
f157 0 4097 -9 2 1.428 0 3 2.825 0
f158 0 4097 -9 4 2.654 0 5 2.688 0 6 1.464 0 7 1.520 0
f159 0 4097 -10 0 0 0 0 0 0 0 1.122 0.940 0.738 0.495 0.362 0.237 0.154 0.154 0.101 0.082 0.054 0.038 0.036
f160 0 4097 -9 2 0.693 0 3 1.606 0
f161 0 4097 -9 4 1.591 0 5 1.056 0 6 0.867 0 7 0.501 0
f162 0 4097 -10 0 0 0 0 0 0 0 0.370 0.159 0.111 0.105 0.054 0.041 0.027 0.024 0.013
f163 0 4097 -9 2 1.167 0 3 1.178 0
f164 0 4097 -9 4 0.611 0 5 0.591 0 6 0.344 0 7 0.139 0
f165 0 4097 -10 0 0 0 0 0 0 0 0.090 0.057 0.035 0.029 0.022 0.020 0.014
f166 0 4097 -9 2 0.972 0 3 0.710 0
f167 0 4097 -9 4 0.389 0 5 0.200 0 6 0.112 0 7 0.065 0
f168 0 4097 -9 8 0.032 0 9 0.026 0
f169 0 4097 -9 2 0.900 0 3 0.262 0
f170 0 4097 -9 4 0.069 0

;reverb--------------------------------------------------------------------------------
;p1    p2      p3     p4        p5        p6
;      start   dur    revtime   %reverb   gain
i194   0     360000    1       .05        1.0
;i2 0 360000
end
</CsScore>
</CsoundSynthesizer>
