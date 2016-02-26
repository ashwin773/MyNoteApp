//
//  TagsViewController.swift
//  Notes
//
//  Created by Ebpearls on 2/22/16.
//  Copyright © 2016 Ebpearls. All rights reserved.
//

import UIKit

class TagsViewController: UIViewController, UIPopoverPresentationControllerDelegate, SwiftColorPickerDelegate, SwiftColorPickerDataSource{

    @IBOutlet weak var addTagBtnConstraint: NSLayoutConstraint!
    @IBOutlet weak var addTagBtnOutlet: UIButton!
    @IBOutlet weak var addTagView: UIView!
    var isAddTagShowing = false
    
   
    @IBOutlet weak var pickedColorImageView: UIImageView!
    @IBOutlet weak var tagNameTxtField: UITextField!
    
   
    @IBOutlet weak var tagsTableView: UITableView!
    var tagsArray: Array<AnyObject> = Array()
    
    var colorMatrix = [ [UIColor]() ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getTags()
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addTagBtn(sender: UIButton) {
        if !isAddTagShowing{
            self.addTagBtnOutlet.setImage(UIImage(named: "cancelImage"), forState: .Normal)
            self.addTagView.hidden = false
            self.addTagBtnConstraint.constant = 2.0
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.view.layoutIfNeeded()
                
                }, completion:{ finished in
                    self.isAddTagShowing=true
            })
        }
        else{
            self.addTagBtnConstraint.constant = -155
            self.addTagView.hidden = true
            self.addTagBtnOutlet.setImage(UIImage(named: "addTag"), forState: .Normal)
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.view.layoutIfNeeded()
                
                }, completion:{ finished in
                    self.isAddTagShowing=false
            })
        }
    }

    @IBAction func searchBtn(sender: UIButton) {
        
    }
    
    @IBAction func backBtnClick(sender: UIButton) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
   
    @IBAction func addTagBtnClick(sender: UIButton) {
        
        if self.tagNameTxtField.text?.characters.count > 0{
            var tagDuplication = false
            for singleTag in tagsArray{
                let tag = singleTag as! Array<String>
                if tag[1] == self.tagNameTxtField.textColor!{
                    tagDuplication = true
                }
            }
            
            if tagDuplication{
                self.showAlertOnMainThread("Tag duplication. \(self.tagNameTxtField.text!) is already present.")
            }
            else{
                self.addTag(self.tagNameTxtField.text!, tagColor: "Red")
            }
            
            
        }
    }
    
    @IBAction func colorPicker(sender: UIButton) {
        let colorPickerVC = SwiftColorPickerViewController()
        colorPickerVC.delegate = self
        colorPickerVC.dataSource = self
        colorPickerVC.modalPresentationStyle = .Popover
        let popVC = colorPickerVC.popoverPresentationController!;
        popVC.sourceRect = sender.frame
        popVC.sourceView = self.view
        popVC.permittedArrowDirections = .Any;
        popVC.delegate = self;
        
        self.presentViewController(colorPickerVC, animated: true, completion: {
            print("Reade<");
        })

        
    }
    
    
    
    
    
}
extension TagsViewController{
  //MARK: - POPOver delegates in Iphones
    
    
    // MARK: popover presenation delegates
    
    // this enables pop over on iphones
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        
        return UIModalPresentationStyle.None
    }
    
    
    // MARK: - Color Matrix (only for test case)
    private func fillColorMatrix(numX: Int, _ numY: Int) {
        
        colorMatrix.removeAll()
        if numX > 0 && numY > 0 {
            
            for _ in 0..<numX {
                var colInX = [UIColor]()
                for _ in 0..<numY {
                    colInX += [UIColor.randomColor()]
                }
                colorMatrix += [colInX]
            }
        }
    }
    
    
    // MARK: - Swift Color Picker Data Source
    
    func colorForPalletIndex(x: Int, y: Int, numXStripes: Int, numYStripes: Int) -> UIColor {
        if colorMatrix.count > x  {
            let colorArray = colorMatrix[x]
            if colorArray.count > y {
                return colorArray[y]
            } else {
                fillColorMatrix(numXStripes,numYStripes)
                return colorForPalletIndex(x, y:y, numXStripes: numXStripes, numYStripes: numYStripes)
            }
        } else {
            fillColorMatrix(numXStripes,numYStripes)
            return colorForPalletIndex(x, y:y, numXStripes: numXStripes, numYStripes: numYStripes)
        }
    }
    
    
    // MARK: Color Picker Delegate
    
    func colorSelectionChanged(selectedColor color: UIColor) {
        
        self.pickedColorImageView.backgroundColor = color
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}

extension TagsViewController{
    
    
    func getTags(){
        let dirPaths =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)
        
        let docsDir = dirPaths[0]
        
        let databasePath = docsDir.stringByAppendingString("/mynotes.db")
        let notesDB = FMDatabase(path: databasePath as String)
        
        if notesDB.open() {
            let querySQL = "SELECT TagId, Tag, TagColor FROM Tags"
            
            let results:FMResultSet? = notesDB.executeQuery(querySQL,
                withArgumentsInArray: nil)
            tagsArray = Array()
            while results?.next() == true {
                var singleTag = Array<String>()
                singleTag.append(results!.stringForColumn("TagId"))
                singleTag.append(results!.stringForColumn("Tag"))
                singleTag.append(results!.stringForColumn("TagColor"))
                self.tagsArray.append(singleTag)
            }
            notesDB.close()
            self.tagsTableView.reloadData()
        } else {
            print("Error: \(notesDB.lastErrorMessage())")
        }
        
    }
    
    func addTag(tagTitle: String, tagColor: String){
        
        let hexColor = Helper.hexStringFromColor(self.pickedColorImageView.backgroundColor!)
        let dirPaths =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)
        
        let docsDir = dirPaths[0]
        
        let databasePath = docsDir.stringByAppendingString("/mynotes.db")
        
        
        let notesDB = FMDatabase(path: databasePath as String)
        
        if notesDB.open() {
            
            let insertSQL = "INSERT INTO Tags (Tag, TagColor ) VALUES ('\(tagTitle)','\(hexColor)')"
            
            let result = notesDB.executeUpdate(insertSQL,
                withArgumentsInArray: nil)
            
            if !result {
                
                print("Error: \(notesDB.lastErrorMessage())")
            } else {
                let alert = UIAlertController(title: "Notes", message: "Tag Addded", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {    (action: UIAlertAction!) in
                    
                        self.tagNameTxtField.text = ""
                        self.addTagBtnOutlet.sendActionsForControlEvents(.TouchUpInside)
                        self.getTags()
                    
                }))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
        } else {
            print("Error: \(notesDB.lastErrorMessage())")
        }
        
    }
    
    func deleteTag(itemId: String, item : NSIndexPath){
        
        let dirPaths =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)
        
        let docsDir = dirPaths[0]
        
        let databasePath = docsDir.stringByAppendingString("/mynotes.db")
        let notesDB = FMDatabase(path: databasePath as String)
        
        if notesDB.open() {
            
            let querySQL = "DELETE FROM Tags WHERE TagId ='\(itemId)'"
            
            let result = notesDB.executeUpdate(querySQL,
                withArgumentsInArray: nil)
            
            if !result{
                self.showAlertOnMainThread("Error deleting Tag")
            }
            else{
                self.tagsArray.removeAtIndex(item.row)
                self.tagsTableView.deleteRowsAtIndexPaths([item], withRowAnimation: .Automatic)
                
                let alert = UIAlertController(title: "Notes", message: "Tag Deleted.Delete related Notes also?", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {    (action: UIAlertAction!) in
                    
                    
                        let querySQL = "DELETE FROM Notes WHERE TagType ='\(itemId)'"
                    
                        let result = notesDB.executeUpdate(querySQL,
                        withArgumentsInArray: nil)
                    
                        if !result{
                            self.showAlertOnMainThread("Error deleting Notes")
                        }

                    
                    
                }))
                alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: {    (action: UIAlertAction!) in
                    
                    let querySQL = "UPDATE  Notes SET TagType = '\("")' WHERE TagType ='\(itemId)'"
                    
                    let result = notesDB.executeUpdate(querySQL,
                        withArgumentsInArray: nil)
                    
                    if !result{
                        self.showAlertOnMainThread("Error updating Notes")
                    }
                    
                    
                }))
                self.presentViewController(alert, animated: true, completion: nil)

            }
            
        }
        else{
            print("Error: \(notesDB.lastErrorMessage())")
            
        }
        
    }
}

extension TagsViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")!
        let celldata = tagsArray[indexPath.row] as! Array<String>
        
        cell.backgroundColor = Helper.hexStringToUIColor(celldata[2])
        
        cell.textLabel?.textColor = Helper.inverseColor(cell.backgroundColor!)
        cell.textLabel?.text = celldata[1]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       // tableView.deselectRowAtIndexPath(indexPath, animated: true)
       // self.addTagBtnOutlet.sendActionsForControlEvents(.TouchUpInside)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagsArray.count
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let itemToDelete = self.tagsArray[indexPath.row] as! Array<String>
        let itemId = itemToDelete[0]
        self.deleteTag(itemId,item: indexPath)
    }
}
