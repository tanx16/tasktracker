//
//  Task.swift
//  TaskTracker
//
//  Created by Tanx on 3/30/19.
//  Copyright © 2019 tanx. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift

class Task: Object {
    @objc dynamic var name = ""
    @objc dynamic var taskDescription = ""
    @objc dynamic var frequency = -1 // Every (frequency) days
    @objc dynamic var duration = 0 // Unused field as of now, implementing timing sometime in the future
    @objc dynamic var streak = 0
    @objc dynamic var lastDone = Date()
    @objc dynamic var location: Location?
    @objc dynamic var completedCount = 0
    @objc dynamic var profile = UUID().uuidString // Unused
    @objc dynamic var identifier = UUID().uuidString
    
    convenience init(name: String, taskDescription: String, frequency: Int, duration: Int, location: Location) {
        self.init()
        self.name = name
        self.taskDescription = taskDescription
        self.frequency = frequency
        self.duration = duration
        self.streak = 0
        self.lastDone = Date() // Make sure that this makes sense!
        self.location = location
        self.completedCount = 0
        self.identifier = UUID().uuidString
    }
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
    
    // TODO: Create approximate radius for detection
    func isAtLocation(currLocation: Location) -> Bool {
        let epsilon = 0.001
        return fabs(currLocation.latitude - location!.latitude) <= epsilon && fabs(currLocation.longitude - location!.longitude) <= epsilon
    }
    
    // Pass in true to add, false to reset.
    func updateStreak(increase: Bool) {
        if increase {
            self.streak += 1
        } else {
            self.streak = 0
        }
    }
    
    // Todo: Make function dependent on distance
    func expOnCompletion() -> Double {
        return (50 + Double(streak)*1.5)
    }
    
    func isOnStreak() -> Bool {
        let endDate = Calendar.current.date(byAdding: .day, value: frequency, to: lastDone)
        // Double check that this works
        return endDate! - Date() > 0
    }
    
    func isDueToday() -> Bool {
        let dueDate = Calendar.current.date(byAdding: .day, value: frequency-1, to: lastDone)
        return Calendar.current.isDateInToday(dueDate!)
    }
}

extension Date {
    
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
}
