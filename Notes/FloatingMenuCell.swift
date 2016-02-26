//
//  FloatingMenuCell.swift
//  Notes
//
//  Created by Ebpearls on 2/19/16.
//  Copyright © 2016 Ebpearls. All rights reserved.
//

import UIKit

class FloatingMenuCell: UITableViewCell {

    @IBOutlet weak var floatingMenuLabel: UILabel!
    @IBOutlet weak var floatingMenuImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
