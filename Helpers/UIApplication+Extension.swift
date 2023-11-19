//
//  UIApplication+Extension.swift
//  19
//
//  Created by Yush Raj Kapoor on 11/19/23.
//

import Foundation
import UIKit

extension UIApplication {
    /**
     Recursively gets the top UIViewController.
     
     - Parameters:
     - base: The base ViewController, defaults as the root ViewController.
     
     - Returns: The sum of `a` and `b`.
     */
    class func topViewController(base: UIViewController? = UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
            
        } else if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
