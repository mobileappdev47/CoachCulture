//
//  CreateRecipeModel.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 10/12/21.
//

import Foundation

class MealTypeListData {
    var map: Map!
    var id = ""
    var meal_type_name = ""
    var isSelected = false
    var meal_type_id = ""
    
   
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        id = map.value("id") ?? ""
        meal_type_name = map.value("meal_type_name") ?? ""
        meal_type_id = map.value("meal_type_id") ?? ""

    }
    
    
    class func getData(data : [Any]) -> [MealTypeListData] {
        
        var arrTemp = [MealTypeListData]()
        for temp in data {
       
            arrTemp.append(MealTypeListData(responseObj: temp as? [String : Any] ?? [String : Any]()))
        }
        
        return arrTemp
    }
}


class AddStepOfRecipe {
    var description = ""
   
    init() {}
}

class AddIngredients {
    var qty = ""
    var unit = ""
    var addIngredients = ""
   
    init() {}
    
}

class DietaryRestrictionListData {
    var map: Map!
    var id = ""
    var dietary_restriction_name = ""
    var dietary_restriction_id = ""
    var isSelected = false
   
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        id = map.value("id") ?? ""
        dietary_restriction_name = map.value("dietary_restriction_name") ?? ""
        dietary_restriction_id = map.value("dietary_restriction_id") ?? ""

    }
    
    
    class func getData(data : [Any]) -> [DietaryRestrictionListData] {
        
        var arrTemp = [DietaryRestrictionListData]()
        for temp in data {
       
            arrTemp.append(DietaryRestrictionListData(responseObj: temp as? [String : Any] ?? [String : Any]()))
        }
        
        return arrTemp
    }
}

class RecipeDetailData {
    var map: Map!
    var id = ""
    var thumbnail_image = ""
    var title = ""
    var duration = ""
    var sub_title = ""
    var recipe_step = ""
    var arrQtyIngredient = [QtyIngredient]()
    var arrMealType = [MealTypeListData]()
    var arrMealTypeString = ""
    var arrDietaryRestrictionListData = [DietaryRestrictionListData]()
    var coachDetailsObj = CoachDetailsData()
    var created_at = ""
    var created_atFormated = ""
    var user_recipe_rating = ""
    var user_recipe_comments = ""
    var bookmark = ""
    var total_viewers = ""
    var status = ""
    var arrRecipeSteps = [String:AnyObject]()
   
   
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        id = map.value("id") ?? ""
        thumbnail_image = map.value("thumbnail_image") ?? ""
        title = map.value("title") ?? ""
        sub_title = map.value("sub_title") ?? ""
        duration = map.value("duration") ?? ""
        arrQtyIngredient = QtyIngredient.getData(data: responseObj["qty_ingredient"] as? [Any] ?? [Any]())
        arrMealType = MealTypeListData.getData(data: responseObj["meal_type"] as? [Any] ?? [Any]())
        arrDietaryRestrictionListData = DietaryRestrictionListData.getData(data: responseObj["dietary_restriction"] as? [Any] ?? [Any]())
        coachDetailsObj = CoachDetailsData(responseObj: responseObj["coach_details"] as? [String : Any] ?? [String : Any]())
        created_at = map.value("created_at") ?? ""
        if !created_at.isEmpty {
            let nsData = created_at.getDateWithFormate(formate: "yyyy-MM-dd hh:mm:ss", timezone: "UTC")
            created_atFormated = nsData.getDateStringWithFormate("dd MMM yyyy", timezone: "UTC")
        }
        user_recipe_rating = map.value("user_recipe_rating") ?? ""
        user_recipe_comments = map.value("user_recipe_comments") ?? ""
        status = map.value("status") ?? ""
        bookmark = map.value("bookmark") ?? ""
        total_viewers = map.value("total_viewers") ?? ""
        recipe_step = map.value("recipe_step") ?? ""
        do{
            if let json = recipe_step.data(using: String.Encoding.utf8){
                if let jsonData = try JSONSerialization.jsonObject(with: json, options: .allowFragments) as? [String:AnyObject]{
                    self.arrRecipeSteps = jsonData
                }
            }
        }catch {
            print(error.localizedDescription)

        }
        
        for temp in arrMealType {
            if arrMealTypeString.isEmpty {
                arrMealTypeString = temp.meal_type_name
            } else {
                arrMealTypeString +=  ", " + temp.meal_type_name
            }
        }

    }
}

class QtyIngredient {
    var map: Map!
    var ingredients = ""
    var quantity = ""
   
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        ingredients = map.value("ingredients") ?? ""
        quantity = map.value("quantity") ?? ""

    }
    
    
    class func getData(data : [Any]) -> [QtyIngredient] {
        
        var arrTemp = [QtyIngredient]()
        for temp in data {
       
            arrTemp.append(QtyIngredient(responseObj: temp as? [String : Any] ?? [String : Any]()))
        }
        
        return arrTemp
    }
}

class CoachDetailsData {
    var map: Map!
    var id = ""
    var username = ""
    var user_image = ""
    
   
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        id = map.value("id") ?? ""
        username = map.value("username") ?? ""
        user_image = map.value("user_image") ?? ""
    }
  
}
