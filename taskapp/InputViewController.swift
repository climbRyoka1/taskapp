//
//  InputViewController.swift
//  taskapp
//
//  Created by 両川昇 on 2019/06/30.
//  Copyright © 2019 両川昇. All rights reserved.
//

import UIKit
import  RealmSwift
import UserNotifications

class InputViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var contentsLabel: UILabel!
    
    var task:Task!
    var category : Results<Category>!
    let dateformatter = DateFormatter()
    let realm = try! Realm()
    
    var datePicker : UIDatePicker = UIDatePicker()
    var categoryPicker : UIPickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        category = realm.objects(Category.self)
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        dateTextField.inputView = datePicker
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        categoryTextField.inputView = categoryPicker
        
        let tapGestuere : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGestuere)
        
        let toolber = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolber.setItems([space,doneButton], animated: true)
        
        dateTextField.inputAccessoryView = toolber
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        categoryTextField.text = task.category
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm"
        contentsLabel.text = "\(dateformatter.string(from: task.date)) 内容"
    }
    
    @objc func dateChanged(datePicker : UIDatePicker){
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateTextField.text = dateformatter.string(from: datePicker.date)
        contentsLabel.text = "\(dateformatter.string(from: datePicker.date)) 内容"
    }
    
    @objc func done(){
        view.endEditing(true)
    }

    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = titleTextField.text!
            self.task.contents = contentsTextView.text
            self.task.category = categoryTextField.text!
            self.task.date = datePicker.date
            self.realm.add(self.task, update: true)
        }
        setNotification(task: task)
        super.viewWillDisappear(animated)
    }
    
    func setNotification(task:Task){
        let content = UNMutableNotificationContent()
        
        if task.title == ""{
            content.title = "(タイトルなし)"
        }else{
            content.title = task.title
        }
        if task.contents == ""{
            content.body = "(内容なし)"
        }else{
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default
        
        let calendar = Calendar.current
        let datecomponents = calendar.dateComponents([.year,.month,.day,.hour,.minute],from:task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: datecomponents, repeats: false)
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request){(error)in print(error ?? "ローカル通知登録0K")
            center.getPendingNotificationRequests{
                (requests:[UNNotificationRequest]) in
                for request in requests{
                    print("/---------------")
                    print(request)
                    print("---------------/")
                    
                }
        
            }
    }
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
