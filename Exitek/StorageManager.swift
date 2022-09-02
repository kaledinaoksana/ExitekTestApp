//
//  StorageManager.swift
//  Exitek
//
//  Created by Oksana Kaledina on 02.09.2022.
//

import Foundation

protocol MobileStorage {
    func getAll() -> Set<Mobile>
    func findByImei(_ imei: String) -> Mobile?
    func save(_ mobile: Mobile) throws -> Mobile
    func delete(_ product: Mobile) throws
    func exists(_ product: Mobile) -> Bool
}

struct Mobile: Hashable{
    let imei: String
    let model: String
}

enum MobileStorageErrors: Error {
    case doesNotInMemory
    case doesNotUniqueIMEI
    case noValueIMEI
    case noValueModel
}

class StorageManager: MobileStorage{
    
    static let shared = StorageManager()
    
    private let defaults = UserDefaults.standard
    private let key = "mobileKey"
    
    func getAll() -> Set<Mobile> {
        
        var mobiles = Set<Mobile>()
        let mobileData = defaults.object(forKey: key) as? [String: String] ?? [String: String]()
        
        for (key, value) in mobileData {
            mobiles.insert(Mobile(imei: key, model: value))
        }
        
        return mobiles
    }
    
    func findByImei(_ imei: String) -> Mobile? {
        
        let mobileData = defaults.object(forKey: key) as? [String: String] ?? [String: String]()
        
        if let model = mobileData[imei]{
            return Mobile(imei: imei, model: model)
        } else {
            return nil
        }
    }
    
    func save(_ mobile: Mobile) throws -> Mobile {
        
        var mobileData = defaults.object(forKey: key) as? [String: String] ?? [String: String]()
        
        if let _ = mobileData[mobile.imei] {throw MobileStorageErrors.doesNotUniqueIMEI}
        if mobile.imei == "" {throw MobileStorageErrors.noValueIMEI}
        if mobile.model == "" {throw MobileStorageErrors.noValueModel}
        
        mobileData[mobile.imei] = mobile.model
        defaults.set(mobileData, forKey: key)
        
        return Mobile(imei: mobile.imei, model: mobile.model)
    }
    
    
    func delete(_ product: Mobile) throws {
        
        var mobileData = defaults.object(forKey: key) as? [String: String] ?? [String: String]()
        
        if exists(product){
            mobileData[product.imei] = nil
        } else {
            throw MobileStorageErrors.doesNotInMemory
        }
       
        defaults.set(mobileData, forKey: key)
    }
    
    func exists(_ product: Mobile) -> Bool {
        
        let mobileData = defaults.object(forKey: key) as? [String: String] ?? [String: String]()
        
        if mobileData[product.imei] == product.model {
            return true
        } else {
            return false
        }
    }
  
}
