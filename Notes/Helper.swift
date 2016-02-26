//
//  Helper.swift
//  Notes
//
//  Created by Ebpearls on 2/19/16.
//  Copyright © 2016 Ebpearls. All rights reserved.
//

import UIKit


class Helper: NSObject {
    
    
    
    static func databaseConnection() -> Bool{
        
        var successful = true
        
        let filemgr = NSFileManager.defaultManager()
        let dirPaths =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)
        
        let docsDir = dirPaths[0]
        
        let databasePath = docsDir.stringByAppendingString("/mynotes.db")
        
        if !filemgr.fileExistsAtPath(databasePath as String) {
            
            let notesDB = FMDatabase(path: databasePath as String)
            
            if notesDB == nil {
                print("Error: \(notesDB.lastErrorMessage())")
            }
            
            if notesDB.open() {
                let sql_stmt = "CREATE TABLE IF NOT EXISTS Notes (ID INTEGER PRIMARY KEY AUTOINCREMENT, NoteType TEXT,TagType TEXT, Title TEXT, Note TEXT, Timestamp TEXT, Latitude Text, Longitude Text, Place Text)"
                if !notesDB.executeStatements(sql_stmt) {
                    print("Error: \(notesDB.lastErrorMessage())")
                    successful = false
                }
                else{
                    let sql_stmt = "CREATE TABLE IF NOT EXISTS Tags (TagId INTEGER PRIMARY KEY AUTOINCREMENT, Tag TEXT, TagColor TEXT )"
                    if !notesDB.executeStatements(sql_stmt) {
                        print("Error: \(notesDB.lastErrorMessage())")
                        successful = false
                    }
                }
                notesDB.close()
            } else {
                print("Error: \(notesDB.lastErrorMessage())")
                successful = false
            }
        }
        return successful
    }
    
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.stringByReplacingOccurrencesOfString("#", withString: "")
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func inverseColor(oldColor: UIColor)-> UIColor{
        let components = CGColorGetComponents(oldColor.CGColor)
        
        return UIColor(red: (1.0 - components[0]), green: (1.0 - components[1]), blue: (1.0 - components[2]), alpha: 1.0)
        
    
    }
    
    
    static func hexStringFromColor(color: UIColor)-> String{
        let components = CGColorGetComponents(color.CGColor)
        let r = components[0]
        let g = components[1]
        let b = components[2]
        
        return NSString(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255))) as String
        
        
    }
    

}

extension UIViewController {
    
    // MARK: - Show alert method
    
    func showAlertOnMainThread(message: String) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let alert = UIAlertController(title: "Notes", message: message, preferredStyle: .Alert)
            alert.addAction( UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
}


