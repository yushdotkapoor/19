//
//  Game.swift
//  19
//
//  Created by Yush Raj Kapoor on 11/15/23.
//

import Foundation
import UIKit

var levels: [Level] = [
    Level(answerType: .shortAnswer, body: UIImage(), question: "Solve this problem", options: [Option(text: "noble", image: UIImage(), correct: true)]),
    Level(answerType: .multipleChoice, body: UIImage.add, question: "Solve this second problem", options: [Option(text: "test 1", image: UIImage()), Option(text: "test 2", image: UIImage()), Option(text: "test 3", image: UIImage()), Option(text: "test 4", image: UIImage(), correct: true)]),
    
]

class Game: UIViewController {
    
    var level: Int!
    
    var optionViews: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        persistantInitialize()
        initializeLevel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func persistantInitialize() {
        let scrollView = LevelSkeletonView(source: self)
       
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        self.view.layoutIfNeeded()
    }
    
    func getBodyStackView() -> LevelBodyStack {
        guard let stackView = self.view.findView(withTag: 2) as? LevelBodyStack else {
            return LevelBodyStack()
        }
        return stackView
    }
    
    func getAnswerStackView() -> LevelAnswerStack {
        guard let stackView = self.view.findView(withTag: 3) as? LevelAnswerStack else {
            return LevelAnswerStack()
        }
        return stackView
    }
    
    func clearView() {
        let bodyStack = getBodyStackView()
        let answerStack = getAnswerStackView()
        for v in (bodyStack.subviews + answerStack.subviews) {
            v.removeFromSuperview()
        }
    }
    
    func initializeLevel() {
        if let levelLabel = self.view.findView(withTag: 1) as? UILabel {
            levelLabel.text = "\(level!)"
        }
        
        initializeBody()
        initializeAnswers()
    }
    
    func initializeBody() {
        let bodyStack = getBodyStackView()
        bodyStack.setupView(source: self)
    }
    
    func initializeAnswers() {
        let answerStack = getAnswerStackView()
        answerStack.setupView(source: self)
    }
    
    func submitPressed() {
        let lvl = levels[level-1]
        
        var correctAnswers: [Option] = []
        var answers: [Option] = []
        
        switch lvl.answerType {
        case .shortAnswer:
            correctAnswers = lvl.options
            
        case .multipleChoice, .selection:
            for optionView in optionViews {
                let option = lvl.options[optionView.tag - 10]
                if optionView.isHighlighted() {
                    answers.append(option)
                }
                if option.correct {
                    correctAnswers.append(option)
                }
            }
        }
        
        if answers.count == correctAnswers.count {
            for i in correctAnswers {
                if !answers.contains(where: { $0.id == i.id }) {
                    // Incorrect solution
                    impact(style: .error)
                    shakeForError()
                    return
                }
            }
            //correct solution
            correctSolutionChosen()
            return
        }
        
        // incorrect solution
        impact(style: .error)
        shakeForError()
    }
    
    func shakeForError() {
        let answerStack = getAnswerStackView()
        var views:[UIView] = []
        if !optionViews.isEmpty {
            for i in 0...optionViews.count - 1 {
                if let aView = answerStack.findView(withTag: i + 10) {
                    views.append(aView)
                }
            }
        }
        
        if let aView = answerStack.findView(withTag: 7) {
            views.append(aView)
        }
        
        for v in views {
            v.shake()
        }
        
    }
    
    func correctSolutionChosen() {
        UserDefaults.standard.setValue(true, forKey: "Level " + (String(level)))
        let correctPopUp = CorrectPopUp(source: self)
        
        view.addSubview(correctPopUp)
        
        NSLayoutConstraint.activate([
            correctPopUp.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            correctPopUp.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        correctPopUp.beginAnimation()
    }
    
    func transitionLevel() {
        let levelTransitionView = LevelTransitonView(source: self)
        
        view.addSubview(levelTransitionView)
        
        NSLayoutConstraint.activate([
            levelTransitionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            levelTransitionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            levelTransitionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            levelTransitionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        if levels.count < level + 1 {
            // completed set
            UIView.animate(withDuration: 1) {
                levelTransitionView.alpha = 1
            } completion: { _ in
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        levelTransitionView.beginAnimation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.view.removeBlurEffect()
        }
    }
    
    
    @objc func handleMCTap(_ sender: UITapGestureRecognizer) {
        impact(style: .medium)
        let lvl = levels[level-1]
        if lvl.answerType == .selection {
            let highlighted = sender.view?.isHighlighted() ?? false
            if highlighted {
                sender.view?.removeHighlightLayer()
            } else {
                sender.view?.addHighlightLayer()
            }
        } else if lvl.answerType == .multipleChoice {
            let highlighted = sender.view?.isHighlighted()
            for optionView in optionViews {
                optionView.removeHighlightLayer()
            }
            if !(highlighted ?? false) {
                sender.view?.addHighlightLayer()
            }
        }
    }
    
    @objc func keyboardWillChange(_ notification: Notification) {
        if let scrollView = view.getTopScrollView() {
            if notification.name == UIResponder.keyboardWillHideNotification {
                // If keyboard has hidden, then set UIScrollView inset to 0
                scrollView.contentInset = UIEdgeInsets.zero
            } else {
                // If keyboard has appeared, then add insets to the UIScrollView equivalent to how much the UITextField is being covered by the keyboard
                let keyboardScreenEndFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
                scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height + 10, right: 0)
            }
            scrollView.scrollIndicatorInsets = scrollView.contentInset
            
        }
    }
    
}

extension Game: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}


func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.impactOccurred()
}

func impact(style: UINotificationFeedbackGenerator.FeedbackType) {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(style)
}



extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.75
        animation.values = [-20.0, 20.0, -15.0, 15.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        layer.add(animation, forKey: "shake")
    }
}
