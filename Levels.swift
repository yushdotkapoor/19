//
//  Levels.swift
//  19
//
//  Created by Yush Raj Kapoor on 11/15/23.
//

import Foundation
import UIKit
import SwiftyJSON

var targetDate: Date = Date.now

class Levels: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setViewControllers([self], animated: false)
        
        updateButtonStates()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        for button in getButton() {
            enableButton(button: button)
        }
        
        dateLabel.textColor = setCompleted(forDate: targetDate) ? UIColor.systemGreen : .label
        
        dateLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleDateTap(_:)))
        dateLabel.addGestureRecognizer(tap)
    }
    
    func enableButton(button: UIButton, bypass: Bool=false) {
        var prev = true
        let lvl = button.tag - 1
        if lvl - 1 >= 0 {
            prev = levels[lvl - 1].completed
        }
        let curr = levels[lvl].completed
        var next = false
        if lvl + 1 < levels.count {
            next = levels[lvl + 1].completed
        }
        button.isEnabled = true
        if curr || bypass {
            button.setTitleColor(UIColor.systemGreen, for: .normal)
        } else if prev && !next {
            button.setTitleColor(UIColor.link, for: .normal)
        } else {
            button.isEnabled = false
            button.setTitleColor(UIColor.tertiaryLabel, for: .normal)
        }
        button.layer.borderColor = button.titleLabel?.textColor.cgColor
    }
    
    func buttonTapped(tag: Int) {
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
    
    func layoutLevelStack() {
        for i in stackView.arrangedSubviews {
            i.removeFromSuperview()
        }
        
        var bypass = false
        if setCompleted(forDate: targetDate) {
            dateLabel.textColor = .systemGreen
            bypass = true
        } else {
            dateLabel.textColor = .label
        }
        
        if levels.isEmpty { return }
        
        for i in 1...levels.count {
            let button = UIButton()
            button.setTitle("Level \(i)", for: .normal)
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            button.tag = i
            enableButton(button: button, bypass: bypass)
            
            button.layer.cornerRadius = 20
            button.layer.borderWidth = 2
            
            button.addAction(UIAction(handler: { _ in
                self.buttonTapped(tag: i)
            }), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        
        stackView.layoutSubviews()
    }
    
    func updateButtonStates() {
        let startTime = UserDefaults.standard.double(forKey: "startDate")
        let startDate = Date(timeIntervalSince1970: startTime)
        let endTime = UserDefaults.standard.double(forKey: "endDate")
        let endDate = Date(timeIntervalSince1970: endTime)
        DispatchQueue.main.async { [self] in
            dateLabel.text = targetDate.toString(format: "MMMM d, yyyy")
            
            leftButton.isEnabled = targetDate.daysSince1970() - startDate.daysSince1970() > 0
            rightButton.isEnabled = Date.now.daysSince1970() - targetDate.daysSince1970() > 0 && targetDate.daysSince1970() - endDate.daysSince1970() < 0
            
            layoutLevelStack()
        }
    }
    
    @IBAction func rightButtonPressed(_ sender: Any) {
        targetDate = Calendar.current.date(byAdding: .day, value: 1, to: targetDate)!
        downloadLevels(forDate: targetDate)
        updateButtonStates()
    }
    
    @IBAction func leftButtonPressed(_ sender: Any) {
        targetDate = Calendar.current.date(byAdding: .day, value: -1, to: targetDate)!
        downloadLevels(forDate: targetDate)
        updateButtonStates()
    }
    
    @objc func handleDateTap(_ sender: UITapGestureRecognizer? = nil) {
        let calendarPopupVC = CalendarViewController()
        calendarPopupVC.delegate = self
        
        if let presentationController = calendarPopupVC.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium()]
        }
        
        calendarPopupVC.modalPresentationStyle = .pageSheet
        self.present(calendarPopupVC, animated: true, completion: nil)
    }
    
}


