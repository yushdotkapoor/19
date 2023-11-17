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
    var options: [Option]
    
    init(answerType: AnswerType, body: UIImage, question: String, options: [Option]) {
        if !options.contains(where: { $0.correct }) {
            fatalError("options must have at least one correct option")
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
    case selection
    
    var command: String {
        switch self {
        case .multipleChoice:
            return "Select ONLY ONE option:"
        case .shortAnswer:
            return "Write your response:"
        case .selection:
            return "Pick ONE OR MORE options:"
        }
    }
}

class Option {
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
