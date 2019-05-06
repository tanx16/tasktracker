//
//  ProfileViewController.swift
//  TaskTracker
//
//  Created by Tanx on 4/17/19.
//  Copyright © 2019 tanx. All rights reserved.
//

import UIKit
import RealmSwift
import CoreLocation
import GaugeKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var mostTasksGauge: Gauge!
    @IBOutlet weak var mostTasksLabel: UILabel!
    @IBOutlet weak var longestDistGauge: Gauge!
    @IBOutlet weak var longestDistLabel: UILabel!
    @IBOutlet weak var totalTasksGauge: Gauge!
    @IBOutlet weak var totalTasksLabel: UILabel!
    @IBOutlet weak var longestStreakGauge: Gauge!
    @IBOutlet weak var longestStreakLabel: UILabel!
    
    let realm = try! Realm()
    lazy var tasks: Results<Task> = { self.realm.objects(Task.self) }()
    lazy var profile: Profile = realm.object(ofType: Profile.self, forPrimaryKey: "userKey") ?? Profile()
    @IBOutlet weak var mostDoneTask: UILabel!
    @IBOutlet weak var currentDailyStreak: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mostDoneTask.text = "Most completed task: \(getMostDoneTask().name)"
        if profile.dailyStreak == 1 {
            currentDailyStreak.text = "Current daily streak: \(profile.dailyStreak) day"
        } else {
            currentDailyStreak.text = "Current daily streak: \(profile.dailyStreak) days"
        }
        setAchievements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewDidLoad()
    }
    
    private func setAchievements() {
        let mostDoneCount = getMostDoneTask().completedCount
        while mostDoneCount >= Int(mostTasksGauge.maxValue) {
            mostTasksGauge.maxValue *= 5
        }
        mostTasksLabel.text = "\(mostDoneCount)/\(Int(mostTasksGauge.maxValue)) times"
        mostTasksGauge.animateRate(2.0, newValue: CGFloat(mostDoneCount), completion: {_ in})
        
        let longestDistCount = longestDistance()
        while longestDistCount >= Double(longestDistGauge.maxValue) {
            longestDistGauge.maxValue *= 5
        }
        longestDistLabel.text = "\(Double(round(100*longestDistCount)/100))/\(Int(longestDistGauge.maxValue)) km"
        longestDistGauge.animateRate(2.0, newValue: CGFloat(longestDistCount), completion: {_ in})
        
        let totalTaskCount = totalTasksDone()
        while totalTaskCount >= Int(totalTasksGauge.maxValue) {
            totalTasksGauge.maxValue *= 5
        }
        totalTasksLabel.text = "\(totalTaskCount)/\(Int(totalTasksGauge.maxValue)) tasks"
        totalTasksGauge.animateRate(2.0, newValue: CGFloat(totalTaskCount), completion: {_ in})
        
        let longestStreakCount = longestStreak()
        while longestStreakCount >= Int(longestStreakGauge.maxValue) {
            longestStreakGauge.maxValue *= 5
        }
        longestStreakLabel.text = "\(longestStreakCount)/\(Int(longestStreakGauge.maxValue)) days"
        longestStreakGauge.animateRate(2.0, newValue: CGFloat(longestStreakCount), completion: {_ in})
    }
    
    // MARK: - Achievemnts
    
    
    // "Repeat!" : Do a task 5/10/100/1000 times
    private func getMostDoneTask() -> Task {
        var maxTask: Task = Task()
        for task in tasks {
            if task.completedCount > maxTask.completedCount {
                maxTask = task
            }
        }
        return maxTask
    }
    
    // "A Long Walk" : Complete a task 1/5/10/100 km away from home
    // Returns in km
    private func longestDistance() -> Double {
        var maxDistance: Double = -1
        let homeLoc = MapViewController.locToCoord(location: profile.home!)
        for task in tasks {
            let taskLoc = MapViewController.locToCoord(location: task.location!)
            let distance = taskLoc.distance(from: homeLoc)
            if distance > maxDistance {
                maxDistance = distance
            }
        }
        return maxDistance/1000
    }
    
    // "Frequent User" : Do 50/500/5000 total tasks
    private func totalTasksDone() -> Int {
        return profile.totalTasksDone
    }
    
    // "An Apple a Day" : Reach a daily streak of 7/30/365 days
    private func longestStreak() -> Int {
        return profile.longestStreak
    }
    
    //"Taskifying..." : Have 5/10/50/100 tasks on the list
    private func totalTasksAdded() -> Int {
        return tasks.count
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension CLLocationCoordinate2D {
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let destination=CLLocation(latitude:from.latitude,longitude:from.longitude)
        return CLLocation(latitude: latitude, longitude: longitude).distance(from: destination)
    }
}
