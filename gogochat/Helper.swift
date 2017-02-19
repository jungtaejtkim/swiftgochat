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
import FirebaseDatabase
import GoogleSignIn

class Helper {
    
    static let helper = Helper()
    
    
    func loginAnounymously() {
        
        
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            if error != nil {
                
                print((error?.localizedDescription)!)
                
            } else {
                
                print((user?.uid)!)
                
                
                let newUser = FIRDatabase.database().reference().child("users").child((user?.uid)!)
                
                newUser.setValue(["id" : user?.uid, "displayname" : "anonymous", "photoUrl" : ""])
                
                
                self.switchToNaviVC()
            }
        })
        
    }
    
    
    func loginwithGoogle(authentication: GIDAuthentication) {
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print((error?.localizedDescription)!)
                
            } else {
                print((user?.uid)!)
                print((user?.displayName)!)
                print((user?.email)!)
                print((user?.photoURL)!)
                
                
                
                let newUser = FIRDatabase.database().reference().child("users").child((user?.uid)!)
                
                let photoUrl : String = String(describing: (user?.photoURL!)!)
                
                newUser.setValue(["id" : user?.uid, "displayname" : user?.displayName, "photoUrl" : photoUrl])
                
                self.switchToNaviVC()
                
                
                
            
                
                
            }
            
            
        })
        
    }
    
    func switchToNaviVC() {
        
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let naviVC = storyboard.instantiateViewController(withIdentifier: "NaviVC") as! UINavigationController
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        
        appdelegate.window?.rootViewController = naviVC

    }
    
}
