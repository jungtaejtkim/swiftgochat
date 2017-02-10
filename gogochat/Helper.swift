//
//  Helper.swift
//  gogochat
//
//  Created by KimJungtae on 2017. 2. 8..
//  Copyright © 2017년 Dolmong. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import GoogleSignIn

class Helper {
    
    static let helper = Helper()
    
    
    func loginAnounymously() {
        
        
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            if error != nil {
                
                print(error?.localizedDescription)
                
            } else {
                
                print(user?.uid)
                
                self.switchToNaviVC()
            }
        })
        
    }
    
    
    func loginwithGoogle(authentication: GIDAuthentication) {
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print(error?.localizedDescription)
                return
            } else {
                print(user?.uid)
                print(user?.displayName)
                print(user?.email)
                self.switchToNaviVC()
            
            }
            
            
        })
        
    }
    
    private func switchToNaviVC() {
        
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let naviVC = storyboard.instantiateViewController(withIdentifier: "NaviVC") as! UINavigationController
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        
        appdelegate.window?.rootViewController = naviVC

    }
    
}
