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

class ProfileViewController: UIViewController {
    
    let realm = try! Realm()
    lazy var tasks: Results<Task> = { self.realm.objects(Task.self) }()
    lazy var profile: Profile = realm.object(ofType: Profile.self, forPrimaryKey: "userKey") ?? Profile()
    @IBOutlet weak var mostDoneTask: UILabel!
    @IBOutlet weak var currentDailyStreak: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mostDoneTask.text = "Most done task: \(getMostDoneTask().name)"
        if profile.dailyStreak == 1 {
            currentDailyStreak.text = "Current daily streak: \(profile.dailyStreak) day"
        } else {
            currentDailyStreak.text = "Current daily streak: \(profile.dailyStreak) days"
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewDidLoad()
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
    
    // "A Long Walk" : Complete a task 1/5/10/100 miles away from home
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
        return maxDistance
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
