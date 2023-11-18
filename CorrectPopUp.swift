//
//  CorrectPopUp.swift
//  19
//
//  Created by Yush Raj Kapoor on 11/17/23.
//

import Foundation
import UIKit

class CorrectPopUp: UIView {
    
    init() {
        super.init(frame: CGRect())
        let popUpStack = UIStackView()
        popUpStack.spacing = 10
        popUpStack.axis = .vertical
        
        
        addSubview(popUpStack)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
