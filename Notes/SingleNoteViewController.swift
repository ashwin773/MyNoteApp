//
//  SingleNoteViewController.swift
//  Notes
//
//  Created by Ebpearls on 2/25/16.
//  Copyright © 2016 Ebpearls. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class SingleNoteViewController: UIViewController {

    @IBOutlet weak var noteTitle: UILabel!
    @IBOutlet weak var titleEditTxtField: UITextField!
    @IBOutlet weak var descriptionTxtView: UITextView!
    @IBOutlet weak var placeLabel: UILabel!
    
    @IBOutlet weak var saveViewBtnConstraint: NSLayoutConstraint!
    
    var note: Array<String>!
    var isSaveBtnShowing = false
    
    var userlocation: CLLocation?
    var latitude: String?
    var longitude: String?
    var timeStamp :String?
    var address: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        noteTitle.text = note[3]
        titleEditTxtField.text = note[3]
        descriptionTxtView.text = note[4]
        timeStamp = note[5]
        latitude = note[6]
        longitude = note[7]
        address = note[8]
        self.placeLabel.text = address
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("locationReceived:"), name:"receivedLocation", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("locationError:"), name:"errorLocation", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("authorizationChanged:"), name:"authorizationStatusChanged", object: nil)

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
    
    @IBAction func saveEditClick(sender: UIButton) {
        let date = NSDate()
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        timeStamp = dateFormatter.stringFromDate(date)

        self.saveNote()
    }
    
    @IBAction func placebtnClick(sender: UIButton) {
        
        self.getLocation()
    }

}
extension SingleNoteViewController: UITextFieldDelegate, UITextViewDelegate{
    func textFieldDidBeginEditing(textField: UITextField) {
        if !isSaveBtnShowing{
            isSaveBtnShowing = true
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.saveViewBtnConstraint.constant = 0.0
                self.view.layoutIfNeeded()
                }, completion:{ finished in
                    
            })
        }
        
        
        
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if !isSaveBtnShowing{
            isSaveBtnShowing = true
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.saveViewBtnConstraint.constant = 0.0
                self.view.layoutIfNeeded()
                }, completion:{ finished in
                    
            })
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


extension SingleNoteViewController{
    
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
        if !self.isSaveBtnShowing{
            isSaveBtnShowing = true
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.saveViewBtnConstraint.constant = 0.0
                self.view.layoutIfNeeded()
                }, completion:{ finished in
                    
            })
        }
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
                    self?.placeLabel.text = (address.valueForKey("formatted_address") as? String)!
                    self?.address = self?.placeLabel.text
                 }
            }
            else {
                self?.showAlertOnMainThread((response.result.error?.localizedDescription)!)
            }
        }
    }
    
    
}

extension SingleNoteViewController{
    
    func saveNote(){
        
        if self.titleEditTxtField.text?.characters.count != 0 && self.descriptionTxtView.text.characters.count != 0 {
            
            let dirPaths =
            NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
                .UserDomainMask, true)
            
            let docsDir = dirPaths[0]
            
            let databasePath = docsDir.stringByAppendingString("/mynotes.db")
            
            
            let notesDB = FMDatabase(path: databasePath as String)
            
            if notesDB.open() {
                
                let updateSQL = "UPDATE Notes set Title = '\(self.titleEditTxtField.text!)', Note = '\(self.descriptionTxtView.text!)' , Timestamp = '\(self.timeStamp!)' , Latitude = '\(self.latitude!)', Longitude = '\(self.longitude!)', Place = '\(self.address!)' WHERE ID = '\(self.note[0])'"
                
                let result = notesDB.executeUpdate(updateSQL,
                    withArgumentsInArray: nil)
                
                if !result {
                    
                    print("Error: \(notesDB.lastErrorMessage())")
                } else {
                    let alert = UIAlertController(title: "Notes", message: "Note Edited", preferredStyle: UIAlertControllerStyle.Alert)
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
}

