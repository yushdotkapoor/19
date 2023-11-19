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
var levels: [Level] = [] {
    didSet {
        if levels.isEmpty { return }
        if let topViewController = UIApplication.topViewController() as? Levels {
            topViewController.layoutLevelStack()
        }
    }
}


func downloadLevels(forDate dt: Date) {
    levels = []
    ref.child("Levels").child(dt.toString(format: "yyyyMMdd")).getData { error, snapshot in
        if error != nil {
            print(error!)
        }
        
        guard let snapshot = snapshot, let value = snapshot.value as? NSArray else { return }
        var tempLevels: [Level] = []
        for lvl in value {
            let lvl = JSON(lvl)
            tempLevels.append(Level(dict: lvl, date: dt))
        }
        levels = tempLevels
        
        for lvl in levels {
            lvl.downloadImages()
        }
        
        updateCompletion(forDate: dt)
    }
}

func updateCompletion(forDate dt: Date) {
    ref.child("Users").child(auth.currentUser!.uid).child("levelCompletion").child(dt.toString(format: "yyyyMMdd")).getData { error, snapshot in
        if error != nil {
            print(error!)
        }
        
        guard let snapshot = snapshot, let value = snapshot.value as? NSArray else { return }
        let arr = JSON(value)
        for i in arr {
            guard let ind = Int(i.0), let completed = i.1.bool else { return }
            levels[ind].completed = completed
        }
        
        // This will casue the didSet function to be called
        levels = levels
    }
    
    ref.child("Users").child(auth.currentUser!.uid).child("setCompletion").getData { error, snapshot in
        if error != nil {
            print(error!)
        }
        
        guard let snapshot = snapshot, let value = snapshot.value as? NSArray else { return }
        let arr = JSON(value)
        if var setsCompleted = UserDefaults.standard.dictionary(forKey: "setsCompleted") as? [String: Bool] {
            for i in arr {
                guard let completed = i.1.bool else { return }
                setsCompleted[i.0] = completed
            }
            UserDefaults.standard.setValue(setsCompleted, forKey: "setsCompleted")
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


extension UIApplication {
    /**
     Recursively gets the top UIViewController.
     
     - Parameters:
     - base: The base ViewController, defaults as the root ViewController.
     
     - Returns: The sum of `a` and `b`.
     */
    class func topViewController(base: UIViewController? = UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
            
        } else if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
