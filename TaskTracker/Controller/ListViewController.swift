//
//  ListViewController.swift
//  TaskTracker
//
//  Created by Tanx on 4/17/19.
//  Copyright © 2019 tanx. All rights reserved.
//

import UIKit
import RealmSwift

class ListViewController: UITableViewController {

    let realm = try! Realm()
    lazy var tasks: Results<Task> = { self.realm.objects(Task.self) }()
    @IBOutlet var listViewTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listViewTableView.delegate = self
        listViewTableView.dataSource = self
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        listViewTableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        listViewTableView.reloadData()
    }
    
    @objc func refresh(sender:AnyObject) {
        listViewTableView.reloadData()
        refreshControl!.endRefreshing()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        cell.textLabel?.text = tasks[indexPath.row].name
        cell.detailTextLabel?.text = "Streak: \(tasks[indexPath.row].streak)"
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "listViewSegue", let destination = segue.destination as? UINavigationController {
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                let vc = destination.viewControllers.first as? ViewTaskViewController
                vc!.taskIdentifier = tasks[indexPath.row].identifier
            }
        }
    }

}
