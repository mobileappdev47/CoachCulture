//
//  PreviousClassModel.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 22/12/21.
//

import Foundation


class CoachClassPrevious {
    var map: Map!
    var id = ""
    var coach_class_type = ""
    var class_subtitle = ""
    var duration = ""
    var status = ""
    var thumbnail_image = ""
    var thumbnail_video = ""
    var bookmark = ""
    var total_viewers = ""
    var class_time = ""
    var class_date = ""
    var class_type_name = ""
    var class_difficulty_name = ""
    var coachDetailsObj = CoachDetailsData()
    var userRatingObj = UserRating()

   
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        id = map.value("id") ?? ""
        thumbnail_image = map.value("thumbnail_image") ?? ""
        coach_class_type = map.value("coach_class_type") ?? ""
        class_subtitle = map.value("class_subtitle") ?? ""
        duration = map.value("duration") ?? ""
        coachDetailsObj = CoachDetailsData(responseObj: responseObj["coach"] as? [String : Any] ?? [String : Any]())
        userRatingObj = UserRating(responseObj: responseObj["user_rating"] as? [String : Any] ?? [String : Any]())
        total_viewers = map.value("total_viewers") ?? ""
        thumbnail_video = map.value("thumbnail_video") ?? ""
        class_type_name = map.value("class_type_name") ?? ""
        status = map.value("status") ?? ""
        bookmark = map.value("bookmark") ?? ""
        class_difficulty_name = map.value("class_difficulty_name") ?? ""
        class_time = map.value("class_time") ?? ""
        class_date = map.value("class_date") ?? ""


    }
    
    
    class func getData(data : [Any]) -> [CoachClassPrevious] {
        
        var arrTemp = [CoachClassPrevious]()
        for temp in data {
       
            arrTemp.append(CoachClassPrevious(responseObj: temp as? [String : Any] ?? [String : Any]()))
        }
        
        return arrTemp
    }
}


class UserRating {
    var map: Map!
    var comments = ""
    var rating = ""
   
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        comments = map.value("comments") ?? ""
        rating = map.value("rating") ?? ""
        
    }
   
}


class ClassDate {
    var date = ""
    var strDate = ""
}
