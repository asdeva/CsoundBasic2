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
iHz chnget S_freq
kVol chnget S_vol

asig = oscil(kVol * .5 * linsegr:k(0, .2, 1, .1, 1, .1, 0), iHz)
outs asig,asig
endin


</CsInstruments>
<CsScore>
</CsScore>
</CsoundSynthesizer>
