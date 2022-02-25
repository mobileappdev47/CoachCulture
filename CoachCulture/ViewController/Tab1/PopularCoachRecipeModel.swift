//
//  PopularCoachRecipeModel.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 20/12/21.
//

import Foundation


class PopularRecipeData {
    var map: Map!
    var id = ""
    var thumbnail_image = ""
    var title = ""
    var duration = ""
    var sub_title = ""
    var recipe_step = ""
    var arrMealType = [MealTypeListData]()
    var arrMealTypeString = ""
    var arrDietaryRestrictionListData = [DietaryRestrictionListData]()
    var coachDetailsObj = CoachDetailsData()
    var created_at = ""
    var created_atFormated = ""
    var user_recipe_rating = ""
    var user_recipe_comments = ""
    var bookmark = ""
    var viewers = ""
    var status = ""
    var arrRecipeSteps = [String:AnyObject]()
    var arrdietary_restriction = [String]()
   
   
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        id = map.value("id") ?? ""
        thumbnail_image = map.value("thumbnail_image") ?? ""
        title = map.value("title") ?? ""
        sub_title = map.value("sub_title") ?? ""
        duration = map.value("duration") ?? ""
        arrMealType = MealTypeListData.getData(data: responseObj["meal_type"] as? [Any] ?? [Any]())
        arrDietaryRestrictionListData = DietaryRestrictionListData.getData(data: responseObj["dietary_restriction"] as? [Any] ?? [Any]())
        coachDetailsObj = CoachDetailsData(responseObj: responseObj["coach"] as? [String : Any] ?? [String : Any]())
        created_at = map.value("created_at") ?? ""
        if !created_at.isEmpty {
            let nsData = created_at.getDateWithFormate(formate: "yyyy-MM-dd hh:mm:ss", timezone: "UTC")
            created_atFormated = nsData.getDateStringWithFormate("dd MMM yyyy", timezone: "UTC")
        }
        user_recipe_rating = map.value("user_recipe_rating") ?? ""
        user_recipe_comments = map.value("user_recipe_comments") ?? ""
        status = map.value("status") ?? ""
        bookmark = map.value("bookmark") ?? ""
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
    
    
    class func getData(data : [Any]) -> [PopularRecipeData] {
        
        var arrTemp = [PopularRecipeData]()
        for temp in data {
       
            arrTemp.append(PopularRecipeData(responseObj: temp as? [String : Any] ?? [String : Any]()))
        }
        
        return arrTemp
    }
}


class CoachRecipeData {
    var map: Map!
    var id = ""
    var thumbnail_image = ""
    var coach_id = ""
    var username = ""
    var title = ""
    var duration = ""
    var status = ""
    var dietary_restriction_name = ""
    var meal_type_name = ""
    var coach_image = ""
    var bookmark = ""
    var arrDietaryRestrictionName = [String]()
   
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        id = map.value("id") ?? ""
        coach_id = map.value("coach_id") ?? ""
        thumbnail_image = map.value("thumbnail_image") ?? ""
        duration = map.value("duration") ?? ""
        username = map.value("username") ?? ""
        duration = map.value("duration") ?? ""
        status = map.value("status") ?? ""
        bookmark = map.value("bookmark") ?? ""
        coach_image = map.value("coach_image") ?? ""
        dietary_restriction_name = map.value("dietary_restriction_name") ?? ""
        meal_type_name = map.value("meal_type_name") ?? ""
        title = map.value("title") ?? ""
        
        arrDietaryRestrictionName = dietary_restriction_name.components(separatedBy: ",")

    }
    
    
    class func getData(data : [Any]) -> [CoachRecipeData] {
        
        var arrTemp = [CoachRecipeData]()
        for temp in data {
       
            arrTemp.append(CoachRecipeData(responseObj: temp as? [String : Any] ?? [String : Any]()))
        }
        
        return arrTemp
    }
}
