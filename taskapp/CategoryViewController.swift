//
//  CategoryViewController.swift
//  taskapp
//
//  Created by 両川昇 on 2019/07/09.
//  Copyright © 2019 両川昇. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class CategoryViewController: UIViewController{

    @IBOutlet weak var categoryName: UITextField!
    @IBOutlet weak var categoryTableView: UITableView!
    
    var categoryText = String()
    var category : Category!
    var categoryList : Results<Category>!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryTableView.dataSource = self
        self.categoryList = realm.objects(Category.self)
        
        let tapGestuere : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGestuere)        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func addButton(_ sender: Any) {
        let categoryInstance :Category = Category()
        categoryInstance.cate = self.categoryName.text!
        let realmDB = try! Realm()
        try! realmDB.write{
        realmDB.add(categoryInstance)
        }
        categoryName.text = ""
        self.categoryTableView.reloadData()
    }
}

extension CategoryViewController:UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        let categoryItem:Category = self.categoryList[indexPath.row]
        cell.textLabel?.text = categoryItem.cate
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
   
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let category = self.categoryList[indexPath.row]
            try! realm.write{
                self.realm.delete(category)
                tableView.deleteRows(at: [indexPath], with: .fade)
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


