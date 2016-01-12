<CsoundSynthesizer>
<CsOptions>
-o dac -+rtmidi=null -+rtaudio=null -d -+msg_color=0 -M0 -m0
</CsOptions>
<CsInstruments>
nchnls=2
0dbfs=1
ksmps=64
sr = 44100

instr 1
itie tival
i_instanceNum = p4
S_freq sprintf "freq.%d", i_instanceNum
S_vol sprintf "vol.%d", i_instanceNum
;S_vib sprintf "vib.%d", i_instanceNum
iHz chnget S_freq
kVol chnget S_vol
;kVib chnget S_vib

kenv     linsegr    0, .01, 1, .25, 0

a1      vco2    kVol * .5 * kenv, iHz, 0

a2      oscil   kVol * kenv, iHz, 1
outs    a1, a2
endin

instr 2
endin

</CsInstruments>
<CsScore>
f1  0   4096    10 1  ; use GEN10 to compute a sine wave
i2  0   360000
</CsScore>
</CsoundSynthesizer>
