//
//  MapNoteViewController.swift
//  Notes
//
//  Created by Ebpearls on 2/23/16.
//  Copyright © 2016 Ebpearls. All rights reserved.
//

import UIKit
import MapKit

class MapNoteViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var viewRegion: MKCoordinateRegion?
    var adjustedRegion :  MKCoordinateRegion?
    var lastLat,lastLong:Double?
   
    @IBOutlet weak var noteTableView: UITableView!
    
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var noteDetailBottomConstraint: NSLayoutConstraint!
    
    var noteArray: Array<AnyObject> = Array<AnyObject>()
    var todisplayArray: Array<AnyObject> = Array<AnyObject>()
    var isNoteViewShowing = false
    
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTableView.rowHeight = UITableViewAutomaticDimension // dynamic table cell height here
        noteTableView.estimatedRowHeight = 60.0

        putMarker()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
    }

   
    @IBAction func backBtnClick(sender: UIButton) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
    func deleteNote(sender:UIButton){
        
       
        let itemId = sender.tag
        
        for (i,note )in todisplayArray.enumerate(){
            let content = note as! Array<String>
            if Int(content[0]) == itemId{
                
                let indexPath = NSIndexPath(forRow: i, inSection: 0)
                self.deleteNote(String(itemId), item: indexPath, row: i) // params itemId= id for item to delete from database , item = IndexPath to remove from table, row = to delete from table
                break
            }
            
        }
       
        
    }

}

extension MapNoteViewController: MKMapViewDelegate{
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? PinAnnotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                    dequeuedView.annotation = annotation
                    view = dequeuedView
                    
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            view.tag = annotation.item!
            return view
        }
        return nil
    }
    
    
    func putMarker(){
        
        for (_, note) in noteArray.enumerate() {
            let singleNote = note as! Array<String>
            let latitude =  Double(singleNote[6])
            let longitude = Double(singleNote[7])
            let marker = PinAnnotation()
            marker.setCoordinate(CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!))
            marker.item = Int(singleNote[0])
            mapView.addAnnotation(marker)
            lastLat = latitude!
            lastLong = longitude!
        }
        centerMapOnLocation(CLLocation(latitude: lastLat!, longitude: lastLong!))
    }
    
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        let noteIdQuery = view.tag
        for (i,note) in noteArray.enumerate(){
            let singleNote = note as! Array<String>
            
            if Int(singleNote[0]) == noteIdQuery{
                self.updateTable(i)
                break
            }
        }
        
        
        
    }
    
    func updateTable(noteItem: Int){
        let singleNote = noteArray[noteItem] as! Array<String>
        
        let queryLat = singleNote[6]
        let queryLong = singleNote[7]
        todisplayArray = Array<AnyObject>()
        for everyNote in noteArray{
            let everySingleNote = everyNote as! Array<String>
            if everySingleNote[6] == queryLat && everySingleNote[7] == queryLong{
                todisplayArray.append(everySingleNote)
            }
        }
        self.noteTableView.reloadData()
        
        if isNoteViewShowing{
            
        }
        else{
            self.isNoteViewShowing=true
            self.noteDetailBottomConstraint.constant = 0.0
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: {
                self.view.layoutIfNeeded()
                }, completion:{ finished in
                    
            })
            
        }
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        if !isNoteViewShowing{
            
        }
        else{
            self.isNoteViewShowing=false
            self.noteDetailBottomConstraint.constant = -300.0
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: {
                self.view.layoutIfNeeded()
                }, completion:{ finished in
                    
            })
            
        }
        
    }
    
}

extension MapNoteViewController:UITableViewDataSource, UITableViewDelegate{
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:SingleNoteCellTableViewCell = tableView.dequeueReusableCellWithIdentifier("SingleNoteCell")! as! SingleNoteCellTableViewCell
        let item = todisplayArray[indexPath.row] as! Array<String>
        cell.configureData(item)
        cell.noteBtn.tag = Int(item[0])!
        cell.noteBtn.addTarget(self, action: "deleteNote:", forControlEvents: .TouchUpInside)
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count = 0
        count = todisplayArray.count
        if count <= 5{
            self.viewHeightConstraint.constant = CGFloat(count * 60)
        }
        else{
            self.viewHeightConstraint.constant = 300.0
        }
        
               return count
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
         let singleNoteVC = self.storyboard?.instantiateViewControllerWithIdentifier("SingleNoteVC") as! SingleNoteViewController
        singleNoteVC.note = todisplayArray[indexPath.row] as! Array<String>
        self.navigationController?.pushViewController(singleNoteVC, animated: true)
        
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.01
        
    }
    
    
}

extension MapNoteViewController{
    
    func deleteNote(itemId: String, item : NSIndexPath,row: Int){
        
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
                self.todisplayArray.removeAtIndex(row)
                //not good way to implement but
                
                for (i,note) in noteArray.enumerate(){
                    let singlenote = note as! Array<String>
                    if singlenote[0] == itemId{
                       noteArray.removeAtIndex(i)
                       
                    }
                }
                
                //now remove marker
                
                    let annotations = mapView.annotations
                    for singleAnnotation in annotations{
                        if singleAnnotation is PinAnnotation{
                            let view = mapView.viewForAnnotation(singleAnnotation)
                            print(view?.tag)
                            print(row)
                            if view?.tag == Int(itemId){
                                mapView.removeAnnotation(singleAnnotation)
                            }
                        }
                    }
                
                
                //
                
                
                
                
                self.noteTableView.deleteRowsAtIndexPaths([item], withRowAnimation: .Automatic)
                self.showAlertOnMainThread("Note Deleted")
            }
            
        }
        else{
            print("Error: \(notesDB.lastErrorMessage())")
            
        }
    }

    
}



