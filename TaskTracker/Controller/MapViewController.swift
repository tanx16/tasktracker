//
//  ViewController.swift
//  TaskTracker
//
//  Created by Tanx on 3/19/19.
//  Copyright © 2019 tanx. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RealmSwift

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    let realm = try! Realm()
    lazy var tasks: Results<Task> = { self.realm.objects(Task.self) }()
    var shownTasks = [Task]()
    var profile: Profile?
    var showAllTasks = true;
    var locationSet = false;

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //addSampleTasks()
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsCompass = false;
        if CLLocationManager.locationServicesEnabled() == true {
            if CLLocationManager.authorizationStatus() == .restricted ||
             CLLocationManager.authorizationStatus() == .denied ||
             CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        } else {
            print("Please turn your location services on!")
        }
        for task in tasks {
            addAnnotation(task: task)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshAnnotations()
    }
    
    private func clearAllTasks() {
        try! realm.write {
        realm.deleteAll()
        }
    }
    
    private func addAnnotation(task: Task) {
        let annotation = taskAnnotation()
        annotation.taskIdentifier = task.identifier
        annotation.coordinate = MapViewController.locToCoord(location: task.location!)
        annotation.title = task.name
        annotation.subtitle = "Every \(task.frequency) days"
        mapView.addAnnotation(annotation)
    }
    
    private func addSampleTasks() {
        clearAllTasks()
        if tasks.count == 0 {
            try! realm.write() {
                let sampleTasks =
                    ["Groceries", "School", "Get stuff", "Brush teeth", "Take out trash" ]
                
                for task in sampleTasks {
                    let newTask = Task()
                    newTask.name = task
                    newTask.location = Location(latitude: 37.872048 +  Double.random(in: -0.003 ..< 0.003), longitude: -122.257833 + Double.random(in: -0.003 ..< 0.003))
                    newTask.frequency = Int.random(in: 1 ..< 7)
                    
                    realm.add(newTask)
                }
            }
            
            tasks = realm.objects(Task.self)
        }
    }
    
    // This should only run when the app starts, not every time location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (!locationSet) {
            let region = MKCoordinateRegion(center: locationManager.location!.coordinate, latitudinalMeters: 1500, longitudinalMeters: 1500)
            self.mapView.setRegion(region, animated: true)
            profile = realm.object(ofType: Profile.self, forPrimaryKey: "userKey")
            if profile == nil {
                profile = Profile(home: MapViewController.coordToLoc(coord: locationManager.location!.coordinate))
                try! realm.write {
                    realm.add(profile!)
                }
            }
            locationSet = true
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if(pinView == nil) {
            pinView = taskAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "viewTaskSegue", sender: view as? taskAnnotationView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UINavigationController,
            let annotationView = sender as? taskAnnotationView {
            let annotation = annotationView.annotation as? taskAnnotation
            let vc = destination.viewControllers.first as? ViewTaskViewController
            vc!.taskIdentifier = annotation!.taskIdentifier!
        }
        
    }
    
    @IBAction func unwindToMapView(_ sender:UIStoryboardSegue) {
        if let senderVC = sender.source as? NewTaskViewController {
            let currLoc: Location = MapViewController.coordToLoc(coord: locationManager.location!.coordinate)
            let newTask = Task(name: senderVC.nameTaskField.text!, taskDescription: senderVC.descriptionField.text!, frequency: senderVC.frequency, duration: 0, location: currLoc)
            try? realm.write {
                realm.add(newTask)
                addAnnotation(task: newTask)
            }
        }
    }
    
    @IBAction func centerLocation(_ sender: Any) {
        let region = MKCoordinateRegion(center: locationManager.location!.coordinate, latitudinalMeters: 1500, longitudinalMeters: 1500)
        self.mapView.setRegion(region, animated: true)
    }
    
    
    @IBAction func toggleDayTasks(_ sender: Any) {
        showAllTasks = !showAllTasks
        if showAllTasks {
            shownTasks = tasks.map{$0}
        }
        else {
            var newTasks = [Task]()
            for task in tasks {
                if task.isDueToday() {
                    newTasks.append(task)
                }
            }
            shownTasks = newTasks
        }
        refreshAnnotations()
    }
    
    public static func locToCoord(location: Location) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }
    
    public static func coordToLoc(coord: CLLocationCoordinate2D) -> Location {
        return Location(latitude: coord.latitude, longitude: coord.longitude)
    }
    
    private func refreshAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        shownTasks = tasks.map{$0}
        for task in shownTasks {
            addAnnotation(task: task)
        }
    }
}

class taskAnnotation : MKPointAnnotation {
    var taskIdentifier: String?
}
class taskAnnotationView: MKPinAnnotationView {  // or nowadays, you might use MKMarkerAnnotationView
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        canShowCallout = true
        rightCalloutAccessoryView = UIButton(type: .infoLight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}