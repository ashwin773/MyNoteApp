//
//  LocationService.swift
//  LiveBid
//
//  Created by developer9  on 1/20/16.
//  Copyright © 2016 Sayami. All rights reserved.
//

import Foundation
import CoreLocation


class LocationService: NSObject, CLLocationManagerDelegate {
    
    class var sharedInstance: LocationService {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            
            static var instance: LocationService? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = LocationService()
        }
        return Static.instance!
    }
    
    var locationManager:CLLocationManager?
    var currentLocation:CLLocation?
    
    
    
    override init() {
        super.init()
        self.locationManager = CLLocationManager()
//        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
//        self.locationManager?.distanceFilter = 200
        self.locationManager?.delegate = self
        self.locationManager?.requestWhenInUseAuthorization()
        
        
    }
    
    func isLocationEnabled() -> Bool{
        
               
        if CLLocationManager.locationServicesEnabled(){
            
            if getAuthorizationStatus().rawValue < 3  && getAuthorizationStatus().rawValue > 0{
                
                return false
            }
            else if getAuthorizationStatus().rawValue == 0 {
                
                self.locationManager?.requestWhenInUseAuthorization()
            }
            
            return true
            
        }
        else {
            
            return false
            
        }
        
    }
    
    
    func getAuthorizationStatus() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    func startUpdatingLocation() {
        print("Starting Location Updates")
        self.locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        print("Stop Location Updates")
        self.locationManager?.stopUpdatingLocation()
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: AnyObject? = (locations as NSArray).lastObject
        
        self.currentLocation = location as? CLLocation
        // use for real time update location
        // updateLocation(self.currentLocation)
        
      
        
        NSNotificationCenter.defaultCenter().postNotificationName("receivedLocation", object: nil)
        
        
    }
    
      
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
            print("Update Location Error : \(error.description)")
        NSNotificationCenter.defaultCenter().postNotificationName("errorLocation",object: nil)
        
    }
    
    func updateLocation(currentLocation:CLLocation){
        //let lat = currentLocation.coordinate.latitude
        //let lon = currentLocation.coordinate.longitude
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        
        NSNotificationCenter.defaultCenter().postNotificationName("authorizationStatusChanged", object: nil)
    }
    
}