//
//  HomeViewModel.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 03/12/21.
//

import Foundation

class UpCommingLiveClass {
    var map: Map!
    
    var coach_class_type = ""
    var class_type = ""
    var class_subtitle = ""
    var class_date = ""
    var class_time = ""
    var duration = ""
    var class_bookmark = ""
    var thumbnail_url = ""
    var username = ""
    var user_image = ""
    var classDateFormated = ""
    var classTimeFormated = ""
    
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        coach_class_type = map.value("coach_class_type") ?? ""
        class_type = map.value("class_type") ?? ""
        class_subtitle = map.value("class_subtitle") ?? ""
        class_date = map.value("class_date") ?? ""
        class_time = map.value("class_time") ?? ""
        duration = map.value("duration") ?? ""
        class_bookmark = map.value("class_bookmark") ?? ""
        thumbnail_url = map.value("thumbnail_url") ?? ""
        username = map.value("username") ?? ""
        user_image = map.value("user_image") ?? ""
        
        if !class_date.isEmpty {
            let nsDate = class_date.getDateWithFormate(formate: "yyyy-MM-dd", timezone: "UTC")
            classDateFormated = nsDate.getDateStringWithFormate("dd MMM yyyy", timezone: "UTC")
        }
        
        if !class_time.isEmpty {
            let nsDate = class_time.getDateWithFormate(formate: "hh:mm:ss", timezone: "UTC")
            classTimeFormated = nsDate.getDateStringWithFormate("hh:mm", timezone: "UTC")
        }
        
    }
}


class PopularClassList {
    var map: Map!
    
    var coach_class_type = ""
    var coach_class_id = ""
    var class_subtitle = ""
    var count_coach_class = ""
    var duration = ""
    var class_type = ""
    var thumbnail_url = ""
    var username = ""
    var total_viewers = ""
    var thumbnail_image = ""
    var thumbnail_video = ""

    
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        coach_class_type = map.value("coach_class_type") ?? ""
        coach_class_id = map.value("coach_class_id") ?? ""
        class_subtitle = map.value("class_subtitle") ?? ""
        count_coach_class = map.value("count_coach_class") ?? ""
        duration = map.value("duration") ?? ""
        class_type = map.value("class_type") ?? ""
        
        thumbnail_url = API.BASE_URL
        thumbnail_url += map.value("thumbnail_url") ?? ""
        username = map.value("username") ?? ""
        total_viewers = map.value("total_viewers") ?? ""
        
        thumbnail_image = map.value("thumbnail_image") ?? ""
        thumbnail_video = map.value("thumbnail_video") ?? ""
       
    }
    
    class func getData(data : [Any]) -> [PopularClassList] {
        
        var arrTemp = [PopularClassList]()
        for temp in data {
       
            arrTemp.append(PopularClassList(responseObj: temp as? [String : Any] ?? [String : Any]()))
        }
        
        return arrTemp
    }
}


class PopularTrainerList {
    var map: Map!
    
    var coach_id = ""
    var count_coach = ""
    
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
    var account_currency = ""
    var is_followed = false
    var total_followers = ""
    var feesDataObj = FeesData()
    var is_coach_subscribed = false
    
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        coach_id = map.value("coach_id") ?? ""
        count_coach = map.value("count_coach") ?? ""
        user_image = map.value("user_image") ?? ""
        username = map.value("username") ?? ""
        total_followers = map.value("total_followers") ?? ""
       
        coach_banner_file = map.value("coach_banner_file") ?? ""
        
        coach_trailer_file = map.value("coach_trailer_file") ?? ""
        is_followed = map.value("is_followed") ?? false
        lastName = map.value("lastName") ?? ""
        countrycode = map.value("countrycode") ?? ""
        date_of_birth = map.value("date_of_birth") ?? ""
        email = map.value("email") ?? ""
        account_currency = map.value("account_currency") ?? ""
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
        is_coach_subscribed = map.value("is_coach_subscribed") ?? false
        feesDataObj = FeesData(responseObj: responseObj["fees"] as? [String : Any] ?? [String : Any]())
    }
    
    class func getData(data : [Any]) -> [PopularTrainerList] {
        
        var arrTemp = [PopularTrainerList]()
        for temp in data {
       
            arrTemp.append(PopularTrainerList(responseObj: temp as? [String : Any] ?? [String : Any]()))
        }
        
        return arrTemp
    }
}
