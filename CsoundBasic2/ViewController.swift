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
    
    var extendedNotes : [BasicInstrument.BasicNote] = []
    
    var buttonToNote : [UIButton: BasicInstrument.BasicNote] = [:]
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        csound = CsoundObj()
        
        instrument = BasicInstrument(csd: "flute", csound: csound)
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
            if legato && nu.sounding {
                extendedNotes.append(nu)
            } else {
                nu.sounding = false
            }
        }
    }
    
    
    @IBAction func noteKeyPressed(sender: UIButton) {
        if let nd = buttonToNote[sender] {
            if let ne = extendedNotes.first where legato {
                extendedNotes.removeFirst()
                if ne !== nd {
                    NSTimer.schedule(delay: 0.15) {_ in
                        ne.sounding = false
                    }
                    nd.volume = 0.5
                    nd.sounding = true
                } else {
                    ne.sounding = false
                }
                
            } else {
                nd.volume = 0.5
                nd.sounding = true
            }
        }
    }
    
    
    
    @IBOutlet var KbdFirstRow: UIStackView!
    
    @IBOutlet var Keyboard: UIStackView!
}

