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
    var imageName: String?
    var questions: [Question]
    var options: [Option]
    
    init(answerType: AnswerType, imageName: String?=nil, questions: [Question], options: [Option]) {
        let correctOptions = options.filter({ $0.correct })
        if correctOptions.isEmpty {
            fatalError("options must have at least one correct option")
        } else if correctOptions.count > 1 && (answerType == .multipleChoice || answerType == .shortAnswer) {
            fatalError("options must have only one correct option for multiple choice or short answer")
        }
        
        self.answerType = answerType
        self.imageName = imageName
        self.questions = questions
        self.options = options
    }
    
    convenience init(dict: JSON) {
        var questions: [Question] = []
        for questionDict in dict["question"].array! {
            questions.append(Question.fromDict(dict: questionDict))
        }
        
        var options: [Option] = []
        for optionDict in dict["option"].array! {
            options.append(Option(dict: optionDict))
        }
        
        self.init(answerType: AnswerType.fromString(string: dict["answerType"].string!), imageName: dict["bodyImage"].string, questions: questions, options: options)
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
        
        if let selfImage = self.imageName {
            allImageNames.append(selfImage)
        }
        
        for option in options {
            if let imgName = option.imageName {
                allImageNames.append(imgName)
            }
        }
        
        let requiresDownloading = Set(allImageNames.filter({ !existsOnFile(name: $0) })).subtracting(Set(downloadQueue))
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        for imgName in requiresDownloading {
            let fileURL = documentsDirectory.appendingPathComponent(imgName)
            StorageManager.shared.downloadURL(for: imgName) { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let url):
                    print("download url \(url)")
                    downloadQueue = UserDefaults.standard.array(forKey: "downloadQueue") as? [String] ?? []
                    guard !downloadQueue.contains(imgName) else { return }
                    downloadQueue.append(imgName)
                    UserDefaults.standard.setValue(downloadQueue, forKey: "downloadQueue")
                    
                    DispatchQueue.global(qos: .utility).async {
                        do {
                            let data = try Data(contentsOf: url)
                                if !FileManager.default.fileExists(atPath: fileURL.path()) {
                                    try data.write(to: fileURL, options: .atomic)
                                }
                            
                                downloadQueue = UserDefaults.standard.array(forKey: "downloadQueue") as? [String] ?? []
                                downloadQueue.removeAll(where: { $0 == imgName })
                                UserDefaults.standard.setValue(downloadQueue, forKey: "downloadQueue")
                                
                                
                                print("\(imgName) saved @ \(fileURL)")
//                                completion(.success(data))
                        } catch {
                            print("Error when attempting to download data \(error.localizedDescription)")
//                            completion(.failure(error))
                            return
                        }
                    }
                    
                    
                }
            }
        }
        
        
    }
    
    
    var image: UIImage? {
        guard let imageName = self.imageName else { return nil }
        return UIImage(named: imageName)
    }
    
}

enum Question {
    case latex(string: String)
    case text(string: String)
    
    static func fromDict(dict: JSON) -> Question {
        guard let type = dict["type"].string, let string = dict["string"].string else { return Question.text(string: "") }
        if type == "l" {
            return Question.latex(string: string)
        } else if type == "t" {
            return Question.text(string: string)
        }
        return Question.text(string: "")
    }
}


class Option {
    var text: String?
    var latex: String?
    var imageName: String?
    var correct: Bool
    var id: String
    
    init(text: String?, latex:String?=nil, imageName: String?=nil, correct: Bool=false) {
        self.text = text
        self.latex = latex
        self.imageName = imageName
        self.correct = correct
        self.id = UUID().uuidString
    }
    
    convenience init(dict: JSON) {
        self.init(text: dict["text"].string ?? "", latex: dict["latex"].string ?? "", imageName: dict["image"].string ?? "", correct: dict["correct"].bool ?? false)
    }
    
    var image: UIImage? {
        guard let imageName = self.imageName else { return nil }
        return UIImage(named: imageName)
    }
}

