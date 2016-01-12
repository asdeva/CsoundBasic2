<CsoundSynthesizer>
<CsOptions>
-o dac -+rtmidi=null -+rtaudio=null -d -+msg_color=0 -M0 -m0
</CsOptions>
<CsInstruments>
nchnls=2
0dbfs=1
ksmps=10
sr = 44100

git1 = ftgen(1, 0, 256, 7, 1, 80, 1, 156, -1, 40, -1)
git3 = ftgen(3, 0, 1024, 10, 1)


instr 1
itie tival
i_instanceNum = p4
S_freq sprintf "freq.%d", i_instanceNum
S_vol sprintf "vol.%d", i_instanceNum
iHz chnget S_freq
kHz chnget S_freq
kVol chnget S_vol

;iHz = 2 * 440
;kVol = 0.5

areedbell init  0
ifqc      =          iHz
;ifco     =          1000
ifco      =          1000
ibore     =          1/ifqc-15/sr

kenv1     linsegr    0, .0001, 1, .05, 0
kenvibr   linseg     0, .1, 0, .9, 1, 0


; SUPPOSEDLY HAS SOMETHING TO DO WITH REED STIFFNESS?
kemboff = .4

; BREATH PRESSURE
apressm = kenv1 + oscil(.1 * kenvibr, 5, 3)

; REFLECTION FILTER FROM THE BELL IS LOWPASS
arefilt = tone(areedbell, ifco)

; THE DELAY FROM BELL TO REED
abellreed delay     arefilt, ibore

; BACK PRESSURE AND REED TABLE LOOK UP
asum2     =         - apressm - .95 * arefilt - kemboff
areedtab  tablei    asum2/4 + .34, 1, 1, .5
amult1    =         asum2 * areedtab

; FORWARD PRESSURE
asum1     =         apressm + amult1

areedbell delay     asum1, ibore

aofilt = atone(areedbell, ifco)

asig      =         aofilt * kVol

outs(asig, asig)

endin



</CsInstruments>
<CsScore>
</CsScore>
</CsoundSynthesizer>
