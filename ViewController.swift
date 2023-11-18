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
        welcome.alpha = 0
        // Do any additional setup after loading the view.
        if auth.currentUser == nil {
            let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(identifier: "Login") as! Login
            vc.source = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        welcomeSequence()
    }
    
    func welcomeSequence() {
        guard let user = auth.currentUser else { return }
        if let name = user.displayName {
            welcome.text = "Welcome, \(name)"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.welcome.fadeIn()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.welcome.fadeOut()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(identifier: "Levels") as! Levels
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}

