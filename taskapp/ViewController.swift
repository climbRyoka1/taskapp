//
//  ViewController.swift
//  taskapp
//
//  Created by 両川昇 on 2019/06/30.
//  Copyright © 2019 両川昇. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController , UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate{

    let realm = try! Realm()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        searchBar.placeholder = "カテゴリーを入力してください"
        searchBar.showsCancelButton = true
    }
    
    
    var taskArray = try!Realm().objects(Task.self).sorted(byKeyPath:"date", ascending: false)
   
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)  {
        searchResult(searchText: searchBar.text! as String)
        view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        taskArray = try!Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
        tableView.reloadData()
    }
    
    func searchResult(searchText: String) {
         taskArray = realm.objects(Task.self).filter("category == %@", searchText)
        print(taskArray)
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("B")
        return taskArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let datestring:String = formatter.string(from:task.date)
        cell.detailTextLabel?.text = datestring
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Cellsegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let task = self.taskArray[indexPath.row]
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "Cellsegue"{
             let inputViewController:InputViewController = segue.destination as! InputViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        }else if segue.identifier == "Categorysegue"{
            let _:CategoryViewController = segue.destination as! CategoryViewController
        }else if segue.identifier == "plussegue"{
            let inputViewController:InputViewController = segue.destination as! InputViewController
            let task = Task()
            task.date = Date()
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0{
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        tableView.reloadData()
    }
}

