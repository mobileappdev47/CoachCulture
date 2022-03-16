//
//  AppPrefsManager.swift
//  ProjectStructure

import UIKit
import CoreLocation


class AppPrefsManager: NSObject
{
    
    static let sharedInstance = AppPrefsManager()
    
    let USER_DATA            =   "USER_DATA"
    let IS_USER_LOGIN_KEY           =   "IS_USER_LOGIN"
    let SAVE_USER_TOKEN           =   "SAVE_USER_TOKEN"
    let SAVE_USER_ROLE           =   "SAVE_USER_ROLE"
    let CLASS_DATA           =   "CLASS_DATA"
    let SELECTED_PREFFERED_CARD = "SELECTED_PREFFERED_CARD"
    
    func setDataToPreference(data: AnyObject, forKey key: String)
    {
        let archivedData = NSKeyedArchiver.archivedData(withRootObject: data)
        UserDefaults.standard.set(archivedData, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func getDataFromPreference(key: String) -> AnyObject?
    {
        let archivedData = UserDefaults.standard.object(forKey: key)
        
        if(archivedData != nil)
        {
            return NSKeyedUnarchiver.unarchiveObject(with: archivedData! as! Data) as AnyObject?
        }
        return nil
    }
    
    func removeDataFromPreference(key: String)
    {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func isKeyExistInPreference(key: String) -> Bool
    {
        if(UserDefaults.standard.object(forKey: key) == nil)
        {
            return false
        }
        
        return true
    }
    
    //MARK: - Device token
    
    func saveSelectedPrefferedCardData(userData: [String:Any]) {
        setDataToPreference(data: userData as AnyObject, forKey: SELECTED_PREFFERED_CARD)
    }

    func getSelectedPrefferedCardData() -> StripeCardsDataModel? {
        return StripeCardsDataModel(responseObj: getDataFromPreference(key: SELECTED_PREFFERED_CARD) as? [String:Any] ?? [String:Any]())
    }

    func saveUserData(userData: [String:Any])
    {
        setDataToPreference(data: userData as AnyObject, forKey: USER_DATA)
    }
    
    func getUserDataJson() -> [String:Any]
    {
        return getDataFromPreference(key: USER_DATA) as? [String:Any] ?? [String:Any]()
    }
    
    func getUserData() -> UserData
    {
        return UserData(responseObj: getDataFromPreference(key: USER_DATA) as? [String:Any] ?? [String:Any]())
    }
        
    
    //MARK: - saveOrganizationData
    func saveUserAccessToken(token: String)
    {
        setDataToPreference(data: token as AnyObject, forKey: SAVE_USER_TOKEN)
    }
    
    func getUserAccessToken() -> String
    {
        return getDataFromPreference(key: SAVE_USER_TOKEN) as? String ?? ""
    }
    
    //MARK: - User login boolean
    func setIsUserLogin(isUserLogin: Bool)
    {
        setDataToPreference(data: isUserLogin as AnyObject, forKey: IS_USER_LOGIN_KEY)
    }
    
    func isUserLogin() -> Bool
    {
        let isUserLogin = getDataFromPreference(key: IS_USER_LOGIN_KEY)
        return isUserLogin == nil ? false:(isUserLogin as! Bool)
    }
    
    //MARK: - User role
    func saveUserRole(role: String)
    {
        setDataToPreference(data: role as AnyObject, forKey: SAVE_USER_ROLE)
    }
    
    func getUserRole() -> String
    {
        return getDataFromPreference(key: SAVE_USER_ROLE) as? String ?? ""
    }
    
    //MARK: - Device token
    func saveClassData(classData: [Any])
    {
        setDataToPreference(data: classData as AnyObject, forKey: CLASS_DATA)
    }
    
    func getClassDataJson() -> [Any]
    {
        return getDataFromPreference(key: CLASS_DATA) as? [Any] ?? [Any]()
    }
    
    func getClassData() -> [ClassDetailData]
    {
        return ClassDetailData.getData(data: getDataFromPreference(key: CLASS_DATA) as? [Any] ?? [Any]())
    }
    
    
}
