//
//  Level.swift
//  19
//
//  Created by Yush Raj Kapoor on 11/16/23.
//

import Foundation
import UIKit
import SwiftyJSON

class Level {
    var answerType: AnswerType
    var questions: [Question]
    var options: [Option]
    var completed: Bool
    var date: Date
    
    init(answerType: AnswerType, questions: [Question], options: [Option], date: Date) {
        let correctOptions = options.filter({ $0.correct })
        if correctOptions.isEmpty {
            fatalError("options must have at least one correct option")
        } else if correctOptions.count > 1 && (answerType == .multipleChoice || answerType == .shortAnswer) {
            fatalError("options must have only one correct option for multiple choice or short answer")
        }
        
        self.answerType = answerType
        self.questions = questions
        self.options = options
        self.completed = false
        self.date = date
    }
    
    convenience init(dict: JSON, date: Date) {
        var questions: [Question] = []
        for questionDict in dict["question"].array! {
            questions.append(Question.fromDict(dict: questionDict, date: date))
        }
        
        var options: [Option] = []
        for optionDict in dict["options"].array! {
            options.append(Option(dict: optionDict, date: date))
        }
        
        var imageName = dict["bodyImage"].string
        if let i = imageName, i.isEmpty {
            imageName = nil
        }
        
        self.init(answerType: AnswerType.fromString(string: dict["answerType"].string!), questions: questions, options: options, date: date)
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
        
        static func fromString(string: String) -> AnswerType {
            if string == "mc" {
                return AnswerType.multipleChoice
            } else if string == "sa" {
                return AnswerType.shortAnswer
            } else if string == "se" {
                return AnswerType.selection
            }
            return AnswerType.shortAnswer
        }
    }
    
    func downloadImages() {
        var downloadQueue = UserDefaults.standard.array(forKey: "downloadQueue") as? [String] ?? []
        var allImageNames: [String] = []
        
        for question in questions {
            switch question {
            case .image(let imageName, _):
                allImageNames.append(imageName)
            default:
                break
            }
        }
        
        for option in self.options {
            if let imgName = option.imageName {
                allImageNames.append(imgName)
            }
        }
        
        let requiresDownloading = Set(allImageNames.filter({ !existsOnFile(name: self.dateString + $0) })).subtracting(Set(downloadQueue))
        requiresDownloading.forEach({ downloadQueue.append($0) })
        UserDefaults.standard.setValue(downloadQueue, forKey: "downloadQueue")
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        for imgName in downloadQueue {
            let fileURL = documentsDirectory.appendingPathComponent(self.dateString + imgName)
            StorageManager.shared.downloadURL(for: "\(self.dateString)/\(imgName)") { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let url):
                    print("download url \(url)")
                    var currentlyDownloading = UserDefaults.standard.array(forKey: "currentlyDownloading") as? [String] ?? []
                    guard !currentlyDownloading.contains(imgName) else { return }
                    currentlyDownloading.append(imgName)
                    UserDefaults.standard.setValue(currentlyDownloading, forKey: "currentlyDownloading")
                    
                    DispatchQueue.global(qos: .utility).async {
                        do {
                            let data = try Data(contentsOf: url)
                            if !FileManager.default.fileExists(atPath: fileURL.path()) {
                                try data.write(to: fileURL, options: .atomic)
                            }
                            
                            currentlyDownloading = UserDefaults.standard.array(forKey: "currentlyDownloading") as? [String] ?? []
                            currentlyDownloading.removeAll(where: { $0 == imgName })
                            UserDefaults.standard.setValue(currentlyDownloading, forKey: "currentlyDownloading")
                            
                            var dq = UserDefaults.standard.array(forKey: "downloadQueue") as? [String] ?? []
                            dq.removeAll(where: { $0 == imgName })
                            UserDefaults.standard.setValue(dq, forKey: "downloadQueue")
                            
                            print("\(imgName) saved @ \(fileURL)")
                        } catch {
                            print("Error when attempting to download data \(error.localizedDescription)")
                            return
                        }
                    }
                    
                    
                }
            }
        }
    }
    
    var dateString: String {
        return self.date.toString(format: "yyyyMMdd")
    }
}

enum Question {
    case latex(string: String)
    case text(string: String)
    case image(imageName: String, date: Date)
    
    static func fromDict(dict: JSON, date: Date) -> Question {
        guard let type = dict["type"].string, let string = dict["string"].string else { return Question.text(string: "") }
        if type == "l" {
            return Question.latex(string: string)
        } else if type == "t" {
            return Question.text(string: string)
        } else if type == "i" {
            return Question.image(imageName: string, date: date)
        }
        return Question.text(string: "")
    }
    
    var img: UIImage? {
        switch self {
        case .image(let imageName, let date):
            guard let path = retrievePath(name: date.toString(format: "yyyyMMdd") + imageName) else { return nil }
            return UIImage(contentsOfFile: path)
        default:
            return nil
        }
    }
}


class Option {
    var text: String?
    var latex: String?
    var imageName: String?
    var correct: Bool
    var id: String
    var date: Date
    
    init(text: String?, latex:String?=nil, imageName: String?=nil, correct: Bool=false, date: Date) {
        self.text = text
        self.latex = latex
        self.imageName = imageName
        self.correct = correct
        self.id = UUID().uuidString
        self.date = date
    }
    
    convenience init(dict: JSON, date: Date) {
        var text = dict["text"].string
        if let i = text, i.isEmpty {
            text = nil
        }
        var latex = dict["latex"].string
        if let i = latex, i.isEmpty {
            latex = nil
        }
        var imageName = dict["image"].string
        if let i = imageName, i.isEmpty {
            imageName = nil
        }
        
        self.init(text: text, latex: latex , imageName: imageName, correct: dict["correct"].bool ?? false, date: date)
    }
    
    var dateString: String {
        return self.date.toString(format: "yyyyMMdd")
    }
    
    var image: UIImage? {
        guard let imageName = self.imageName, let path = retrievePath(name: self.dateString + imageName) else { return nil }
        return UIImage(contentsOfFile: path)
    }
}

