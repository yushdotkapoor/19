//
//  LevelTransitonView.swift
//  19
//
//  Created by Yush Raj Kapoor on 11/18/23.
//

import Foundation
import UIKit

class LevelTransitonView: UIView {
    
    var delegate: Game?
    
    var secondLevelLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = lbl.font.withSize(200)
        lbl.textAlignment = .right
        lbl.alpha = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    var firstLevelLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = lbl.font.withSize(200)
        lbl.textAlignment = .left
        lbl.alpha = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    init(delegate: Game) {
        super.init(frame: CGRect())
        self.delegate = delegate
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupView() {
        guard let delegate = delegate else { return }
        
        backgroundColor = .systemBackground
        alpha = 0
        
        firstLevelLabel.text = String(delegate.level)
        
        addSubview(firstLevelLabel)
        
        secondLevelLabel.text = String(delegate.level + 1)
        
        addSubview(secondLevelLabel)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            firstLevelLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
            firstLevelLabel.topAnchor.constraint(equalTo: topAnchor, constant: 50),
            secondLevelLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
            secondLevelLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
        ])
    }
    
    func beginAnimation() {
        guard let delegate = delegate else { return }
        let timeConstant:Double = 0.5
        let timeConstant2:Double = 0.7
        
        UIView.animate(withDuration: timeConstant) {
            self.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: timeConstant) {
                self.firstLevelLabel.alpha = 1
            } completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + timeConstant2) {
                    UIView.animate(withDuration: timeConstant) {
                        self.secondLevelLabel.alpha = 1
                    } completion: { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + timeConstant2) {
                            UIView.animate(withDuration: timeConstant) {
                                self.firstLevelLabel.alpha = 0
                            } completion: { _ in
                                DispatchQueue.main.asyncAfter(deadline: .now() + timeConstant2) {
                                    delegate.clearView()
                                    delegate.level += 1
                                    delegate.initializeLevel()
                                    UIView.animate(withDuration: timeConstant) {
                                        self.alpha = 0
                                    } completion: { _ in
                                        self.removeFromSuperview()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
}
