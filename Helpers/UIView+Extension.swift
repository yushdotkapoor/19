//
//  UIView+Extension.swift
//  19
//
//  Created by Yush Raj Kapoor on 11/18/23.
//

import Foundation
import UIKit

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
    
    func addBlurEffect(style: UIBlurEffect.Style, fadeDuration: Double = 0.0) {
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
        blurEffectView.alpha = 0
        
        self.addSubview(blurEffectView)
        
        UIView.animate(withDuration: fadeDuration) {
            blurEffectView.alpha = 1
        }
    }
    
    func removeBlurEffect(fadeDuration: Double = 0.0) {
        if let blurView = self.viewWithTag(blurEffectTag) {
            UIView.animate(withDuration: fadeDuration) {
                blurView.alpha = 0
            } completion: { _ in
                blurView.removeFromSuperview()
            }
        }
    }
    
    
    func fadeIn(duration: Double = 1.0) {
        UIView.animate(withDuration: duration) {
            self.alpha = 1.0
        }
    }
    
    func fadeOut(duration: Double = 1.0) {
        UIView.animate(withDuration: duration) {
            self.alpha = 0.0
        }
    }
    
    func startPulse() {
        if !isUserInteractionEnabled {
            UIView.animate(withDuration: 0.5, animations: {
                self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            }, completion: {_ in
                UIView.animate(withDuration: 0.85, delay: 0.05, animations: {
                    self.transform = CGAffineTransform(scaleX: 1/1.15, y: 1/1.15)
                }, completion: {_ in
                    self.startPulse()
                })
            })
        }
    }
    
    func stopPulse() {
        isUserInteractionEnabled = true
    }
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.75
        animation.values = [-20.0, 20.0, -15.0, 15.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        layer.add(animation, forKey: "shake")
    }
    
}
