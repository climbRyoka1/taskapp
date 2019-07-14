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

class ViewController: UIViewController , UITableViewDataSource, UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate{

    var category : Results<Category>!
    let realm = try! Realm()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryTextField: UITextField!
    
    var categoryPicker : UIPickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        categoryPicker.delegate = self
        categoryPicker.dataSource  = self
        
        category = realm.objects(Category.self)
        
        
        
        let toolber = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action:#selector(cancel))
        toolber.setItems([space,doneButton,cancelButton], animated: true)
        
        categoryTextField.inputView = categoryPicker
        categoryTextField.inputAccessoryView = toolber
    }
    
    
    
    @objc func done(){
        let searchCategory = categoryTextField.text
        taskArray = realm.objects(Task.self).filter("category == %@", searchCategory!)
        tableView.reloadData()
        view.endEditing(true)
    }
    
    @objc func cancel(){
        taskArray = try!Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
        tableView.reloadData()
        
    }
    
    var taskArray = try!Realm().objects(Task.self).sorted(byKeyPath:"date", ascending: false)
   
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let category = category{
            return category.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let category = category{
            return category[row].cate
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTextField.text = category[row].cate
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
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

