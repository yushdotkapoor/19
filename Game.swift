//
//  Game.swift
//  19
//
//  Created by Yush Raj Kapoor on 11/15/23.
//

import Foundation
import UIKit

var levels: [Level] = [
    //        Level(answerType: .shortAnswer, body: UIImage(), question: "Solve this problem"),
    Level(answerType: .multipleChoice, body: UIImage(), question: "Solve this second problem", options: [MCOption(text: "test 1", image: UIImage()), MCOption(text: "test 2", image: UIImage.checkmark, correct: true)]),
    
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
        let scrollView = UIScrollView()
        
        let mainStack = UIStackView()
        mainStack.spacing = 20
        mainStack.axis = .vertical
        
        let levelLabel = UILabel()
        levelLabel.tag = 1
        levelLabel.font = levelLabel.font.withSize(50)
        levelLabel.textAlignment = .center
        
        mainStack.addArrangedSubview(levelLabel)
        
        let bodyStack = UIStackView()
        bodyStack.tag = 2
        bodyStack.spacing = 20
        bodyStack.axis = .vertical
        
        mainStack.addArrangedSubview(bodyStack)
        
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
            self.submitPressed()
        }), for: .touchUpInside)
        
        answerStack.addArrangedSubview(submitButton)
        
        mainStack.addArrangedSubview(answerStack)
        
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(mainStack)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
        
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            mainStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            mainStack.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            mainStack.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        self.view.layoutIfNeeded()
    }
    
    func getBodyStackView() -> UIStackView {
        guard let stackView = self.view.findView(withTag: 2) as? UIStackView else {
            return UIStackView()
        }
        return stackView
    }
    
    func getAnswerStackView() -> UIStackView {
        guard let stackView = self.view.findView(withTag: 3) as? UIStackView else {
            return UIStackView()
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
        
        let lvl = levels[level-1]
        let questionLabel = UILabel()
        questionLabel.text = lvl.question
        questionLabel.numberOfLines = 0
        questionLabel.font = questionLabel.font.withSize(20)
        
        bodyStack.addArrangedSubview(questionLabel)
        
        let questionImage = UIImageView()
        questionImage.image = lvl.body
        
        bodyStack.addArrangedSubview(questionImage)
    }
    
    func initializeAnswers() {
        let answerStack = getAnswerStackView()
        
        let lvl = levels[level-1]
        if lvl.answerType == .shortAnswer {
            let textBox = UITextField()
            textBox.placeholder = "Answer"
            textBox.layer.borderWidth = 2
            textBox.layer.cornerRadius = 20
            textBox.returnKeyType = .done
            textBox.autocorrectionType = .no
            textBox.smartInsertDeleteType = .no
            textBox.delegate = self
            textBox.setLeftPaddingPoints(10)
            textBox.setRightPaddingPoints(10)
            
            textBox.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            answerStack.insertArrangedSubview(textBox, at: 0)
        } else if lvl.answerType == .multipleChoice {
            var n = 0
            var hStack: UIStackView!
            optionViews = []
            for _ in lvl.options! {
                let outerButtonView = UIView()
                outerButtonView.layer.cornerRadius = 10
                outerButtonView.layer.borderWidth = 2
                outerButtonView.layer.borderColor = UIColor.link.cgColor
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleMCTap(_:)))
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
                
                buttonStack.addArrangedSubview(letterLabel)
                
                let choiceStack = UIStackView()
                choiceStack.axis = .vertical
                choiceStack.spacing = 5
                
                let buttonLabel = UILabel()
                buttonLabel.textColor = UIColor.link
                buttonLabel.numberOfLines = 0
                buttonLabel.tag = 5
                
                choiceStack.addArrangedSubview(buttonLabel)
                
                let buttonImage = UIImageView()
                buttonImage.tag = 6
                
                choiceStack.addArrangedSubview(buttonImage)
                
                buttonStack.addArrangedSubview(choiceStack)
                
                optionViews.append(outerButtonView)
                
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
                    
                    answerStack.insertArrangedSubview(hStack, at: 0)
                    n += 1
                } else {
                    n = 0
                }
                
                hStack.addArrangedSubview(outerButtonView)
                hStack.layoutSubviews()
            }
            
            for (i, optionView) in optionViews.enumerated() {
                let option = lvl.options![i]
                if let letterLabel = optionView.findView(withTag: 4) as? UILabel {
                    letterLabel.text = String(Character(UnicodeScalar(i + 65)!))
                }
                if let buttonLabel = optionView.findView(withTag: 5) as? UILabel {
                    buttonLabel.text = option.text
                }
                if let buttonImage = optionView.findView(withTag: 6) as? UIImageView {
                    buttonImage.image = option.image
                }
                optionView.tag = 10 + i
            }
        }
    }
    
    func submitPressed() {
        var correctAnswers: [MCOption] = []
        var answers: [MCOption] = []
        let lvl = levels[level-1]
        for optionView in optionViews {
            let MCOption = lvl.options![optionView.tag - 10]
            if optionView.isHighlighted() {
                answers.append(MCOption)
            }
            if MCOption.correct {
                correctAnswers.append(MCOption)
            }
        }
        
        if answers.count == correctAnswers.count {
            for i in correctAnswers {
                if !answers.contains(where: { $0.id == i.id }) {
                    // Incorrect solution
                    print("NO")
                    return
                }
            }
            //correct solution
            print("yay")
            return
        }
        print("NO!")
        
        // incorrect solution
        
    }
    
    
    @objc func handleMCTap(_ sender: UITapGestureRecognizer) {
        impact(style: .medium)
        let highlighted = sender.view?.isHighlighted()
        for optionView in optionViews {
            optionView.removeHighlightLayer()
        }
        if !(highlighted ?? false) {
            sender.view?.addHighlightLayer()
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



extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}


extension UIView {
    /**
     Recursively gets the topmost UiScrollView in a view.
     
     - Returns: The topmost UIScrollView in the view.
     */
    func getTopScrollView() -> UIScrollView? {
        if let scrollView = self as? UIScrollView {
            return scrollView
        }
        
        for subview in self.subviews {
            if let scrollView = subview.getTopScrollView() {
                return scrollView
            }
        }
        
        return nil
    }
    
    func findView(withTag tag: Int) -> UIView? {
        if self.tag == tag {
            return self
        }
        
        for subview in self.subviews {
            if let view = subview.findView(withTag: tag) {
                return view
            }
        }
        
        return nil
    }
    
    func addHighlightLayer() {
        let highlightLayer = CALayer()
        highlightLayer.frame = bounds
        
        let cornerRadius = layer.cornerRadius // Get the corner radius of the view
        highlightLayer.cornerRadius = cornerRadius
        
        highlightLayer.backgroundColor = UIColor.lightGray.cgColor
        highlightLayer.opacity = 0.5
        
        layer.addSublayer(highlightLayer)
        layer.mask = createMaskLayer()
    }
    
    private func createMaskLayer() -> CAShapeLayer {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius)
        maskLayer.path = path.cgPath
        
        return maskLayer
    }
    
    func removeHighlightLayer() {
        // Find the highlight layer based on a specific condition (e.g., color, type, etc.)
        if let highlightLayer = layer.sublayers?.first(where: { $0.backgroundColor == UIColor.lightGray.cgColor }) {
            highlightLayer.removeFromSuperlayer() // Remove the highlight layer from its superlayer
        }
    }
    
    func isHighlighted() -> Bool {
        if let _ = layer.sublayers?.first(where: { $0.backgroundColor == UIColor.lightGray.cgColor }) {
            return true
        }
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
