//
//  Levels.swift
//  19
//
//  Created by Yush Raj Kapoor on 11/15/23.
//

import Foundation
import UIKit

class Levels: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    
    let numLevels = levels.count
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 1...numLevels {
            let button = UIButton()
            button.setTitle("Level \(i)", for: .normal)
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            button.tag = i
            enableButton(button: button)
            
            button.layer.cornerRadius = 20
            button.layer.borderWidth = 2
            button.layer.borderColor = button.titleLabel?.textColor.cgColor
            
            button.addAction(UIAction(handler: { _ in
                self.buttonTapped(tag: i)
           }), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        stackView.layoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        for button in getButton() {
            enableButton(button: button)
        }
    }
    
    func enableButton(button: UIButton) {
        let prev = UserDefaults.standard.bool(forKey: "Level \(button.tag - 1)")
        let curr = UserDefaults.standard.bool(forKey: "Level \(button.tag)")
        let next = UserDefaults.standard.bool(forKey: "Level \(button.tag + 1)")
        button.isHidden = false
        if curr {
            button.setTitleColor(UIColor.green, for: .normal)
        } else if prev && !next {
            button.setTitleColor(UIColor.link, for: .normal)
        } else {
            button.isHidden = true
        }
    }
    
    func buttonTapped(tag: Int) {
        print(tag)
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(identifier: "Game") as! Game
        vc.level = tag
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func getButton(level: Int=0) -> [UIButton] {
        var buttons: [UIButton] = []
        for i in stackView.subviews {
            if let button = i as? UIButton {
                if i.tag == level {
                    return [button]
                }
                buttons.append(button)
            }
        }
        
        return buttons
    }
    
}
