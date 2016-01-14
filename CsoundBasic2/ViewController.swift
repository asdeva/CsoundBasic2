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
    
    var noteA: PlainNote!

    var noteB: PlainNote!
    
    var noteC: PlainNote!
    
    var hertzA : (Float, Int) = (220.0, 0)
    
    var hertzB : (Float, Int) = (220.0, -12)
    
    var hertzC : (Float, Int) = (220.0, 7)
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        csound = CsoundObj()
        
        instrument = BasicInstrument(csd: "flute", csound: csound)
        view.multipleTouchEnabled = true
    }
    
    
    @IBAction func A(sender: UISwitch) {
        if noteA == nil {
            if var note = instrument.newNote() {
                note.volume = 0.5
                note.hertz = hertzA
                note.vibrato = 0
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
                note.vibrato = 0
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
                note.vibrato = 0
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
    
    
    
    @IBAction func vibra(sender: UISlider) {
        let vibrato = sender.value / 20.0
        print("vibrato:", vibrato)
        if noteA != nil {
            noteA.vibrato = vibrato
        }
        if noteB != nil {
            noteB.vibrato = vibrato
        }
        if noteC != nil {
            noteC.vibrato = vibrato
        }
    }
    
}

