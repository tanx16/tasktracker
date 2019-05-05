//
//  Location.swift
//  TaskTracker
//
//  Created by Tanx on 4/18/19.
//  Copyright © 2019 tanx. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift

class Location: Object {
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    
    convenience init(latitude: Double, longitude: Double) {
        self.init()
        self.latitude = latitude
        self.longitude = longitude
    }
}
