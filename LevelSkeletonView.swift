//
//  LevelSkeletonView.swift
//  19
//
//  Created by Yush Raj Kapoor on 11/17/23.
//

import Foundation
import UIKit

class LevelSkeletonView: UIScrollView {
    
    var source: Game?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(source: Game) {
        super.init(frame: CGRect())
        self.source = source
        setupView()
    }
    
    func setupView() {
        layer.masksToBounds = false
        
        let mainStack = UIStackView()
        mainStack.spacing = 10
        mainStack.axis = .vertical
        
        let levelLabel = UILabel()
        levelLabel.tag = 1
        levelLabel.font = levelLabel.font.withSize(50)
        levelLabel.textAlignment = .center
        
        mainStack.addArrangedSubview(levelLabel)
        
        let bodyStack = UIStackView()
        bodyStack.tag = 2
        bodyStack.spacing = 10
        bodyStack.axis = .vertical
        
        mainStack.addArrangedSubview(bodyStack)
        
        let bufferView = UIView()
        
        mainStack.addArrangedSubview(bufferView)
        
        let answerStack = UIStackView()
        answerStack.tag = 3
        answerStack.spacing = 10
        answerStack.axis = .vertical
        
        let submitButton = UIButton()
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(UIColor.link, for: .normal)
        submitButton.layer.cornerRadius = 20
        submitButton.layer.borderWidth = 2
        submitButton.layer.borderColor = submitButton.titleLabel?.textColor.cgColor
        submitButton.addAction(UIAction(handler: { _ in
            self.source!.submitPressed()
        }), for: .touchUpInside)
        
        answerStack.addArrangedSubview(submitButton)
        
        mainStack.addArrangedSubview(answerStack)
        
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            mainStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
    }
    
    
    
}
