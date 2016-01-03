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
    
    var notes: [PlainNote]!
    
    var hertz : Float = 220.0
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        csound = CsoundObj()
        
        instrument = BasicInstrument(csd: "csscript", csound: csound)
        view.multipleTouchEnabled = true
    }
    
    
    override func touchesBegan(touches: Set<UITouch>,
        withEvent event: UIEvent?)
    {
        if notes == nil {
            notes = [PlainNote]()
        }
        if var note = instrument.newNote() {
            note.volume = 0.5
            note.hertz = hertz
            hertz *= pow(pow(2, 1/2), 3)
            note.sounding = true
            notes.append(note)
        }
    }
}

