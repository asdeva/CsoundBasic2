<CsoundSynthesizer>
<CsOptions>
-o dac -+rtmidi=null -+rtaudio=null -d -+msg_color=0 -M0 -m0
</CsOptions>
<CsInstruments>
nchnls=2
0dbfs=1
ksmps=64
sr = 44100

ga1 init 0

instr 1
itie tival
i_instanceNum = p4
S_freq sprintf "freq.%d", i_instanceNum
S_vol sprintf "vol.%d", i_instanceNum

kHz chnget S_freq
kVol chnget S_vol


kenv linsegr 0, .01, 1, .1, 1, .25, 0
a1 vco2 kVol * .5 * kenv, kHz, 0

ga1 = ga1 + a1

endin

instr 2

;kcutoff chnget "cutoff"
;kresonance chnget "resonance"

kcutoff = 6000
kresonance = .2


a1 moogladder ga1, kcutoff, kresonance

aL, aR reverbsc a1, a1, .72, 5000

outs aL, aR

ga1 = 0

endin


</CsInstruments>
<CsScore>
f1 0 16384 10 1

i2 0 360000

</CsScore>
</CsoundSynthesizer>
