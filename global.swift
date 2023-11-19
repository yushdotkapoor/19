//
//  global.swift
//  19
//
//  Created by Yush Raj Kapoor on 11/18/23.
//

import Foundation
import Firebase
import SwiftyJSON

var ref = Database.database().reference()
let auth = Auth.auth()
var levels: [Level] = []


func downloadLevels(forDate dt: Date) {
    levels = []
    ref.child("Levels").child(dt.toString(format: "yyyyMMdd")).getData { error, snapshot in
        if error != nil {
            print(error!)
        }
        
        guard let snapshot = snapshot, let value = snapshot.value as? NSArray else { return }
        for lvl in value {
            let lvl = JSON(lvl)
            levels.append(Level(dict: lvl))
        }
        
        for lvl in levels {
            lvl.downloadImages()
        }
        
        updateCompletion(forDate: dt)
    }
}

func updateCompletion(forDate dt: Date) {
    ref.child("Users").child(auth.currentUser!.uid).child("completion").child(dt.toString(format: "yyyyMMdd")).getData { error, snapshot in
        if error != nil {
            print(error!)
        }
        
        guard let snapshot = snapshot, let value = snapshot.value as? NSArray else { return }
        let arr = JSON(value)
        for i in arr {
            guard let ind = Int(i.0), let completed = i.1.bool else { return }
            levels[ind].completed = completed
        }
        
    }
}

func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.impactOccurred()
}

func impact(style: UINotificationFeedbackGenerator.FeedbackType) {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(style)
}

func existsOnFile(name: String) -> Bool {
    if let _ = retrievePath(name: name) {
        return true
    }
    return false
}

func retrievePath(name: String) -> String? {
    let fileManager = FileManager.default
    let directoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let path = (directoryPath as NSString).appendingPathComponent(name)
    if fileManager.fileExists(atPath: path) {
        return path
    }
    print("File \(name) does not exist")
    return nil
}

