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
import Photos
import ChameleonFramework

// MARK:- Structure
struct Message {
    var sender : String = ""
    var dateTime : String = ""
    var messageBody : String = ""
    var receiver : String = ""
    var ImageURL: String = ""
}

class ChatViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK:- Outlet and Variables
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var sendImage : UIImageView!
    
    var userEmail:String!
    var userName:String!
    var messageArray : [Message] = [Message]()
    let currentUser = Auth.auth().currentUser?.email as String?
    let date = Date()
    let format = DateFormatter()
    
    // MARK:- View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        cellRowHeight()
        retriveMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true) 
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    // MARK:- Other Method
    func setupUI() {
        self.title = userName
        chatTableView.separatorStyle = .none
        navigationItem.rightBarButtonItem = nil
    }
    
    func cellRowHeight() {
        chatTableView.estimatedRowHeight = 85.0
        chatTableView.rowHeight = UITableView.automaticDimension
    }
    
    func dissmissKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func retriveMessages() {
        let messageDB = Database.database().reference().child("Messages")
        messageDB.observe(.childAdded, with:{ (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary < String,String>
            let sender = snapshotValue["Sender"]!
            let receiver = snapshotValue["Receiver"]!
            let dateTime = snapshotValue["DateTime"]!
            let messageBody = snapshotValue["MessageBody"]!
            let ImageURL = snapshotValue["ImageURL"]!
            if ((sender == self.currentUser) || (receiver == self.currentUser)) && ((sender == self.userEmail) || (receiver == self.userEmail)) {
                let messageStruct = Message(sender: sender, dateTime: dateTime, messageBody: messageBody, receiver: receiver, ImageURL: ImageURL)
                self.messageArray.append(messageStruct) 
                self.chatTableView.reloadData()
            }
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        sendImage.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        self.uploadImage(sendImage.image!) { (url) in
                  self.saveImage(imageName: "imgSavedd", profileURL: url!, complition: { success in
                if success != nil {
                    print("image saved")
                }
            })
        }
    }
    
    func uploadImage(_ image: UIImage , complition: @escaping ((_ url: URL?) -> ())) {
        format.dateFormat = "dMMMyyyyhh:mm:ss"
        let formattedDate = format.string(from: date)
        let imageName = currentUser! + formattedDate
        let storageReg = Storage.storage().reference().child(imageName)
        let imageData = sendImage.image?.pngData()
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        storageReg.putData(imageData!, metadata: metaData) { (metadata, error) in
            if error == nil {
                print("success")
                storageReg.downloadURL(completion: { (url, error) in
                    complition(url)
                })
            } else {
                print("erroir while saving image")
                complition(nil)
            }
        }
    }
    
    func saveImage(imageName:String, profileURL: URL , complition: @escaping ((_ url: URL?) -> ()) ) {
        let imageURL = profileURL.absoluteString
        print(imageURL)
        format.dateFormat = "d MMM yyyy, h:mm a"
        let formattedDate = format.string(from: date) 
            let messagesDB = Database.database().reference().child("Messages")
            let messageDictionary = ["Sender": Auth.auth().currentUser?.email, "MessageBody": "image","ImageURL": imageURL, "Receiver": self.userEmail, "DateTime": formattedDate]
            messagesDB.childByAutoId().setValue(messageDictionary) { (error,reference) in
                if error != nil {
                    print(error!)
                }else{
                    print("message saved successfully")
                }
            }
    }
    
    // MARK:- IBAction
    @IBAction func onAddImageBtnClicked(_ sender: Any) {
        let imageController = UIImagePickerController()
        imageController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imageController.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imageController,animated: true,completion: nil)
    }
    
    @IBAction func onSendBtnClicked(_ sender: Any) {
        dismissKeyboard()
        format.dateFormat = "d MMM yyyy, h:mm a"
        let formattedDate = format.string(from: date)
        
        if messageTextField.text != "" {
            let messagesDB = Database.database().reference().child("Messages")
            let messageDictionary = ["Sender": Auth.auth().currentUser?.email, "MessageBody": messageTextField.text!, "Receiver": self.userEmail, "DateTime": formattedDate,"ImageURL": ""]
            messagesDB.childByAutoId().setValue(messageDictionary) { (error,reference) in
                if error != nil {
                    print(error!)
                }else{
                    print("message saved successfully")
                }
            }
            messageTextField.text = ""
        }
    }
}

// MARK:- TableView
extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if messageArray[indexPath.row].ImageURL != "" {
            if messageArray[indexPath.row].receiver == userEmail {
                tableView.register(UINib(nibName: "SenderImageCell", bundle: nil), forCellReuseIdentifier: "SenderImageCell")
                let cell = tableView.dequeueReusableCell(withIdentifier: "SenderImageCell", for: indexPath) as! SenderImageCell
                cell.backGround.backgroundColor = UIColor.flatMint()
                cell.lblDateTime.text = messageArray[indexPath.row].dateTime
                if let url = URL(string: messageArray[indexPath.row].ImageURL) {
                    do {
                        let data = try Data(contentsOf: url)
                        cell.messageImage.image = UIImage(data: data)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                return cell
            } else {
                tableView.register(UINib(nibName: "ReceiverImageCell", bundle: nil), forCellReuseIdentifier: "ReceiverImageCell")
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverImageCell", for: indexPath) as! ReceiverImageCell
                cell.backGround.backgroundColor = UIColor.flatPowderBlue()
                cell.lblDateTime.text = messageArray[indexPath.row].dateTime
                if let url = URL(string: messageArray[indexPath.row].ImageURL) {
                    do {
                        let data = try Data(contentsOf: url)
                        cell.messageImage.image = UIImage(data: data) 
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                return cell
            }
        } else {
            if messageArray[indexPath.row].receiver == userEmail {
                tableView.register(UINib(nibName: "MessageCell2", bundle: nil), forCellReuseIdentifier: "customMessageCell2")
                let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell2", for: indexPath) as! CustomMessageCell2
                cell.messageBackground.backgroundColor = UIColor.flatMint()
                cell.lblDateTime.text = messageArray[indexPath.row].dateTime
                cell.lblMessageBody.text = messageArray[indexPath.row].messageBody
                return cell
            } else {
                tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
                let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
                cell.messageBackground.backgroundColor = UIColor.flatPowderBlue()
                cell.lblDateTime.text = messageArray[indexPath.row].dateTime
                cell.lblMessageBody.text = messageArray[indexPath.row].messageBody
                return cell
            }
        }     }
}


