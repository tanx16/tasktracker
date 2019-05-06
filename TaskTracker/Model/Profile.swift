//
//  Profile.swift
//  TaskTracker
//
//  Created by Tanx on 3/30/19.
//  Copyright © 2019 tanx. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift

// TODO: Separate preferences/achievements to another class?
// How to make records for achievements?
class Profile: Object {
    //@objc let tasks = List<Task> ()
    @objc dynamic var identifier = UUID().uuidString
    @objc dynamic var home: Location?
    @objc dynamic var level = 0
    @objc dynamic var exp = 0.0
    @objc dynamic var totalTasksDone = 0 // Increments once for every task completed
    @objc dynamic var dailyStreak = 0 // Increments once when last task due today is finished
    @objc dynamic var longestStreak = 0 // Increments once when last task due today is finished
    @objc dynamic var lastStreak = Date() // Used to check if daily streak is already done today
    convenience init(home: Location) {
        self.init()
        //self.tasks = List<Task> ()
        self.identifier = "userKey"
        self.home = home
        self.level = 0
        self.exp = 0
        self.totalTasksDone = 0
        self.dailyStreak = 0
        self.longestStreak = 0
        self.lastStreak = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    }
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
    
    // Use this to update a user's experience points. Returns whether a user has leveled up.
    func updateExp(amount: Double) -> Bool {
        var hasLeveledUp = false
        self.exp += amount
        while self.exp > nextLevel(level: self.level) {
            hasLeveledUp = true
            self.exp -= nextLevel(level: self.level)
            self.level += 1
        }
        return hasLeveledUp
    }
    
    // used for setting exp bonus
    func distanceFromTask(taskLoc: Location) -> Double {
        let homeLoc = MapViewController.locToCoord(location: home!)
        let taskLoc = MapViewController.locToCoord(location: taskLoc)
        return taskLoc.distance(from: homeLoc)/1000
    }
    
    func updateHomeLocation(newLoc: Location) {
        self.home = newLoc
    }
    
    func getLevel() -> Int {
        return self.level
    }
    
    func getExp() -> Double {
        return self.exp
    }
    
    func getNumTotalTasks() -> Int {
        return self.totalTasksDone
    }
    
    // Returns the task count of the task done most often.
    /*
    func getMostTasksDone() -> Int {
        var ret = 0
        for task in tasks {
            if task.completedCount > ret {
                ret = task.completedCount
            }
        }
        return ret
    }
 */
    
    // Returns exp needed for next level
    private func nextLevel(level: Int) -> Double {
        return round(Double((4 * (level ^ 3)) / 5))
    }
    
}

/*
 Achievement Ideas:
 "Repeat!" : Do a task 5/10/100/1000 times
 "A Long Walk" : Complete a task 1/5/10/100 miles away from home
 "Frequent User" : Do 50/500/5000 total tasks
 "An Apple a Day" : Reach a streak of 7/30/365 days
 "Taskifying..." : Have 5/10/50/100 tasks on the list
 */
