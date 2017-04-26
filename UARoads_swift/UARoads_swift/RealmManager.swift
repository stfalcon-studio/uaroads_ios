//
//  RealmManager.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/20/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import RealmSwift

final class RealmManager {
    init() {
        self.realm = try? Realm()
    }
    
    public let realm: Realm?
    
    public func objects<T: Object>(type: T.Type) -> Results<T>? {
        return realm?.objects(type)
    }
    
    public func deleteAll() {
        try! realm?.write {
            realm?.deleteAll()
        }
    }
    
    public func add(_ obj: Object?) {
        if let obj = obj {
            try! realm?.write {
                realm?.add(obj, update: true)
            }
        }
    }
    
    public func delete(_ obj: Object?) {
        if let obj = obj {
            try! realm?.write({
                realm?.delete(obj)
            })
        }
    }
    
    public func update(updateBlock: () -> ()) {
        try! realm?.write(updateBlock)
    }
}
