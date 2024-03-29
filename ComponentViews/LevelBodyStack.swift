//
//  LevelBodyStack.swift
//  19
//
//  Created by Yush Raj Kapoor on 11/17/23.
//

import Foundation
import UIKit
import SwiftMath

class LevelBodyStack: UIStackView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(delegate: Game) {
        let lvl = levels[delegate.level-1]
        for question in lvl.questions {
            switch question {
            case .latex(let string):
                let questionLabel = MTMathUILabel()
                questionLabel.latex = string
                questionLabel.fontSize = 20.0
                questionLabel.fitWithin(width: bounds.width)
                
                addArrangedSubview(questionLabel)
            case .text(let string):
                let questionLabel = UILabel()
                questionLabel.text = string
                questionLabel.numberOfLines = 0
                questionLabel.font = questionLabel.font.withSize(20)
                
                addArrangedSubview(questionLabel)
            case .image(_):
                if let image = question.img {
                    let questionImage = UIImageView()
                    questionImage.image = image.aspectFittedToWidth(bounds.width)
                    
                    addArrangedSubview(questionImage)
                }
            }
        }
    }
}
