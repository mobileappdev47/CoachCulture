//
//  SMCountry.swift
//  RedButton
//
//  Created by Zignuts Technolab on 30/03/18.
//  Copyright © 2018 Zignuts Technolab. All rights reserved.
//

import UIKit

struct Country {
    var code: String?
    var name: String?
    var phoneCode: String?
    var currencySymbol: String?
    var currencyCode: String?
    var currencyDesc: String?
    var flag: UIImage? {
        guard let code = self.code else { return nil }
        return UIImage.init(named: "SwiftCountryPicker.bundle/Images/\(code.uppercased())", in: nil, compatibleWith: nil)
    }
    
    init(code: String?, name: String?, phoneCode: String?, currencySymbol: String?, currencyCode: String?, currencyDesc: String?) {
        self.code = code
        self.name = name
        self.phoneCode = phoneCode
        self.currencySymbol = currencySymbol
        self.currencyCode = currencyCode
        self.currencyDesc = currencyDesc
    }
}

class SMCountry: NSObject {
    
    fileprivate var arrCountrycode = [Country]()
    class var shared : SMCountry {
        struct Static {
            static let instance : SMCountry = SMCountry()
        }
        return Static.instance
    }
    
    // Populates the metadata from the included json file resource
    
    func getAllCountry(withreload:Bool) -> [Country] {
        if withreload == false && arrCountrycode.count != 0 {
            return arrCountrycode
        }
        
        arrCountrycode.removeAll()
        let frameworkBundle = Bundle(for: type(of: self))
        guard let jsonPath = frameworkBundle.path(forResource: "SwiftCountryPicker.bundle/Data/countryCodes", ofType: "json"), let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)) else {
            return arrCountrycode
        }
        let enLocale = Locale(identifier: "en")
        do {
            if let jsonObjects = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? NSArray {
                
                for jsonObject in jsonObjects {
                    
                    guard let countryObj = jsonObject as? NSDictionary else {
                        return arrCountrycode
                    }
                    
                    guard let code = countryObj["code"] as? String, let phoneCode = countryObj["dial_code"] as? String, let name = countryObj["name"] as? String else {
                        return arrCountrycode
                    }
                    let loc = Locale(identifier: "_\(code)")
                    let curCode = loc.currencyCode ?? "USD"
                    let currencyDec = enLocale.localizedString(forCurrencyCode: curCode)
                    let country = Country(code: code, name: name, phoneCode: phoneCode, currencySymbol: loc.currencySymbol, currencyCode: curCode, currencyDesc: currencyDec)
                    arrCountrycode.append(country)
                }
                
            }
        } catch {
            return arrCountrycode
        }
        return arrCountrycode
    }
    
    func getinfoUsingCountryCode(code:String) -> Country? {
        let allCountry = self.getAllCountry(withreload: false)
        let arrResult = allCountry.filter { (objCountry) -> Bool in
            return objCountry.code?.lowercased() == code.lowercased()
        }
        
        if  arrResult.count != 0 {
            return arrResult.first
        }
        
        return nil
    }
}
/*
struct Ingredient {
    var name: String?
    var id: Int?
    
    init(name: String?, id: Int?) {
        self.name = name
        self.id = id
    }
}

class SMIngredint: NSObject {
    
    fileprivate var arrIngredient = [Ingredient]()
    class var shared : SMIngredint {
        struct Static {
            static let instance : SMIngredint = SMIngredint()
        }
        return Static.instance
    }
    
    // Populates the metadata from the included json file resource
    
    func getAllCountry(withreload:Bool) -> [Ingredient] {
        if withreload == false && arrIngredient.count != 0 {
            return arrIngredient
        }
        
        arrIngredient.removeAll()
        let frameworkBundle = Bundle(for: type(of: self))
        guard let jsonPath = frameworkBundle.path(forResource: "SwiftCountryPicker.bundle/Data/countryCodes", ofType: "json"), let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)) else {
            return arrIngredient
        }
        
        do {
            if let jsonObjects = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? NSArray {
                
                for jsonObject in jsonObjects {
                    
                    guard let countryObj = jsonObject as? NSDictionary else {
                        return arrIngredient
                    }
                    
                    guard let code = countryObj["code"] as? String, let phoneCode = countryObj["dial_code"] as? String, let name = countryObj["name"] as? String else {
                        return arrIngredient
                    }
                    let loc = Locale(identifier: "_\(code)")
                    let curCode = loc.currencyCode ?? "USD"
//                    let ingredient = Ingredient(name: <#String?#>, id: <#Int?#>)
//                    arrIngredient.append(ingredient)
                }
                
            }
        } catch {
            return arrIngredient
        }
        return arrIngredient
    }
    
    /*func getinfoUsingCountryCode(code:String) -> Country? {
        let allCountry = self.getAllCountry(withreload: false)
        let arrResult = allCountry.filter { (objCountry) -> Bool in
            return objCountry.code?.lowercased() == code.lowercased()
        }
        
        if  arrResult.count != 0 {
            return arrResult.first
        }
        
        return nil
    }*/
}
*/
