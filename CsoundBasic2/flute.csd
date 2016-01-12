<CsoundSynthesizer>
<CsOptions>
-o dac -+rtmidi=null -+rtaudio=null -d -+msg_color=0 -M0 -m0
</CsOptions>
<CsInstruments>
nchnls=2
0dbfs=1
ksmps=10
sr = 44100

; FLUTE INSTRUMENT BASED ON PERRY COOK'S SLIDE FLUTE


; SINE
git3 = ftgen(3, 0, 1024, 10, 1)

instr 1
itie tival
i_instanceNum = p4
S_freq sprintf "freq.%d", i_instanceNum
S_vol sprintf "vol.%d", i_instanceNum
iHz chnget S_freq
kHz chnget S_freq
kVol chnget S_vol

;iHz = 1 * 440
;kHz = 2 * 440
;kVol = 0.5
kVib = .1

aflute init 0

ipress    =  .97 ; TODO make it a function of kVol?
;ibreath   =  .036 ; blowing noise level
ibreath  =  .02

ifeedbk1  =  .4
ifeedbk2  =  .4

kenv1     = linsegr(0, .06, 1.1, .2, ipress, .25, 0)
kenv2     = linsegr(0, .01, 1, .15, 0)
kenvibr   = linsegr(0, .5,  1, .15, 0)

asum1     = ibreath * rand(kenv1) + kenv1 + oscil(kVib * kenvibr, 5, 3)
asum2     = asum1 + aflute * ifeedbk1

idelmax   = 1000 / iHz
adelbor   = idelmax - asum1/20 - 9000/sr + iHz/12000
adelemb   = adelbor / 2

ax        = vdelay3(asum2, adelemb, idelmax)
avalue    = tone(ax-ax^3 + aflute * ifeedbk2, 2000)
aflute    = vdelay3(avalue, adelbor, idelmax)
asig      = avalue * kVol * kenv2

outs(asig, asig)

endin



</CsInstruments>
<CsScore>
</CsScore>
</CsoundSynthesizer>
