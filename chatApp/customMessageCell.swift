//
//  CustomMessageCell.swift
//  chatApp
//
//  Created by iMac on 11/11/19.
//  Copyright © 2019 Mayur. All rights reserved.
//


import UIKit

class CustomMessageCell: UITableViewCell {
    
    // MARK:- Outlet
    @IBOutlet weak var messageBackground: UIView! 
    @IBOutlet weak var lblMessageBody: UILabel!
    @IBOutlet weak var lblDateTime: UILabel!
    
    
    // MARK:- Cell LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code goes here
    }
}
