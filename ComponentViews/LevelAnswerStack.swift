//
//  LevelAnswerStack.swift
//  19
//
//  Created by Yush Raj Kapoor on 11/17/23.
//

import Foundation
import UIKit
import SwiftMath

class LevelAnswerStack: UIStackView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(delegate: Game) {
        let lvl = levels[delegate.level-1]
        
        let commandLabel = UILabel()
        commandLabel.numberOfLines = 0
        commandLabel.text = lvl.answerType.command
        
        insertArrangedSubview(commandLabel, at: 0)
        
        delegate.optionViews = []
        
        switch lvl.answerType {
        case .shortAnswer:
            let textBox = UITextField()
            textBox.placeholder = "Answer"
            textBox.layer.borderWidth = 2
            textBox.layer.cornerRadius = 20
            textBox.returnKeyType = .done
            textBox.autocorrectionType = .no
            textBox.smartInsertDeleteType = .no
            textBox.keyboardType = .numberPad
            textBox.delegate = delegate
            textBox.tag = 7
            textBox.setLeftPaddingPoints(10)
            textBox.setRightPaddingPoints(10)
            
            textBox.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            delegate.optionViews.append(textBox)
            
            insertArrangedSubview(textBox, at: 1)
        case .multipleChoice, .selection:
            var n = 0
            var hStack: UIStackView!
            var rows = 0
            
            for (i, _) in lvl.options.enumerated() {
                let outerButtonView = UIView()
                outerButtonView.layer.cornerRadius = 10
                outerButtonView.layer.borderWidth = 2
                outerButtonView.layer.borderColor = UIColor.link.cgColor
                let tap = UITapGestureRecognizer(target: delegate, action: #selector(delegate.handleMCTap(_:)))
                outerButtonView.addGestureRecognizer(tap)
                outerButtonView.isUserInteractionEnabled = true
                
                let buttonStack = UIStackView()
                buttonStack.distribution = .fillProportionally
                buttonStack.axis = .horizontal
                buttonStack.spacing = 5
                
                let letterLabel = UILabel()
                letterLabel.textColor = UIColor.link
                letterLabel.layer.borderColor = letterLabel.textColor.cgColor
                letterLabel.tag = 4
                letterLabel.widthAnchor.constraint(equalToConstant: 15).isActive = true
                
                buttonStack.addArrangedSubview(letterLabel)
                
                let choiceStack = UIStackView()
                choiceStack.axis = .vertical
                choiceStack.spacing = 5
                
                let buttonLabel = UILabel()
                buttonLabel.textColor = UIColor.link
                buttonLabel.numberOfLines = 0
                buttonLabel.tag = 5
                
                choiceStack.addArrangedSubview(buttonLabel)
                
                let latexLabel = MTMathUILabel()
                latexLabel.textColor = UIColor.link
                latexLabel.autoresizesSubviews = true
                latexLabel.tag = 8
                
                choiceStack.addArrangedSubview(latexLabel)
                
                let buttonImage = UIImageView()
                buttonImage.tag = 6
                
                choiceStack.addArrangedSubview(buttonImage)
                
                buttonStack.addArrangedSubview(choiceStack)
                
                delegate.optionViews.append(outerButtonView)
                
                buttonStack.translatesAutoresizingMaskIntoConstraints = false
                outerButtonView.addSubview(buttonStack)
                
                NSLayoutConstraint.activate([
                    buttonStack.leadingAnchor.constraint(equalTo: outerButtonView.leadingAnchor, constant: 5),
                    buttonStack.trailingAnchor.constraint(equalTo: outerButtonView.trailingAnchor, constant: -5),
                    buttonStack.topAnchor.constraint(equalTo: outerButtonView.topAnchor, constant: 5),
                    buttonStack.bottomAnchor.constraint(equalTo: outerButtonView.bottomAnchor, constant: -5),
                ])
                
                if n == 0 {
                    hStack = UIStackView()
                    hStack.axis = .horizontal
                    hStack.distribution = .fillEqually
                    hStack.spacing = 10
                    
                    insertArrangedSubview(hStack, at: rows + 1)
                    n += 1
                } else {
                    n = 0
                    rows += 1
                }
                
                hStack.addArrangedSubview(outerButtonView)
                
                if n == 1 && i == lvl.options.count - 1 {
                    let bufferView = UIView()
                    
                    hStack.addArrangedSubview(bufferView)
                }
                
                hStack.layoutSubviews()
            }
            
            
            for (i, optionView) in delegate.optionViews.enumerated() {
                let stackWidth = optionView.bounds.width - 30
                
                let option = lvl.options[i]
                if let letterLabel = optionView.findView(withTag: 4) as? UILabel {
                    letterLabel.text = String(Character(UnicodeScalar(i + 65)!))
                }
                if let buttonLabel = optionView.findView(withTag: 5) as? UILabel {
                    if let text = option.text {
                        buttonLabel.text = text
                    } else {
                        buttonLabel.isHidden = true
                    }
                }
                if let latexLabel = optionView.findView(withTag: 8) as? MTMathUILabel {
                    if let latex = option.latex {
                        latexLabel.labelMode = .text
                        latexLabel.latex = latex
                        latexLabel.fitWithin(width: stackWidth)
                    } else {
                        latexLabel.isHidden = true
                    }
                }
                if let buttonImage = optionView.findView(withTag: 6) as? UIImageView {
                    if let img = option.image {
                        buttonImage.image = img.aspectFittedToWidth(stackWidth)
                    } else {
                        buttonImage.isHidden = true
                    }
                }
                optionView.tag = 10 + i
            }
        }
    }
    
    
}


extension MTMathUILabel {
    func fitWithin(width: CGFloat) {
        while intrinsicContentSize.width > width {
            fontSize -= 0.1
        }
    }
}
