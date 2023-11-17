//
//  ViewController.swift
//  19
//
//  Created by Yush Raj Kapoor on 11/15/23.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var welcome: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        welcome.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.welcome.fadeIn()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.welcome.fadeOut()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.performSegue(withIdentifier: "landing", sender: self)
                }
            }
        }
    }

}


extension UIView {
    
    func fadeIn(duration: Double = 1.0) {
        UIView.animate(withDuration: duration) {
            self.alpha = 1.0
        }
    }
    
    func fadeOut(duration: Double = 1.0) {
        UIView.animate(withDuration: duration) {
            self.alpha = 0.0
        }
    }
    
    func startPulse() {
        if !isUserInteractionEnabled {
            UIView.animate(withDuration: 0.5, animations: {
                self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            }, completion: {_ in
                UIView.animate(withDuration: 0.85, delay: 0.05, animations: {
                    self.transform = CGAffineTransform(scaleX: 1/1.15, y: 1/1.15)
                }, completion: {_ in
                    self.startPulse()
                })
            })
        }
    }
    
    func stopPulse() {
        isUserInteractionEnabled = true
    }
}
