//
//  LandingScreen.swift
//  19
//
//  Created by Yush Raj Kapoor on 11/15/23.
//

import Foundation
import UIKit

class LandingScreen: UIViewController {
    
    @IBOutlet weak var tapToStart: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tapToStart.startPulse()
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(gesture:)))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        
    }
    
    @objc func viewTapped(gesture: UIGestureRecognizer) {
        tapToStart.stopPulse()
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(identifier: "Levels") as! Levels
        navigationController?.pushViewController(vc, animated: true)
    }
}
