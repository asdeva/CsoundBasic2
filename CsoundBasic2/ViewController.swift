//
//  ViewController.swift
//  AudioKitExample
//
//  Created by Carlos Millan on 5/2/15.
//  Copyright (c) 2015 Carlos Millan. All rights reserved.
//

import UIKit



class ViewController: UIViewController
{
        
    var csound: CsoundObj!
    
    var instrument: BasicInstrument!
    
    let baseNote:  Float = 50.0
    
    var legato = false
    
    var volume: Float = 0.3
    
    var vibrato: Float = 0.5
    
    var lastUp: UIButton? = nil
    
    typealias BasicNote = BasicInstrument.BasicNote
    
    var extendedNotes : [BasicNote] = []
    
    var buttonToNote : [UIButton: BasicNote] = [:]
    
    var numNotesOn = 0
    
    //let melody = [5,5,8,5,5,8,5,8,13,12,10,10,8,3,5,6,3,3,5,6,3,6,12,10,8,12,13,
    //1,1,13,10,6,8,5,1,6,8,10,8,1,1,13,10,6,8,5,1,6,8,6,5,3,1]
    
    //let melody = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24]
    
    let melody = [5,10,5,10,13,10,13,17,13,18,17,13,10,12,9,13,12,9,5,10,5,13,12,
        5,10,5,10,13,10,13,17,13,18,17,13,10,12,9,13,12,9,5,10,5,9,10]
  
    
    var i = 0
    
    var offset = 0
    
    var playBack = true
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        csound = CsoundObj()
        
        //instrument = BasicInstrument(csd: "flute", csound: csound)
        //instrument = BasicInstrument(csd: "piccolo", csound: csound)
        //instrument = BasicInstrument(csd: "oboe", csound: csound)
        //instrument = BasicInstrument(csd: "csscript", csound: csound)
        //instrument = BasicInstrument(csd: "sax", csound: csound)
        //instrument = BasicInstrument(csd: "horn", csound: csound)
        //instrument = BasicInstrument(csd: "trumpet", csound: csound)
        //instrument = BasicInstrument(csd: "trombone", csound: csound)
        //instrument = BasicInstrument(csd: "tuba", csound: csound)
        //instrument = BasicInstrument(csd: "clarinet", csound: csound)
        //instrument = BasicInstrument(csd: "enghorn", csound: csound)
        //instrument = BasicInstrument(csd: "bassoon", csound: csound)
        instrument = BasicInstrument(csd: "cbassoon", csound: csound)
        //instrument = BasicInstrument(csd: "bassclar", csound: csound)
        assignNoteToButton()
        view.multipleTouchEnabled = true
    }
    
    func assignNoteToButton() {
        var row: Int = 0
        var col: Int = 0
        for view in Keyboard.subviews {
            col = 0
            for k in view.subviews {
                if let k = k as? UIButton {
                    let offset = col + Int(row%2 != 0) * 7 + (row/2)*12
                    if let n = instrument.newNote() as?
                        BasicInstrument.BasicNote {
                        buttonToNote[k] = n
                        buttonToNote[k]?.hertz = (baseNote, offset)
                    }
                }
                ++col
            }
            ++row
        }
    }
    
    
    
    @IBAction func touchUp(sender: UIButton) {
        if let nu = buttonToNote[sender] {
            if legato && nu.sounding  {
                extendedNotes.append(nu)
            } else if numNotesOn > 0 {
                nu.sounding = false
                --numNotesOn
            }
        }
    }
    
    
    @IBAction func noteKeyPressed(sender: UIButton) {
        if var nd = buttonToNote[sender] {
            if let ne = extendedNotes.first where legato {
                extendedNotes.removeFirst()
                if ne !== nd {
                    NSTimer.schedule(delay: 0.03) {_ in
                        ne.sounding = false
                        --self.numNotesOn
                    }
                    nd.volume = volume
                    nd.vibrato = vibrato
                    if playBack {
                        nd.hertz = (baseNote, offset + melody[i])
                        i = (i+1) % melody.count
                    }
                    nd.sounding = true
                    ++numNotesOn
                } else {
                    ne.sounding = false
                    --numNotesOn
                }
            } else {
                nd.volume = volume
                nd.vibrato = vibrato
                if playBack {
                    nd.hertz = (baseNote, offset + melody[i])
                    i = (i+1) % melody.count
                }
                nd.sounding = true
                ++numNotesOn
            }
        }
    }
    
    
    
    @IBAction func volumeCtl(sender: UISlider) {
        volume = sender.value/3
        for (_, note) in buttonToNote {
            note.volume = volume
        }
    }
    
    @IBAction func vibratoCtl(sender: UISlider) {
        vibrato = sender.value
        for (_, note) in buttonToNote {
            note.vibrato = vibrato
        }
    }
    
    @IBOutlet var KbdFirstRow: UIStackView!
    
    @IBOutlet var Keyboard: UIStackView!
}

