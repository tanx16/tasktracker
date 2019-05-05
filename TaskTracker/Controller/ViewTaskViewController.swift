//
//  ViewTaskViewController.swift
//  TaskTracker
//
//  Created by Tanx on 4/17/19.
//  Copyright © 2019 tanx. All rights reserved.
//

import UIKit
import RealmSwift
import CoreLocation

class ViewTaskViewController: UITableViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    let realm = try! Realm()
    lazy var profile: Profile = realm.object(ofType: Profile.self, forPrimaryKey: "userKey") ?? Profile()
    @IBOutlet weak var nameTask: UILabel!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var lastDoneLabel: UITextField!
    var taskIdentifier: String = ""
    var task: Task?
    var lastLocation: Location?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        task = realm.object(ofType: Task.self, forPrimaryKey: taskIdentifier)
        nameTask.text = task!.name
        descriptionField.text = task!.taskDescription
        frequencyLabel.text = "Every \(task!.frequency) Days"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        lastDoneLabel.text = dateFormatter.string(from: (task?.lastDone)!)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        lastLocation = Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
    
    
    // TODO: Add alert on completion
    @IBAction func completedTask(_ sender: Any) {
        if (task?.isAtLocation(currLocation: lastLocation!))! {
            try! realm.write {
                task?.completedCount += 1
                task?.lastDone = Date()
                if ((task?.isOnStreak())!) {
                    task?.updateStreak(increase: true)
                } else {
                    task?.updateStreak(increase: false)
                }
                profile.totalTasksDone += 1
                if profile.updateExp(amount: task!.expOnCompletion()) {
                    print("Leveled up!")
                }
                if shouldUpdateProfileStreak()  {
                    print("ok")
                    print(profile.lastStreak)
                    print(Date())
                    if !Calendar.current.isDateInToday(profile.lastStreak) {
                        print("ok!")
                        profile.dailyStreak += 1
                        profile.longestStreak = max(profile.dailyStreak, profile.longestStreak)
                        profile.lastStreak = Date()
                    }
                } else {
                    print("hmm")
                    profile.dailyStreak = 0
                }
                realm.add(profile, update: true)
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func doneReturn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editTask(_ sender: Any) {
        performSegue(withIdentifier: "editTaskSegue", sender: self)
    }
    
    @IBAction func unwindToViewTask(_ sender:UIStoryboardSegue) {
        if let senderVC = sender.source as? EditTaskViewController {
            try? realm.write {
                task?.name = senderVC.nameTaskField.text!
                task?.frequency = senderVC.frequency
                task?.taskDescription = senderVC.descriptionField.text!
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func unwindDeleteTask(_ sender:UIStoryboardSegue) {
        if sender.source is EditTaskViewController {
            try? realm.write {
                realm.delete(task!)
            }
            dismiss(animated: true, completion: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navCont = segue.destination as? UINavigationController,
            let _ = sender as? ViewTaskViewController {
            let destination = navCont.viewControllers.first as? EditTaskViewController
            destination!.taskName = task!.name
            destination!.taskDescription = task!.taskDescription
            destination!.frequency = task!.frequency
        }
    }
    
    // Update profile streak if no task is due or overdue
    private func shouldUpdateProfileStreak() -> Bool {
        let checkStreak: Results<Task> = { self.realm.objects(Task.self) }()
        for task in checkStreak {
            if !task.isOnStreak() {
                return false
            }
        }
        return true
    }

}
