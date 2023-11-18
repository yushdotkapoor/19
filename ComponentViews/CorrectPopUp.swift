//
//  CorrectPopUp.swift
//  19
//
//  Created by Yush Raj Kapoor on 11/17/23.
//

import Foundation
import UIKit

class CorrectPopUp: UIView {
    
    var source: Game?
    
    init(source: Game) {
        super.init(frame: CGRect())
        self.source = source
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        guard let source = source else { return }
        
        let h: CGFloat = 380
        let w: CGFloat = UIScreen.main.bounds.width - 100
        layer.cornerRadius = 10
        alpha = 0
        
        let popUpStack = UIStackView()
        popUpStack.spacing = 15
        popUpStack.axis = .vertical
        popUpStack.distribution = .fillProportionally
        
        let correctLabel = UILabel()
        correctLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 50.0)
        
        correctLabel.textAlignment = .center
        correctLabel.textColor = UIColor.systemGreen
        correctLabel.text = "Correct!"
        correctLabel.numberOfLines = 0
        
        popUpStack.addArrangedSubview(correctLabel)
        
        let successGif = UIImage.gifImageWithName("success")
        let imageView = UIImageView(image: successGif)
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        
        popUpStack.addArrangedSubview(imageView)
        
        let nextButton = UIButton()
        nextButton.setTitle("Next", for: .normal)
        nextButton.setTitleColor(UIColor.systemGreen, for: .normal)
        nextButton.layer.cornerRadius = 15
        nextButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        nextButton.layer.borderColor = nextButton.titleLabel?.textColor.cgColor
        nextButton.layer.borderWidth = 2
        nextButton.addAction(UIAction(handler: { _ in
            source.transitionLevel()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                source.view.removeBlurEffect()
                self.removeFromSuperview()
            }
        }), for: .touchUpInside)
        
        popUpStack.addArrangedSubview(nextButton)
        
        popUpStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(popUpStack)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            popUpStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            popUpStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            popUpStack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            popUpStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            heightAnchor.constraint(equalToConstant: h),
            widthAnchor.constraint(equalToConstant: w),
        ])
    }
    
    func beginAnimation() {
        guard let source = source else { return }
        let timeConstant:Double = 0.5
        
        source.view.addBlurEffect(style: .prominent, fadeDuration: timeConstant)
        source.view.bringSubviewToFront(self)
        UIView.animate(withDuration: timeConstant) {
            self.alpha = 1
        }
    }
}
