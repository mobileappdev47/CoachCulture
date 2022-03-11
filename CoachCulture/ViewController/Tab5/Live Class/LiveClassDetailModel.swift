//
//  LiveClassDetailModel.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 16/12/21.
//

import Foundation

class ClassDetailData {
    var map: Map!
    var id = ""
    var class_completed = false
    var coach_class_type = ""
    var class_subtitle = ""
    var duration = ""
    var class_type = ""
    var class_difficulty = ""
    var feesDataObj = FeesData()
    var burn_calories = ""
    var description = ""
    var arrMuscleGroupList = [MuscleGroupList]()
    var arrEquipmentList = [EquipmentList]()
    var coachDetailsDataObj = CoachDetailsData()
    var created_at = ""
    var created_atForamted = ""
    var user_class_rating = ""
    var user_class_comments = ""
    var bookmark = ""
    var total_viewers = ""
    var thumbnail_image = ""
    var thumbnail_image_path = ""
    var thumbnail_video = ""
    var thumbnail_video_file = ""

    var class_date = ""
    var class_time = ""
    var coachChannelDataObj = CoachChannel()
    var responseDic = [String : Any]()
    var subscription = false
    var coach_class_subscription_id = 0
    var started_at = ""
    
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        self.responseDic = responseObj
        
        id = map.value("id") ?? ""
        started_at = map.value("started_at") ?? ""
        class_completed = map.value("class_completed") ?? false
        coach_class_subscription_id = map.value("coach_class_subscription_id") ?? 0
        coach_class_type = map.value("coach_class_type") ?? ""
        subscription = map.value("subscription") ?? false
        class_subtitle = map.value("class_subtitle") ?? ""
        class_type = map.value("class_type") ?? ""
        duration = map.value("duration") ?? ""
        class_difficulty = map.value("class_difficulty") ?? ""
        feesDataObj = FeesData(responseObj: responseObj["fees"] as? [String : Any] ?? [String : Any]())
        burn_calories = map.value("burn_calories") ?? ""
        description = map.value("description") ?? ""
        thumbnail_video_file = map.value("thumbnail_video_file") ?? ""

        arrMuscleGroupList = MuscleGroupList.getData(data: responseObj["muscle_group"] as? [Any] ?? [Any]())
        arrEquipmentList = EquipmentList.getData(data: responseObj["equipment"] as? [Any] ?? [Any]())
        coachDetailsDataObj = CoachDetailsData(responseObj: responseObj["coach_details"] as? [String : Any] ?? [String : Any]())
        coachChannelDataObj = CoachChannel(responseObj: responseObj["coach_channel"] as? [String : Any] ?? [String : Any]())

        
        created_at = map.value("created_at") ?? ""
        if !created_at.isEmpty {
            let nsDate = created_at.getDateWithFormate(formate: "yyyy-MM-dd hh:mm:ss", timezone: "UTC")
            created_atForamted = nsDate.getDateStringWithFormate("dd MMM yyyy", timezone: "UTC")
        }
        user_class_rating = map.value("user_class_rating") ?? ""
        user_class_comments = map.value("user_class_comments") ?? ""
        bookmark = map.value("bookmark") ?? ""
        total_viewers = map.value("total_viewers") ?? ""
        thumbnail_image = map.value("thumbnail_image") ?? ""
        thumbnail_image_path = map.value("thumbnail_image_path") ?? ""
        thumbnail_video = map.value("thumbnail_video") ?? ""
        class_date = map.value("class_date") ?? ""
        class_time = map.value("class_time") ?? ""


    }
    
    class func getData(data : [Any]) -> [ClassDetailData] {
        
        var arrTemp = [ClassDetailData]()
        for temp in data {
       
            arrTemp.append(ClassDetailData(responseObj: temp as? [String : Any] ?? [String : Any]()))
        }
        
        return arrTemp
    }
}




class FeesData {
    var map: Map!
    var base_subscriber_fee = ""
    var base_non_subscriber_fee = ""
    var base_currency = ""
    var subscriber_fee = ""
    var non_subscriber_fee = ""
    var fee_regional_currency = ""
   
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        base_subscriber_fee = map.value("base_subscriber_fee") ?? ""
        base_non_subscriber_fee = map.value("base_non_subscriber_fee") ?? ""
        base_currency = map.value("base_currency") ?? ""
        subscriber_fee = map.value("subscriber_fee") ?? ""
        non_subscriber_fee = map.value("non_subscriber_fee") ?? ""
        fee_regional_currency = map.value("fee_regional_currency") ?? ""
    }
    
}


class MuscleGroupList {
    var map: Map!
    var muscle_group_id = ""
    var muscle_group_name = ""
   
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        muscle_group_id = map.value("muscle_group_id") ?? ""
        muscle_group_name = map.value("muscle_group_name") ?? ""
    }
    
    
    class func getData(data : [Any]) -> [MuscleGroupList] {
        
        var arrTemp = [MuscleGroupList]()
        for temp in data {
       
            arrTemp.append(MuscleGroupList(responseObj: temp as? [String : Any] ?? [String : Any]()))
        }
        
        return arrTemp
    }
}



class CoachChannel {
    var map: Map!
    var playbackurl = ""
   
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        playbackurl = map.value("playbackurl") ?? ""
        
    }
    
}

class ClassRatingList {
    var map: Map!
    var id = ""
    var coach_class_id = ""
    var rating = ""
    var comments = ""
    var created_at = ""
    var created_atFormated = ""
    var userDataObj = CoachDetailsData()
   
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        id = map.value("id") ?? ""
        coach_class_id = map.value("coach_class_id") ?? ""
        rating = map.value("rating") ?? ""
        comments = map.value("comments") ?? ""
        created_at = map.value("created_at") ?? ""
        if !created_at.isEmpty {
            let nsDate = created_at.getDateWithFormate(formate: "yyyy-MM-dd hh:mm:ss", timezone: "UTC")
            created_atFormated = nsDate.getDateStringWithFormate("dd MMM, yyyy", timezone: TimeZone.current.abbreviation() ?? "")
        }
        userDataObj = CoachDetailsData(responseObj: responseObj["user_id"] as? [String : Any] ?? [String : Any]())
    }
    
    
    class func getData(data : [Any]) -> [ClassRatingList] {
        
        var arrTemp = [ClassRatingList]()
        for temp in data {
       
            arrTemp.append(ClassRatingList(responseObj: temp as? [String : Any] ?? [String : Any]()))
        }
        
        return arrTemp
    }
}
