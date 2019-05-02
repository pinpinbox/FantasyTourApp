//)
//  FavListManager.swift
//  FantasyTourApp
//
//  Created by Antelis on 2019/4/25.
//  Copyright © 2019 . All rights reserved.
//

import Foundation
import RealmSwift

class FavouriteItem : Object {
    
    @objc dynamic var tourId : String = ""
    // save a model or raw JSON ?
    @objc dynamic var json : String = ""
    
    override static func primaryKey() -> String? {
        return "tourId"
    }
    
}

public class FavListManager {
    
    public static var realm : Realm? {
        do {
            return try Realm()
        } catch {
            return nil
        }
        
    }
        
    static func addToFavourite(_ tourId: String, _ json : String) {
        do {
            
            try FavListManager.realm?.write {
                let f = FavouriteItem()
                f.tourId = tourId
                f.json = json
                FavListManager.realm?.add(f)
            }
        } catch let error {
            print("write error : \(error)")
        }
    }
    static func deleteFavItemWithKey(_ tourId: String) -> Bool {
        do{
            if let obj = FavListManager.realm?.object(ofType: FavouriteItem.self, forPrimaryKey: tourId) {
                try FavListManager.realm?.write {
                    FavListManager.realm?.delete(obj)
                }
                
            } else {
                return false
            }
        } catch let error {
            print("delete Error \(error)")
            return false
        }
        
        return true
    }
    static func deleteFavItem(_ tour: FavouriteItem) {
        do {
            try FavListManager.realm?.write {
                FavListManager.realm?.delete(tour)
            }
            
        } catch let error {
                print("delete Error \(error)")
        }
    }
    static func getFavList() -> Array<FavouriteItem> {
        
        if let l = FavListManager.realm?.objects(FavouriteItem.self) {
            let list = Array<FavouriteItem>(l)
            return list
        }
        
        return []
    }
    
    static func isInFavList(_ tourId: String) -> Bool {
        if let _ = FavListManager.realm?.object(ofType: FavouriteItem.self, forPrimaryKey: tourId) {
            return true
        }
        
        return false
    }
    
}
