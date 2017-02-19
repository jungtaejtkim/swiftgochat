//
//  LoginViewController.swift
//  gogochat
//
//  Created by KimJungtae on 2017. 2. 8..
//  Copyright © 2017년 Dolmong. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn
import FirebaseDatabase

class LoginViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {

    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginAnonymously(_ sender: Any) {
        Helper.helper.loginAnounymously()
    }
    
    
    
    @IBAction func loginWithGoogle(_ sender: Any) {
        
        
        GIDSignIn.sharedInstance().signIn()
        
    }
    

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            print(error.localizedDescription)
        } else {
            print(user.authentication)
            
            
            Helper.helper.loginwithGoogle(authentication: user.authentication)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.borderWidth = 1.0
        loginButton.layer.borderColor = UIColor.white.cgColor
        
        
        GIDSignIn.sharedInstance().clientID = "933917451254-80iitrc8i0mr5jshhv25mpmgdugfia9k.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            if user != nil {
                print(user!)
                Helper.helper.switchToNaviVC()
            } else {
                
                print("unauthorized")
                
            }
        })
        // JT: firebase offer this mothod to monitor user's signing status but I can use just if nil case
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
