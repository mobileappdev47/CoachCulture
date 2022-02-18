//
//  LoginModel.swift
//   
//
//  Created by PC on 17/06/19.
//  Copyright © 2019 Dhaval Bhanderi. All rights reserved.
//

import Foundation


class UserData {
    var map: Map!
    
    var coach_banner_file = ""
    var coach_trailer_file = ""
    var lastName = ""
    var countrycode = ""
    var date_of_birth = ""
    var email = ""
    var first_name = ""
    var id = ""
    var last_name = ""
    var login_type = ""
    var monthly_subscription_fee = ""
    var nationality = ""
    var phonecode = ""
    var phoneno = ""
    var user_image = ""
    var username = ""
    var base_currency = ""
    var is_followed = false
    var total_followers = ""
    var feesDataObj = FeesData()
    
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        coach_banner_file = map.value("coach_banner_file") ?? ""
        
        coach_trailer_file = map.value("coach_trailer_file") ?? ""
        is_followed = map.value("is_followed") ?? false
        lastName = map.value("lastName") ?? ""
        countrycode = map.value("countrycode") ?? ""
        date_of_birth = map.value("date_of_birth") ?? ""
        email = map.value("email") ?? ""
        first_name = map.value("first_name") ?? ""
        id = map.value("id") ?? ""
        last_name = map.value("last_name") ?? ""
        login_type = map.value("login_type") ?? ""
        monthly_subscription_fee = map.value("monthly_subscription_fee") ?? ""
        nationality = map.value("nationality") ?? ""
        phonecode = map.value("phonecode") ?? ""
        username = map.value("username") ?? ""
        user_image = map.value("user_image") ?? ""
        phoneno = map.value("phoneno") ?? ""
        base_currency = map.value("base_currency") ?? ""
        total_followers = map.value("total_followers") ?? ""
        feesDataObj = FeesData(responseObj: responseObj["fees"] as? [String : Any] ?? [String : Any]())
    }
}


class CountryData {
    var map: Map!
    
    var country_nm = ""
    var currency_code = ""
    var currency_symbol = ""
    var type = ""
    
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        
        country_nm = map.value("country_nm") ?? ""
        currency_code = map.value("currency_code") ?? ""
        currency_symbol = map.value("currency_symbol") ?? ""
        type = map.value("type") ?? ""
        
    }
    
    class func getData(data : [Any]) -> [CountryData] {
        
        var arrTemp = [CountryData]()
        for temp in data {
            let dataObj = CountryData(responseObj: temp as? [String : Any] ?? [String : Any]())
            
            arrTemp.append(CountryData(responseObj: temp as? [String : Any] ?? [String : Any]()))
        }
        
        return arrTemp
    }
}
