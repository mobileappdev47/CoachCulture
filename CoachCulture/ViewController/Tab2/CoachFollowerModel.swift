//
//  CoachFollowerModel.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 20/12/21.
//

import Foundation


class CoachSearchList {
    var map: Map!
    var username = ""
    var user_image = ""
    var id = ""
   
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        username = map.value("username") ?? ""
        user_image = map.value("user_image") ?? ""
        id = map.value("id") ?? ""

    }
    
    
    class func getData(data : [Any]) -> [CoachSearchList] {
        
        var arrTemp = [CoachSearchList]()
        for temp in data {
       
            arrTemp.append(CoachSearchList(responseObj: temp as? [String : Any] ?? [String : Any]()))
        }
        
        return arrTemp
    }
}


class CoachInfoData {
    var map: Map!
    var id = ""
    var username = ""
    var user_image = ""
    var monthly_subscription_fee = ""
    var total_followers = ""
    var user_follow = ""
    var user_subscribed = ""
    var base_currency = ""
   
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        id = map.value("id") ?? ""
        username = map.value("username") ?? ""
        user_image = map.value("user_image") ?? ""
        
        monthly_subscription_fee = map.value("monthly_subscription_fee") ?? ""
        total_followers = map.value("total_followers") ?? ""
        user_follow = map.value("user_follow") ?? ""
        user_subscribed = map.value("user_subscribed") ?? ""
        
        let obj = responseObj["fee_regional"] as? [String : Any] ?? [String : Any]()
        base_currency = obj["base_currency"] as? String ??  ""
    }
  
}


class CoachClassInfoList {
    var map: Map!
    var coach_class_type = ""
    var class_type_name = ""
    var id = ""
    var class_subtitle = ""
    var duration = ""
    var created_at = ""
    var status = ""
    var thumbnail_image = ""
    var thumbnail_video = ""
    var total_viewers = ""
    var bookmark = ""
    var created_atFormated = ""
    var class_date = ""
    var class_time = ""
   
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        coach_class_type = map.value("coach_class_type") ?? ""
        class_time = map.value("class_time") ?? ""
        class_date = map.value("class_date") ?? ""
        class_type_name = map.value("class_type_name") ?? ""
        id = map.value("id") ?? ""
        class_subtitle = map.value("class_subtitle") ?? ""
        duration = map.value("duration") ?? ""
        
        status = map.value("status") ?? ""
        thumbnail_image = map.value("thumbnail_image") ?? ""
        thumbnail_video = map.value("thumbnail_video") ?? ""
        total_viewers = map.value("total_viewers") ?? ""
        duration = map.value("duration") ?? ""
        bookmark = map.value("bookmark") ?? ""
        created_at = map.value("created_at") ?? ""
        if !created_at.isEmpty {
            let nsDate = created_at.getDateWithFormate(formate: "yyyy-MM-dd hh:mm:ss", timezone: "UTC")
            created_atFormated = nsDate.getDateStringWithFormate("dd MMM yyyy", timezone: TimeZone.current.abbreviation()!)
        }

    }
    
    
    class func getData(data : [Any]) -> [CoachClassInfoList] {
        
        var arrTemp = [CoachClassInfoList]()
        for temp in data {
       
            arrTemp.append(CoachClassInfoList(responseObj: temp as? [String : Any] ?? [String : Any]()))
        }
        
        return arrTemp
    }
}
