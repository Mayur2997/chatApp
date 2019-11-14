//
//  ChatViewController.swift
//  chatApp
//
//  Created by iMac on 11/11/19.
//  Copyright © 2019 Mayur. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

// MARK:- Structure
struct User {
    var email : String = ""
    var name : String = ""
}
 

class UserListViewController: UIViewController {
    
    // MARK:- Outlet And Variable
    @IBOutlet weak var UserListTableView: UITableView!
    var usersArray = [User]()
    let currentUser = Auth.auth().currentUser?.email as String? 
    
    // MARK:- View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        retriveUsers()
        setupUI()
    }
    
    // MARK:- Other Methods
    func setupUI() {
        UserListTableView.tableFooterView = UIView()
    }
    
    func retriveUsers() {
        let messageDB = Database.database().reference().child("Users")
        messageDB.observe(.childAdded, with:{ (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary < String,String>
            let email = snapshotValue["Email"]!
            let name = snapshotValue["Name"]!
            if email != self.currentUser {
                let userStruct = User(email: email, name: name)
                self.usersArray.append(userStruct)
                print(self.usersArray)
                self.UserListTableView.reloadData()
            }
        })
    }
    
    func removeUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.set(nil, forKey: "userEmail")
        defaults.set(nil, forKey: "userPassword")
    }
    
    // MARK:- IBAction
    @IBAction func btnLogoutClicked(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                removeUserDefaults()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpViewController")
                present(vc, animated: true, completion: nil)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    } 
}

// MARK:- TableView
extension UserListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(usersArray.count)
        return usersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! UserListTableViewCell
        cell.nameTextField.text = usersArray[indexPath.row].name
        return cell
    }
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) 
        let userChat: ChatViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        userChat.userName = usersArray[indexPath.row].name
        userChat.userEmail = usersArray[indexPath.row].email
        self.navigationController?.pushViewController(userChat, animated: true)
    }
}

// MARK:- NavigationController
class UserListNavigationController: UINavigationController {
}
