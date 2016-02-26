//
//  AllNotesViewController.swift
//  Notes
//
//  Created by Ebpearls on 2/19/16.
//  Copyright © 2016 Ebpearls. All rights reserved.
//

import UIKit



class AllNotesViewController: UIViewController {

    @IBOutlet weak var backBtnOutlet: UIButton!
    @IBOutlet weak var sideviewConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var floatingBtnOutlet: UIButton!
    @IBOutlet weak var floatingMenuView: UIView!
    @IBOutlet weak var floatingMenuTable: UITableView!
    @IBOutlet weak var floatingMenuWidth: NSLayoutConstraint!
    @IBOutlet weak var floatingMenuHeight: NSLayoutConstraint!
    
    @IBOutlet weak var allNotesTableView: UITableView!
    @IBOutlet weak var menuItemTableView: UITableView!
    
    var sideViewShowing = false
    var floatingMenuShowing = false
    
    var menuArray: Array<AnyObject>!
    var floatingMenuArray: Array<AnyObject>!
    var notesArray: Array<AnyObject>!
    
    var tagArray: Array<AnyObject>!
    var sectionWiseNoteArray: Array<AnyObject>!
    
    var databasePath = NSString()
    var isSortTagView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.allNotesTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        menuArray = [["signIn", "Sign in to sync"], ["tagIcon", "Tags"], ["placesIcon", "Places"], ["settingsIcon", "Settings"], ["syncImage", "Sync"]]
        
        floatingMenuArray = [["note", "Text"]]
        allNotesTableView.rowHeight = UITableViewAutomaticDimension // dynamic table cell height here
        allNotesTableView.estimatedRowHeight = 50.0
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.floatingBtnOutlet.transform = CGAffineTransformMakeRotation(CGFloat(0))
        notesArray = []
        if !(Helper.databaseConnection()){
            self.showAlertOnMainThread("Database Error")
        }
        else{
            getNotes()
        }
        
    }
    
    func viewTapped(tapgesture: UITapGestureRecognizer){
        
        if self.sideViewShowing{
            self.backBtnOutlet.sendActionsForControlEvents(.TouchUpInside)
        }
        
        if self.floatingMenuShowing{
            self.floatingBtnOutlet.sendActionsForControlEvents(.TouchUpInside)
        }
        
        
    }
    
    @IBAction func floatingBtnClick(sender: UIButton) {
        
        if floatingMenuShowing{
            UIView.animateWithDuration(0.25, animations:{
                self.floatingBtnOutlet.transform = CGAffineTransformMakeRotation(CGFloat(0))
            })
            hideFloatingView()
            
        }
        else{
            if self.sideViewShowing{
                self.backBtnOutlet.sendActionsForControlEvents(.TouchUpInside)
            }
            UIView.animateWithDuration(0.25, animations:{
                self.floatingBtnOutlet.transform = CGAffineTransformMakeRotation(CGFloat((3/4)*M_PI))
            })
            showFloatingView()
        }
        
        
    }

    @IBAction func backClickBtn(sender: UIButton) {
        
        if sideViewShowing{
            
            self.sideviewConstraint.constant = -200.0
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    self.view.layoutIfNeeded()
                
                }, completion:{ finished in
                    self.sideViewShowing=false
            })
            
        }
            
        else{
            if self.floatingMenuShowing{
                UIView.animateWithDuration(0.25, animations:{
                    self.floatingBtnOutlet.transform = CGAffineTransformMakeRotation(CGFloat(0))
                })
                self.hideFloatingView()
            }
            self.sideviewConstraint.constant = 0.0
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: {
                    self.view.layoutIfNeeded()
                }, completion:{ finished in
                    self.sideViewShowing=true
            })
        }
        
    }
    
    @IBAction func sortBtnClick(sender: UIButton) {
        if sideViewShowing{
            
            self.sideviewConstraint.constant = -200.0
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.view.layoutIfNeeded()
                
                }, completion:{ finished in
                    self.sideViewShowing=false
            })
            
        }
        
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let optionMenu = UIAlertController(title: "Sort by", message: nil, preferredStyle: .ActionSheet)
        
        let tag = UIAlertAction(title: "Tag", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            if !self.isSortTagView{
                self.isSortTagView = !self.isSortTagView
                self.getTags()
            }
            
           

        })
        let timeAsc = UIAlertAction(title: "Time Ascending", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.isSortTagView = false
            self.notesArray.sortInPlace({ (first:AnyObject, second: AnyObject) -> Bool in
                
                let array1 = first as! Array<String>
                let array2 = second as! Array <String>
                let date1 = dateFormatter.dateFromString(array1[5])?.timeIntervalSince1970
                let date2 = dateFormatter.dateFromString(array2[5])?.timeIntervalSince1970
                if date1 < date2{
                    return true
                }
                return false
            })
            self.allNotesTableView.reloadData()
        })
        let timeDsc = UIAlertAction(title: "Time Descending", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.isSortTagView = false
            
            self.notesArray.sortInPlace({ (first:AnyObject, second: AnyObject) -> Bool in
                
                let array1 = first as! Array<String>
                let array2 = second as! Array <String>
                let date1 = dateFormatter.dateFromString(array1[5])?.timeIntervalSince1970
                let date2 = dateFormatter.dateFromString(array2[5])?.timeIntervalSince1970
                if date1 < date2{
                    return false
                }
                return true
            })
            self.allNotesTableView.reloadData()
            
            
            
        })

        let cancel = UIAlertAction(title: "Cancel", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        optionMenu.addAction(tag)
        optionMenu.addAction(timeAsc)
        optionMenu.addAction(timeDsc)
        optionMenu.addAction(cancel)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
        
        
    }
    
    func showFloatingView(){
        
        self.floatingMenuWidth.constant = 200
        self.floatingMenuHeight.constant = CGFloat(self.floatingMenuArray.count * 50)
        UIView.animateWithDuration(0.2, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 5,options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.floatingMenuView.alpha = 1.0
            self.view.layoutIfNeeded()
            }, completion:{ finished in
                self.floatingMenuShowing = true
        })
     
        
    }
    
    func hideFloatingView(){
        
        self.floatingMenuWidth.constant = 200
        self.floatingMenuHeight.constant = 0
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.floatingMenuView.alpha = 0.0
            self.view.layoutIfNeeded()
            }, completion:{ finished in
                self.floatingMenuShowing = false
        })
        
    }
   

}


extension AllNotesViewController{
    
    func goMapView(sender:UIButton){
        
        if floatingMenuShowing{
            UIView.animateWithDuration(0.25, animations:{
                self.floatingBtnOutlet.transform = CGAffineTransformMakeRotation(CGFloat(0))
            })
            self.hideFloatingView()
        }
        if sideViewShowing{
            self.backBtnOutlet.sendActionsForControlEvents(.TouchUpInside)
        }
        let itemId = sender.tag
        
        for (_, note) in notesArray.enumerate(){
            let content = note as! Array<String>
            if Int(content[0]) 	== itemId{
                let mapVC = self.storyboard?.instantiateViewControllerWithIdentifier("MapVC") as! MapNoteViewController
                mapVC.noteArray.append(note)
                self.navigationController?.pushViewController(mapVC, animated: true)
                break
            }
            
        }
       
        
       
    }
    
    func tagArraySort(){
        sectionWiseNoteArray = Array<AnyObject>()
        let tagCount = tagArray.count + 1
        for _ in 1...tagCount{
            sectionWiseNoteArray.append(Array<AnyObject>())
        }
        tagArray.append(["","",""])
        
        for singlenote in notesArray{
            
            let content = singlenote as! Array<String>
            var i = 0
            for singletag in tagArray{

                let tag = singletag as! Array<String>

                let indexOfTag = i
                var element = sectionWiseNoteArray[indexOfTag] as! Array<AnyObject>
                if content[2] == tag[0]{
                    element.append(content)
                    sectionWiseNoteArray[indexOfTag] = element
                }
                i++
            }
        }
        self.allNotesTableView.reloadData()
    }
}


extension AllNotesViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        if tableView == self.menuItemTableView{
            let cell: MenuItemCell = tableView.dequeueReusableCellWithIdentifier("MenuItemCell") as! MenuItemCell
            
            let cellData = menuArray[indexPath.row] as! Array<String>
            
            cell.menuItemImage.image = UIImage(named: cellData[0])
            cell.menuItemLabel.text = cellData[1]
            return cell

        }
        else if tableView == self.allNotesTableView{
            
            let cell:SingleNoteCellTableViewCell = tableView.dequeueReusableCellWithIdentifier("SingleNoteCell")! as! SingleNoteCellTableViewCell
            var item = notesArray[indexPath.row] as! Array<String>
            
            if isSortTagView{
                
                 item = (sectionWiseNoteArray[indexPath.section] as! Array<AnyObject>)[indexPath.row] as! Array<String>
                
            }
            cell.noteBtn.tag = Int(item[0])!
            cell.configureData(item)
            
            cell.noteBtn.addTarget(self, action: "goMapView:", forControlEvents: .TouchUpInside)
            return cell
        }
        else{
            let cell: FloatingMenuCell = tableView.dequeueReusableCellWithIdentifier("FloatingMenuCell") as! FloatingMenuCell
            
            let cellData = floatingMenuArray[indexPath.row] as! Array<String>
            
            cell.floatingMenuImage.image = UIImage(named: cellData[0])
            cell.floatingMenuLabel.text = cellData[1]
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSortTagView && tableView == self.allNotesTableView{
            
            let currentSection = section
            
            return (self.sectionWiseNoteArray[currentSection] as! Array<AnyObject>).count
            
        }
        else{
            
            var count = 0
            if tableView == self.menuItemTableView{
                count = menuArray.count
            }
            if tableView == self.floatingMenuTable{
                count = floatingMenuArray.count
            }
            if tableView == self.allNotesTableView{
                count = notesArray.count
            }
            return count

        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if tableView == self.floatingMenuTable{
            if indexPath.row == 0{
                self.hideFloatingView()
                let addVC = self.storyboard?.instantiateViewControllerWithIdentifier("AddNotesVC") as! AddNoteViewController
                self.navigationController?.pushViewController(addVC, animated: true)
            }
        }
        
        if tableView == self.menuItemTableView{
            self.backBtnOutlet.sendActionsForControlEvents(.TouchUpInside)

            if indexPath.row == 1{
                let tagVC = self.storyboard?.instantiateViewControllerWithIdentifier("TagsVC") as! TagsViewController
                self.navigationController?.pushViewController(tagVC, animated: true)
            }
            if indexPath.row == 2{
                if notesArray.count > 0{
                    let mapVC = self.storyboard?.instantiateViewControllerWithIdentifier("MapVC") as! MapNoteViewController
                    mapVC.noteArray = notesArray
                    self.navigationController?.pushViewController(mapVC, animated: true)

                }
                else{
                    self.showAlertOnMainThread("No Notes to display in map")
                }
                
                
            }
            
            
        }
        if tableView == self.allNotesTableView{
            if floatingMenuShowing{
                UIView.animateWithDuration(0.25, animations:{
                    self.floatingBtnOutlet.transform = CGAffineTransformMakeRotation(CGFloat(0))
                })
                self.hideFloatingView()
            }
            if sideViewShowing{
                self.backBtnOutlet.sendActionsForControlEvents(.TouchUpInside)
            }
            let singleNoteVC = self.storyboard?.instantiateViewControllerWithIdentifier("SingleNoteVC") as! SingleNoteViewController
            if isSortTagView{
                
                singleNoteVC.note = (sectionWiseNoteArray[indexPath.section] as! Array<AnyObject>)[indexPath.row] as! Array<String>
               
            }
            else{
                singleNoteVC.note = notesArray[(indexPath.row)] as! Array<String>
            }
            
            self.navigationController?.pushViewController(singleNoteVC, animated: true)
            
            
        }
        
    }

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.01
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if tableView == self.allNotesTableView{
            return true
        }
        return false
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if isSortTagView && tableView == self.allNotesTableView{
            return tagArray.count
        }
        return 1
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView == self.allNotesTableView{
            if isSortTagView{
               let itemToDelete = (sectionWiseNoteArray[indexPath.section] as! Array<AnyObject>)[indexPath.row] as! Array<String>
                let itemId = itemToDelete[0]
                self.deleteNote(itemId,item: indexPath)
                
            }
            else{
                let itemToDelete = self.notesArray[indexPath.row] as! Array<String>
                let itemId = itemToDelete[0]
                self.deleteNote(itemId,item: indexPath)
            }
            
            
        }
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isSortTagView{
            if sectionWiseNoteArray[section].count > 0{
                return 60.0
            }
            else{
                return 0.0
            }
        }
        else{
            return 0.0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isSortTagView && tableView == self.allNotesTableView{
            
            if sectionWiseNoteArray[section].count > 0{
                let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 60))
                
                
                view.backgroundColor = Helper.hexStringToUIColor((tagArray[section] as! Array<String>)[2])
                
                let label = UILabel(frame: CGRect(x: 10, y: 15, width: tableView.frame.size.width, height: 30))
                label.text = (tagArray[section] as! Array<String>)[0] == "" ? "UnOwned" : (tagArray[section] as! Array<String>)[1]
                label.textColor = Helper.inverseColor(view.backgroundColor!)
                view.addSubview(label)
                return view
            }
            else{
                return nil
            }
            
            
        }
        else{
            return nil
        }
        
    }
    
}

extension AllNotesViewController{
    
        
    func getNotes(){
        notesArray = []
        let dirPaths =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)
        
        let docsDir = dirPaths[0]
        
        let databasePath = docsDir.stringByAppendingString("/mynotes.db")
        let notesDB = FMDatabase(path: databasePath as String)
        print(databasePath)
        if notesDB.open() {
            let querySQL = "SELECT ID, NoteType, TagType, Title, Note, Timestamp, Latitude, Longitude, Place FROM Notes"
            
            let results:FMResultSet? = notesDB.executeQuery(querySQL,
                withArgumentsInArray: nil)
            
            while results?.next() == true {
                var singlenote = Array<String>()
                singlenote.append(results!.stringForColumn("ID"))
                singlenote.append(results!.stringForColumn("NoteType"))
                singlenote.append(results!.stringForColumn("TagType"))
                singlenote.append(results!.stringForColumn("Title"))
                singlenote.append(results!.stringForColumn("Note"))
                singlenote.append(results!.stringForColumn("Timestamp"))
                singlenote.append(results!.stringForColumn("Latitude"))
                singlenote.append(results!.stringForColumn("Longitude"))
                singlenote.append(results!.stringForColumn("Place"))
                self.notesArray.append(singlenote)
             }
            notesDB.close()
            self.getTags()
            
            self.allNotesTableView.reloadData()
        } else {
            print("Error: \(notesDB.lastErrorMessage())")
        }
    }
    
    func deleteNote(itemId: String, item : NSIndexPath){
        
        let dirPaths =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)
        
        let docsDir = dirPaths[0]
        
        let databasePath = docsDir.stringByAppendingString("/mynotes.db")
        let notesDB = FMDatabase(path: databasePath as String)
        
        if notesDB.open() {
            let querySQL = "DELETE FROM Notes WHERE ID ='\(itemId)'"
            
            let result = notesDB.executeUpdate(querySQL,
                withArgumentsInArray: nil)
            
            if !result{
                self.showAlertOnMainThread("Error deleting Note")
            }
            else{
                
                if isSortTagView{
                    
                    var idx = self.sectionWiseNoteArray[item.section] as! Array<AnyObject>
                    idx.removeAtIndex(item.row)
                    self.sectionWiseNoteArray[item.section] = idx
                    self.allNotesTableView.deleteRowsAtIndexPaths([item], withRowAnimation: .Automatic)                    
                }
                else{
                    self.notesArray.removeAtIndex(item.row)
                    self.allNotesTableView.deleteRowsAtIndexPaths([item], withRowAnimation: .Automatic)
                }
                
                self.showAlertOnMainThread("Note Deleted")
            }

        }
        else{
            print("Error: \(notesDB.lastErrorMessage())")
            
        }
    }
    
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
            tagArray = Array<String>()
            while results?.next() == true {
                var singleTag = Array<String>()
                singleTag.append(results!.stringForColumn("TagId"))
                singleTag.append(results!.stringForColumn("Tag"))
                singleTag.append(results!.stringForColumn("TagColor"))
                self.tagArray.append(singleTag)
            }
            notesDB.close()
            tagArraySort()
        } else {
            print("Error: \(notesDB.lastErrorMessage())")
        }
    
    }

    
    
}


