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
    
    let baseNote:  Float = 110.0
    
    var legato = true
    
    var lastUp: UIButton? = nil
    
    typealias BasicNote = BasicInstrument.BasicNote
    
    var extendedNotes : [BasicNote] = []
    
    var buttonToNote : [UIButton: BasicNote] = [:]
    
    var numNotesOn = 0
    
    let melody = [5,5,8,5,5,8,5,8,13,12,10,10,8,3,5,6,3,3,5,6,3,6,12,10,8,12,13,
    1,1,13,10,6,8,5,1,6,8,10,8,1,1,13,10,6,8,5,1,6,8,6,5,3,1]
    
    var i = 0
    
    var offset = 12
    
    var playBack = true
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        csound = CsoundObj()
        
        //instrument = BasicInstrument(csd: "flute", csound: csound)
        instrument = BasicInstrument(csd: "oboe1", csound: csound)
        //instrument = BasicInstrument(csd: "oboe2", csound: csound)
        //instrument = BasicInstrument(csd: "csscript", csound: csound)
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
                    NSTimer.schedule(delay: 0.01) {_ in
                        ne.sounding = false
                        --self.numNotesOn
                    }
                    nd.volume = 0.5
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
                nd.volume = 0.3
                if playBack {
                    nd.hertz = (baseNote, offset + melody[i])
                    i = (i+1) % melody.count
                }
                nd.sounding = true
                ++numNotesOn
            }
        }
    }
    
    
    
    @IBOutlet var KbdFirstRow: UIStackView!
    
    @IBOutlet var Keyboard: UIStackView!
}

