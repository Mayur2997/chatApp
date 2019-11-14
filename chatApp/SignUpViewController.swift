//
//  SignUpViewController.swift
//  chatApp
//
//  Created by iMac on 11/11/19.
//  Copyright © 2019 Mayur. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth 
import FirebaseDatabase

class SignUpViewController: UIViewController {
    
    // MARK:- Outlet
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var NameTextField: UITextField!
     
    // MARK:- View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkUserDefaults()
    }
    
    // MARK:- Other Methods
    func checkUserDefaults() {
        let defaults = UserDefaults.standard
        let userEmail = defaults.string(forKey: "userEmail")
        let userPassword = defaults.string(forKey: "userPassword")
        if userEmail != nil && userPassword != nil {
            Auth.auth().signIn(withEmail: userEmail!, password: userPassword! ) { (user, error) in
                if error == nil {
                    //  successfully logged in
                    print("You have successfully logged in")
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
    
    // MARK:- IBAction
    @IBAction func onCreateAccBtnClick(_ sender: Any) { 
        if passwordTextField.text == confirmPasswordTextField.text {
            if emailTextField.text == "" {
                let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                present(alertController, animated: true, completion: nil)
            } else {
                Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                    if error == nil {
                        print("You have successfully signed up")
                        let currentUser = Auth.auth().currentUser?.email as String?
                        let messagesDB = Database.database().reference().child("Users")
                        let messageDictionary = ["Email": currentUser , "Name": self.NameTextField.text!]
                        messagesDB.childByAutoId().setValue(messageDictionary) { (error,reference) in
                            if error != nil {
                                print(error!)
                            }else{
                                print("name and email saved successfully")
                            }
                        }
                        //move to login page
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
                        self.present(vc!, animated: true, completion: nil)
                    } else {
                        let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        } else {
            let alertController = UIAlertController(title: "Error", message: "password does not match!", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        }
    }
}
 
