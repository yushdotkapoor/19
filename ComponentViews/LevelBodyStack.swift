//
//  LevelBodyStack.swift
//  19
//
//  Created by Yush Raj Kapoor on 11/17/23.
//

import Foundation
import UIKit

class LevelBodyStack: UIStackView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(source: Game) {
        let lvl = levels[source.level-1]
        let questionLabel = UILabel()
        questionLabel.text = lvl.question
        questionLabel.numberOfLines = 0
        questionLabel.font = questionLabel.font.withSize(20)
        
        addArrangedSubview(questionLabel)
        
        let questionImage = UIImageView()
        questionImage.image = lvl.body.aspectFittedToWidth(bounds.width)
        
        addArrangedSubview(questionImage)
    }
    
    
}
