//
//  ViewController.swift
//  chatApp
//
//  Created by iMac on 11/11/19.
//  Copyright © 2019 Mayur. All rights reserved.
//

import UIKit 
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {

    // MARK:- Outlet
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad() 
    }
    
    // MARK:- Other Method
    func setUserDefaults(email: String, password: String) {
        let defaults = UserDefaults.standard 
        defaults.set(email, forKey: "userEmail")
        defaults.set(password, forKey: "userPassword")
    }
    
    // MARK:- IBAction
    @IBAction func OnLoginBtnClick(_ sender: Any) {
        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
            //Error alert
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        } else { 
            Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                if error == nil {
                    //  successfully logged in
                    print("You have successfully logged in")
                    self.setUserDefaults(email:  self.emailTextField.text!, password: self.passwordTextField.text!)
                    //move to user chat list
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserListNavigationController")
                    self.present(vc!, animated: true, completion: nil)
                } else {
                    // Error alert
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}

