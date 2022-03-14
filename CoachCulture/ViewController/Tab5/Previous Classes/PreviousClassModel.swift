//
//  PreviousClassModel.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 22/12/21.
//

import Foundation

class UserWorkoutStatisticsModel {
    var map: Map!
    
    var allDataObj = AllModel()
    var arrWeeklyDataObj = [AllModel]()
    
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        
        allDataObj = AllModel(responseObj: responseObj["all"] as? [String : Any] ?? [String : Any]())
        
        if let arrWeekly = responseObj["weekly"] as? [[String : Any]] {
            for temp in arrWeekly {
                arrWeeklyDataObj.append(AllModel(responseObj: temp))
            }
        }
    }    
}

class AllModel {
    var map: Map!
    var user_total_duration = ""
    var user_total_burn_calories = ""
    var total_duration = ""
    var total_burn_calories = ""
    var date = ""
    
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        date = map.value("date") ?? ""
        user_total_duration = map.value("user_total_duration") ?? ""
        user_total_burn_calories = map.value("user_total_burn_calories") ?? ""
        total_duration = map.value("total_duration") ?? ""
        total_burn_calories = map.value("total_burn_calories") ?? ""
    }
}

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
    var username = ""
    var created_at = ""
    var average_rating = ""
    
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        id = map.value("id") ?? ""
        created_at = map.value("created_at") ?? ""
        username = map.value("username") ?? ""
        average_rating = map.value("average_rating") ?? ""
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

class NewUploadList {
    var map: Map!
    var on_demand : CoachClassPrevious?
    var live : CoachClassPrevious?
    var Recipe : PopularRecipeData?
    
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        on_demand = CoachClassPrevious(responseObj: responseObj["on_demand"] as? [String : Any] ?? [String : Any]())
        Recipe = PopularRecipeData(responseObj: responseObj["Recipe"] as? [String : Any] ?? [String : Any]())
        live = CoachClassPrevious(responseObj: responseObj["live"] as? [String : Any] ?? [String : Any]())
    }
    
    class func getData(data : [Any]) -> [NewUploadList] {
        var arrTemp = [NewUploadList]()
        for temp in data {
            arrTemp.append(NewUploadList(responseObj: temp as? [String : Any] ?? [String : Any]()))
        }
        return arrTemp
    }
}

class ModelMeta {
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
    var username = ""
    var created_at = ""
    var average_rating = ""
    
    var title = ""
    var sub_title = ""
    var recipe_step = ""
    var arrMealType = [MealTypeListData]()
    var arrMealTypeString = ""
    var arrDietaryRestrictionListData = [DietaryRestrictionListData]()
    var created_atFormated = ""
    var user_recipe_rating = ""
    var user_recipe_comments = ""
    var viewers = ""
    var arrRecipeSteps = [String:AnyObject]()
    var arrdietary_restriction = [String]()
    var coach_image = ""
    var meal_type_name = ""
    var dietary_restriction_name = ""
    
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        id = map.value("id") ?? ""
        created_at = map.value("created_at") ?? ""
        username = map.value("username") ?? ""
        average_rating = map.value("average_rating") ?? ""
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
        
        dietary_restriction_name =  map.value("dietary_restriction_name") ?? ""
        meal_type_name =  map.value("meal_type_name") ?? ""
        coach_image =  map.value("coach_image") ?? ""
        title = map.value("title") ?? ""
        sub_title = map.value("sub_title") ?? ""
        arrMealType = MealTypeListData.getData(data: responseObj["meal_type"] as? [Any] ?? [Any]())
        arrDietaryRestrictionListData = DietaryRestrictionListData.getData(data: responseObj["dietary_restriction"] as? [Any] ?? [Any]())
        user_recipe_rating = map.value("user_recipe_rating") ?? ""
        user_recipe_comments = map.value("user_recipe_comments") ?? ""
        viewers = map.value("viewers") ?? ""
                
        for temp in arrMealType {
            if arrMealTypeString.isEmpty {
                arrMealTypeString = temp.meal_type_name
            } else {
                arrMealTypeString +=  ", " + temp.meal_type_name
            }
        }
        
        for temp in arrDietaryRestrictionListData {
            arrdietary_restriction.append(temp.dietary_restriction_name)
        }
    }
    
    class func getData(data : [Any]) -> [ModelMeta] {
        var arrTemp = [ModelMeta]()
        for temp in data {
            arrTemp.append(ModelMeta(responseObj: temp as? [String : Any] ?? [String : Any]()))
        }
        return arrTemp
    }
}

class ModelNotificationClass {
    var map: Map!
    
    var notification_type = 0
    var message = ""
    var datetime = ""
    var user_id = 0
    var id = ""
    var meta = ModelMeta()
        
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        notification_type = map.value("notification_type") ?? 0
        message = map.value("message") ?? ""
        datetime = map.value("datetime") ?? ""
        user_id = map.value("user_id") ?? 0
        meta = ModelMeta(responseObj: responseObj["meta"] as? [String : Any] ?? [String : Any]())
    }
    
    class func getData(data : [Any]) -> [ModelNotificationClass] {
        var arrTemp = [ModelNotificationClass]()
        for temp in data {
            arrTemp.append(ModelNotificationClass(responseObj: temp as? [String : Any] ?? [String : Any]()))
        }
        return arrTemp
    }
}
