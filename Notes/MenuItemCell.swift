//
//  MenuItemCell.swift
//  Notes
//
//  Created by Ebpearls on 2/19/16.
//  Copyright © 2016 Ebpearls. All rights reserved.
//

import UIKit

class MenuItemCell: UITableViewCell {

    
    @IBOutlet weak var menuItemImage: UIImageView!
    @IBOutlet weak var menuItemLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
