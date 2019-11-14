//
//  UserListTableViewCell.swift
//  chatApp
//
//  Created by iMac on 12/11/19.
//  Copyright © 2019 Mayur. All rights reserved.
//

import UIKit

class UserListTableViewCell: UITableViewCell {

    // MARK:- Outlet
    @IBOutlet weak var nameTextField: UILabel!
    
    // MARK:- Cell LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
