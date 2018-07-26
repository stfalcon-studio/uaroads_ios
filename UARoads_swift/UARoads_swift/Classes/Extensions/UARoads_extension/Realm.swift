//
//  Realm.swift
//
//  Created by Victor Amelin on 2/23/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import RealmSwift

public extension Object {
    public func add() {
        let realm = try? Realm()
        try! realm?.write {
            realm?.add(self, update: true)
        }
    }
    
    public func delete() {
        let realm = try? Realm()
        try! realm?.write({
            realm?.delete(self)
        })
    }
    
    public func update(updateBlock: () -> ()) {
        let realm = try? Realm()
        try! realm?.write(updateBlock)
    }
}

public class RealmHelper {
    private init() {}
    
    public class func objects<T: Object>(type: T.Type) -> Results<T>? {
        let realm = try? Realm()
        return realm?.objects(type)
    }
    
    public class func deleteAll() {
        let realm = try? Realm()
        try! realm?.write {
            realm?.deleteAll()
        }
    }
}










