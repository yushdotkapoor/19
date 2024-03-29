//
//  Game.swift
//  19
//
//  Created by Yush Raj Kapoor on 11/15/23.
//

import Foundation
import UIKit
import SwiftMath

/*
 Tags:
    1 - levelLabel (top UILabel that displays level)
    2 - bodyStack (UIStackView that contains the question)
    3 - answerStack (UIStackView that contains the answer options)
    4 - letterLabel (UILabel for each MC option [A, B, C, D...])
    5 - buttonLabel (UILabel for each MC option that displays the text answer choice)
    6 - buttonImage (UIImage for each MC option that displays the image answer choice)
    7 - textBox (UITextField for SA option that allows user input for the answer)
    8 - latexLabel (MTMathUILabel for each MC option that displays latex text)
    10+N - optionView (Each answer choice/field has their own unique tag)
 */

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
        bodyStack.setupView(delegate: self)
    }
    
    func initializeAnswers() {
        let answerStack = getAnswerStackView()
        answerStack.setupView(delegate: self)
    }
    
    func submitPressed() {
        view.endEditing(true)
        
        let lvl = levels[level-1]
        
        var correctAnswers: [Option] = []
        var answers: [Option] = []
        
        
        switch lvl.answerType {
        case .shortAnswer:
            correctAnswers = lvl.options
            if let textField = optionViews.last as? UITextField {
                answers = [Option(text: textField.text, date: Date.now)]
            }
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
                let mc = answers.contains(where: { $0.id == i.id })
                let sa = answers.contains(where: { $0.text == i.text })
                
                if ([.multipleChoice, .selection].contains(lvl.answerType) && !mc) || (lvl.answerType == .shortAnswer && !sa) {
                    // Incorrect solution
                    impact(style: .error)
                    shakeForError()
                    return
                }
            }
            //correct solution
            impact(style: .success)
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
        
        for i in 0...optionViews.count - 1 {
            if let aView = answerStack.findView(withTag: i + 10) {
                views.append(aView)
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
        levels[level - 1].completed = true
        let dtFormatted = targetDate.toString(format: "yyyyMMdd")
        ref.child("Users").child(auth.currentUser!.uid).child("levelCompletion").child(dtFormatted).child(String(level - 1)).setValue(true)
        
        if levels.count < level + 1 {
            // completed set
            ref.child("Users").child(auth.currentUser!.uid).child("setCompletion").child(dtFormatted).setValue(true)
            if var setsCompleted = UserDefaults.standard.dictionary(forKey: "setsCompleted") as? [String: Bool] {
                setsCompleted[dtFormatted] = true
                UserDefaults.standard.setValue(setsCompleted, forKey: "setsCompleted")
            }
        }
        
        let correctPopUp = CorrectPopUp(delegate: self)
        
        view.addSubview(correctPopUp)
        
        NSLayoutConstraint.activate([
            correctPopUp.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            correctPopUp.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        correctPopUp.beginAnimation()
    }
    
    func transitionLevel() {
        let levelTransitionView = LevelTransitonView(delegate: self)
        
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





