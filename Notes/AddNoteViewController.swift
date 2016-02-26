//
//  AddNoteViewController.swift
//  Notes
//
//  Created by Ebpearls on 2/19/16.
//  Copyright © 2016 Ebpearls. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire


class AddNoteViewController: UIViewController {

    @IBOutlet weak var noteTitle: UITextField!
    @IBOutlet weak var noteText: UITextView!
    
    @IBOutlet weak var noteDescriptionTitle: UILabel!
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var tagPicker: UIPickerView!
    @IBOutlet weak var tagViewConstraint: NSLayoutConstraint!
    var selectedTag: String = ""
    var isPickerViewShowing = false
    
    var userlocation: CLLocation?
    var latitude: String?
    var longitude: String?
    var timeStamp :String?
    var address: String?
    
    var titleString:String?
    
    var isTextViewEditing = false
    var tagArray: Array<AnyObject> = Array<String>()
    
    var currentField: UITextField?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }

    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
       
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("locationReceived:"), name:"receivedLocation", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("locationError:"), name:"errorLocation", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("authorizationChanged:"), name:"authorizationStatusChanged", object: nil)
        
        let mainViewTapRecognizer = UITapGestureRecognizer(target: self, action: "mainViewTapped:")
        mainViewTapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(mainViewTapRecognizer)
        getTags()
        self.getLocation()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
       NSNotificationCenter.defaultCenter().removeObserver(self, name: "receivedLocation", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "errorLocation", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "authorizationStatusChanged", object: nil)
    }

    

    @IBAction func backBtnClick(sender: UIButton) {
        
        self.navigationController?.popViewControllerAnimated(true)
    
    }
    
    @IBAction func addTgBtn(sender: UIButton) {
        
        if !isPickerViewShowing{
            if tagArray.count > 0 {
                UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    self.tagViewConstraint.constant = 0.0
                    }, completion:{ finished in
                        self.isPickerViewShowing = true
                })
                
            }
            else{
                
                self.showAlertOnMainThread("No Tags Available")
            }
            
        }
    }
    
    func makeTitle(address:String){
        
        let date = NSDate()
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        timeStamp = dateFormatter.stringFromDate(date)
        let title = "\(timeStamp!)-\(address)"
        self.address = address
        self.noteTitle.text = title
        self.titleString = title
        
    }
    
     func mainViewTapped(gestureRecognizer: UITapGestureRecognizer){
        
        if isTextViewEditing{
            self.noteText.resignFirstResponder()
        }
        if isPickerViewShowing{
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.tagViewConstraint.constant = -216.0
                }, completion:{ finished in
                    self.isPickerViewShowing = false
            })
        }
        self.currentField?.resignFirstResponder()
        
    }
}


extension AddNoteViewController{
    
    func getLocation() {
        
            if LocationService.sharedInstance.isLocationEnabled(){
                LocationService.sharedInstance.startUpdatingLocation()
            }
            else{
                self.showAlertOnMainThread("Please check  location settings to proceed")
            }
        
        
    }
    
    func locationReceived(notification: NSNotification){
       
        LocationService.sharedInstance.stopUpdatingLocation()
        userlocation = LocationService.sharedInstance.currentLocation
        reverseGeocodeLocation()
        
    }
    
    func locationError(notification: NSNotification){
       
        LocationService.sharedInstance.stopUpdatingLocation()
        self.showAlertOnMainThread("Error. Please try again")
        
    }
    
    func authorizationChanged(notification: NSNotification){
        
        let authorizationStatus = LocationService.sharedInstance.getAuthorizationStatus()
        if authorizationStatus.rawValue < 3{
            LocationService.sharedInstance.stopUpdatingLocation()
            self.showAlertOnMainThread("Please checking location settings to proceed")
        }
        
    }
    
    
    func reverseGeocodeLocation(){
        
        latitude = String((userlocation?.coordinate.latitude)!)
        longitude = String((userlocation?.coordinate.longitude)!)
        let url = kReverseGeocodeUrl+latitude!+","+longitude!+"&sensor=true"
        
        Alamofire.request(.GET, url).responseJSON { [weak self] response in
            
            if let responseData = response.result.value {
                
                let status = responseData.valueForKey("status") as! String
                let result = responseData.valueForKey("results") as! NSArray
                let address = result.objectAtIndex(0) as! NSDictionary
                if status == "OK" {
                    self?.makeTitle((address.valueForKey("formatted_address") as? String)!)
                   
                }
            }
            else {
                self?.showAlertOnMainThread((response.result.error?.localizedDescription)!)
            }
        }
    }
    
    
}


extension AddNoteViewController{
   
    @IBAction func saveBtn(sender: AnyObject) {
        
        if self.noteTitle.text?.characters.count != 0 && self.noteText.text.characters.count != 0 {
            
            let dirPaths =
            NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
                .UserDomainMask, true)
            
            let docsDir = dirPaths[0]
            
            let databasePath = docsDir.stringByAppendingString("/mynotes.db")
            
            
            let notesDB = FMDatabase(path: databasePath as String)
            
            if notesDB.open() {
                
                let insertSQL = "INSERT INTO Notes (NoteType, TagType, Title,  Note, Timestamp, Latitude, Longitude, Place) VALUES ('\("1")','\(self.selectedTag)','\(self.noteTitle.text!)', '\(self.noteText.text!)', '\(self.timeStamp!)', '\(self.latitude!)', '\(self.longitude!)','\(self.address!)')"
                
                let result = notesDB.executeUpdate(insertSQL,
                    withArgumentsInArray: nil)
                
                if !result {
                    
                    print("Error: \(notesDB.lastErrorMessage())")
                } else {
                    let alert = UIAlertController(title: "Notes", message: "Note Addded", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {    (action: UIAlertAction!) in
                        
                        self.navigationController?.popViewControllerAnimated(true)
                        
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)

                }
            } else {
                print("Error: \(notesDB.lastErrorMessage())")
            }

            
        }
        else{
            
            self.showAlertOnMainThread("One of the field is empty")
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
            let querySQL = "SELECT TagId, Tag,TagColor FROM Tags"
            
            let results:FMResultSet? = notesDB.executeQuery(querySQL,
                withArgumentsInArray: nil)
            print(results!)
            while results?.next() == true {
                var singletag = Array<String>()
                singletag.append(results!.stringForColumn("TagId"))
                singletag.append(results!.stringForColumn("Tag"))
                singletag.append(results!.stringForColumn("TagColor"))
                self.tagArray.append(singletag)
            }
            notesDB.close()
            self.tagPicker.reloadAllComponents()
        } else {
            print("Error: \(notesDB.lastErrorMessage())")
        }
    }
    
}

extension AddNoteViewController: UITextFieldDelegate, UITextViewDelegate{
    
    //MARK: - TextField and TextView Delegate Methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
       
        currentField = textField
        titleString = textField.text
        textField.text = ""
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
      
        textField.resignFirstResponder()
        return true
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
       
        if textField.text?.characters.count == 0 {
            textField.text = titleString
        }
        textField.resignFirstResponder()
        
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
       
        self.isTextViewEditing = true
        
    }
}


extension AddNoteViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let item = self.tagArray[row] as! Array<String>
        self.selectedTag = item[0]
        self.noteDescriptionTitle.text = "Note: \(item[1])"
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.tagViewConstraint.constant = -216.0
            self.view.layoutIfNeeded()
            }, completion:{ finished in
                self.isPickerViewShowing = false
        })
        
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if self.tagArray.count > 0{
            return self.tagArray.count
        }
        
        return 0
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let item = self.tagArray[row] as! Array<String>
        return item[1]
        
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        return 1
        
    }

}