//
//  Login.swift
//  19
//
//  Created by Yush Raj Kapoor on 11/18/23.
//

import Foundation
import UIKit
import GoogleSignIn
import Firebase

class Login: UIViewController {
    
    var source: ViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref.child("Users/sdfdsdf").getData { error, snapshot in
            if error == nil {
                if let _ = snapshot?.value as? NSNull {
                    print("User does not exist yet")
                }
            } else {
                print(error!)
            }
        }
        
        let signInButton = GIDSignInButton()
        signInButton.addAction(UIAction(handler: { action in
            self.signInWithGoogle()
        }), for: .touchUpInside)
        
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signInButton)
        
        NSLayoutConstraint.activate([
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else { return }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            auth.signIn(with: credential) { result, error in
                if error == nil {
                    ref.child("Users/\(auth.currentUser!.uid)").getData { error, snapshot in
                        if error == nil {
                            if let _ = snapshot?.value as? NSNull {
                                print("User does not exist yet")
                                ref.child("Users/\(auth.currentUser!.uid)").setValue(["name": auth.currentUser!.displayName])
                                self.source.welcomeSequence()
                                self.navigationController?.popViewController(animated: true)
                            }
                        } else {
                            print(error!)
                        }
                    }
                } else {
                    print(error!)
                }
            }
        }
    }
    
    
}
