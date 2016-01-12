//
//  ViewController.swift
//  AudioKitExample
//
//  Created by Carlos Millan on 5/2/15.
//  Copyright (c) 2015 Carlos Millan. All rights reserved.
//

import UIKit


extension PlainNote {
    var hertz: (Float, Int) {
        get {
            return (hertz, 0)
        }
        set {
            hertz = newValue.0 * Float(pow(2, Float(newValue.1)/Float(12.0)))
            print(hertz)
        }
    }
}

class ViewController: UIViewController
{
    
    var csound: CsoundObj!
    
    var instrument: BasicInstrument!
    
    var noteA: PlainNote!

    var noteB: PlainNote!
    
    var noteC: PlainNote!
    
    var hertzA : (Float, Int) = (220.0, 0)
    
    var hertzB : (Float, Int) = (220.0, 4)
    
    var hertzC : (Float, Int) = (220.0, 7)
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        csound = CsoundObj()
        
        instrument = BasicInstrument(csd: "flute", csound: csound)
        //instrument = BasicInstrument(csd: "test3", csound: csound)
        //instrument = BasicInstrument(csd: "test2", csound: csound)
        //instrument = BasicInstrument(csd: "test", csound: csound)
        //instrument = BasicInstrument(csd: "csscript", csound: csound)
        view.multipleTouchEnabled = true
    }
    
    
    @IBAction func A(sender: UISwitch) {
        if noteA == nil {
            if var note = instrument.newNote() {
                note.volume = 0.5
                note.hertz = hertzA
                noteA = note
            }
        }
        if noteA != nil {
            noteA.sounding = sender.on
        }
        print(noteA.hertz.0)
    }
    
    
    @IBAction func ASlider(sender: UISlider) {
        if noteA != nil {
            noteA.volume = sender.value
        }
    }
    
    @IBAction func B(sender: UISwitch) {
        if noteB == nil {
            if var note = instrument.newNote() {
                note.volume = 0.5
                note.hertz = hertzB
                noteB = note
            }
        }
        if noteB != nil {
            noteB.sounding = sender.on
        }
        print(noteB.hertz.0)
        
    }
    
    @IBAction func BSlider(sender: UISlider) {
        if noteB != nil {
            noteB.volume = sender.value
        }
    }
    
    @IBAction func C(sender: UISwitch) {
        if noteC == nil {
            if var note = instrument.newNote() {
                note.volume = 0.5
                note.hertz = hertzC
                noteC = note
            }
        }
        if noteC != nil {
            noteC.sounding = sender.on
        }
        print(noteC.hertz.0)
    }
    
    @IBAction func CSlider(sender: UISlider) {
        if noteC != nil {
            noteC.volume = sender.value
        }
    }
    
    
}

