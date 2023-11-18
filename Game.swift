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
        
//        let scrollView = UIScrollView()
//        scrollView.layer.masksToBounds = false
//        
//        let mainStack = UIStackView()
//        mainStack.spacing = 10
//        mainStack.axis = .vertical
//        
//        let levelLabel = UILabel()
//        levelLabel.tag = 1
//        levelLabel.font = levelLabel.font.withSize(50)
//        levelLabel.textAlignment = .center
//        
//        mainStack.addArrangedSubview(levelLabel)
//        
//        let bodyStack = UIStackView()
//        bodyStack.tag = 2
//        bodyStack.spacing = 10
//        bodyStack.axis = .vertical
//        
//        mainStack.addArrangedSubview(bodyStack)
//        
//        let bufferView = UIView()
//        
//        mainStack.addArrangedSubview(bufferView)
//        
//        let answerStack = UIStackView()
//        answerStack.tag = 3
//        answerStack.spacing = 10
//        answerStack.axis = .vertical
//        
//        let submitButton = UIButton()
//        submitButton.setTitle("Submit", for: .normal)
//        submitButton.setTitleColor(UIColor.link, for: .normal)
//        submitButton.layer.cornerRadius = 20
//        submitButton.layer.borderWidth = 2
//        submitButton.layer.borderColor = submitButton.titleLabel?.textColor.cgColor
//        submitButton.addAction(UIAction(handler: { _ in
//            self.submitPressed()
//        }), for: .touchUpInside)
//        
//        answerStack.addArrangedSubview(submitButton)
//        
//        mainStack.addArrangedSubview(answerStack)
//        
//        mainStack.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.addSubview(mainStack)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
//        NSLayoutConstraint.activate([
//            mainStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
//            mainStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
//            mainStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
//            mainStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
//            mainStack.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
//            submitButton.heightAnchor.constraint(equalToConstant: 40)
//        ])
        
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
        questionImage.image = lvl.body.aspectFittedToWidth(bodyStack.bounds.width)
        
        bodyStack.addArrangedSubview(questionImage)
    }
    
    func initializeAnswers() {
        let answerStack = getAnswerStackView()
        
        let lvl = levels[level-1]
        
        let commandLabel = UILabel()
        commandLabel.numberOfLines = 0
        commandLabel.text = lvl.answerType.command
        
        answerStack.insertArrangedSubview(commandLabel, at: 0)
        
        switch lvl.answerType {
        case .shortAnswer:
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
            
            answerStack.insertArrangedSubview(textBox, at: 1)
        case .multipleChoice, .selection:
            var n = 0
            var hStack: UIStackView!
            var rows = 0
            optionViews = []
            for _ in lvl.options {
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
                buttonStack.spacing = 10
                
                let letterLabel = UILabel()
                letterLabel.textColor = UIColor.link
                letterLabel.layer.borderColor = letterLabel.textColor.cgColor
                letterLabel.tag = 4
                letterLabel.widthAnchor.constraint(equalToConstant: 20).isActive = true
                
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
                    
                    answerStack.insertArrangedSubview(hStack, at: rows + 1)
                    n += 1
                } else {
                    n = 0
                    rows += 1
                }
                
                hStack.addArrangedSubview(outerButtonView)
                hStack.layoutSubviews()
            }
            
            
            for (i, optionView) in optionViews.enumerated() {
                let option = lvl.options[i]
                if let letterLabel = optionView.findView(withTag: 4) as? UILabel {
                    letterLabel.text = String(Character(UnicodeScalar(i + 65)!))
                }
                if let buttonLabel = optionView.findView(withTag: 5) as? UILabel {
                    buttonLabel.text = option.text
                }
                if let buttonImage = optionView.findView(withTag: 6) as? UIImageView {
                    buttonImage.image = option.image?.aspectFittedToWidth(optionView.bounds.width - 35)
                }
                optionView.tag = 10 + i
            }
        }
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
                    print("NO")
                    return
                }
            }
            //correct solution
            correctSolutionChosen()
            return
        }
        print("NO!")
        
        // incorrect solution
    }
    
    func correctSolutionChosen() {
        let correctPopUp = CorrectPopUp()
        view.addBlurEffect(style: .light)
        view.addSubview(correctPopUp)
        
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
   
    private var blurEffectTag: Int { return 999 } // Unique tag to identify the blur effect view
    
    func addBlurEffect(style: UIBlurEffect.Style) {
        // Check if the blur effect view is already added
        if let _ = self.viewWithTag(blurEffectTag) {
            return // Blur effect view already exists, no need to add it again
        }
        
        // Create a blur effect
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        // Configure the blur effect view
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = blurEffectTag
        
        // Add the blur effect view to the background
        self.addSubview(blurEffectView)
    }
    
    func removeBlurEffect() {
        if let blurView = self.viewWithTag(blurEffectTag) {
            blurView.removeFromSuperview()
        }
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


extension UIImage
{
    /// Given a required height, returns a (rasterised) copy
    /// of the image, aspect-fitted to that height.

    func aspectFittedToWidth(_ newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: newSize)

        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
