//
//  Level.swift
//  19
//
//  Created by Yush Raj Kapoor on 11/16/23.
//

import Foundation
import UIKit

class Level {
    var answerType: AnswerType
    var body: UIImage
    var question: String
    var options: [MCOption]?
    
    init(answerType: AnswerType, body: UIImage, question: String, options: [MCOption]? = nil) {
        if options == nil && answerType == .multipleChoice {
            fatalError("Multiple Choice Answer must have Level options")
        } else if options != nil && !options!.contains(where: { $0.correct }) {
            fatalError("Multiple Choice Answer must have at least one correct option")
        }
        
        self.answerType = answerType
        self.body = body
        self.question = question
        self.options = options
    }
    
}

enum AnswerType {
    case multipleChoice
    case shortAnswer
}

class MCOption {
    var text: String?
    var image: UIImage?
    var correct: Bool
    var id: String
    
    init(text: String?, image: UIImage?, correct: Bool=false) {
        self.text = text
        self.image = image
        self.correct = correct
        self.id = UUID().uuidString
    }
}

