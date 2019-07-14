//
//  task.swift
//  taskapp
//
//  Created by 両川昇 on 2019/07/04.
//  Copyright © 2019 両川昇. All rights reserved.
//
import Foundation
import RealmSwift


class Task: Object {
    // 管理用 ID。プライマリーキー
    @objc dynamic var id = 0
    
    // タイトル
    @objc dynamic var title = ""
    
    // 内容
    @objc dynamic var contents = ""
    
    /// 日時
    @objc dynamic var date = Date()
    
    @objc dynamic var category = ""
    
    
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Category: Object {
    
    @objc dynamic var id = 0
    
    @objc dynamic var cate = ""
    
   
}
