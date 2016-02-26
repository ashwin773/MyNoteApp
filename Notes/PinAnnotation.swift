//
//  PinAnnotation.swift
//  Notes
//
//  Created by Ebpearls on 2/23/16.
//  Copyright © 2016 Ebpearls. All rights reserved.
//

import MapKit
import Foundation
import UIKit

class PinAnnotation : NSObject, MKAnnotation {
    private var coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var noteDetail: Array<String>?
    var coordinate: CLLocationCoordinate2D {
        get {
            return coord
        }
    }
    var item : Int?
    
    var title: String?
    var subtitle: String?
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        self.coord = newCoordinate
    }
}
