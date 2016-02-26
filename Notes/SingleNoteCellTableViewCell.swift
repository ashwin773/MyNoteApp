//
//  SingleNoteCellTableViewCell.swift
//  Notes
//
//  Created by Ebpearls on 2/22/16.
//  Copyright © 2016 Ebpearls. All rights reserved.
//

import UIKit

class SingleNoteCellTableViewCell: UITableViewCell {

    @IBOutlet weak var noteImage: UIImageView!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var noteDate: UILabel!
    @IBOutlet weak var noteBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureData(item :Array<String>){
        
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
       
        self.noteImage.layer.cornerRadius = self.noteImage.frame.size.width/2
        self.noteImage.clipsToBounds = true
        
        if item[1] == "1"{
            let label = UILabel(frame: CGRect(origin: CGPoint(x: ((self.noteImage.frame.size.width/2)-5), y: ((self.noteImage.frame.size.height/2)-10)), size: CGSize(width: 20, height: 20)))
            label.text = "N"
            label.textColor = UIColor.whiteColor()
            self.noteImage.addSubview(label)
            
        }
        self.noteLabel.text = item[3]
        self.noteDate.text = item[5]
            }

}
