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
    var coach_image = ""
    var username = ""
    var meal_type_name = ""
    var dietary_restriction_name = ""
    var average_rating = ""
    
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        id = map.value("id") ?? ""
        dietary_restriction_name =  map.value("dietary_restriction_name") ?? ""
        meal_type_name =  map.value("meal_type_name") ?? ""
        username =  map.value("username") ?? ""
        coach_image =  map.value("coach_image") ?? ""
        thumbnail_image = map.value("thumbnail_image") ?? ""
        title = map.value("title") ?? ""
        sub_title = map.value("sub_title") ?? ""
        duration = map.value("duration") ?? ""
        average_rating = map.value("average_rating") ?? ""
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

class StripeCardsDataModel {
    var map: Map!
    var id = ""
    var object = ""
    var billing_details = BillingDetailsDataModel()
    var card = CardDataModel()
    var metadata = MetaDataModel()
    var created = ""
    var customer = ""
    var livemode = false
    var type = ""
    var isPrefferedSelected = false
    var isDeleteSelected = false

    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        id = map.value("id") ?? ""
        object =  map.value("object") ?? ""
        metadata = MetaDataModel(responseObj: responseObj["metadata"] as? [String : Any] ?? [String : Any]())
        billing_details = BillingDetailsDataModel(responseObj: responseObj["billing_details"] as? [String : Any] ?? [String : Any]())
        card = CardDataModel(responseObj: responseObj["card"] as? [String : Any] ?? [String : Any]())
        created =  map.value("created") ?? ""
        customer =  map.value("customer") ?? ""
        livemode =  map.value("livemode") ?? false
        type = map.value("type") ?? ""
    }
    
    class func getData(data : [Any]) -> [StripeCardsDataModel] {
        var arrTemp = [StripeCardsDataModel]()
        for temp in data {
            arrTemp.append(StripeCardsDataModel(responseObj: temp as? [String : Any] ?? [String : Any]()))
        }
        return arrTemp
    }
}

class ChecksDataModel {
    var map: Map!
    var address_line1_check = ""
    var address_postal_code_check = ""
    var cvc_check = ""
    
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        address_line1_check =  map.value("address_line1_check") ?? ""
        address_postal_code_check =  map.value("address_postal_code_check") ?? ""
        cvc_check =  map.value("cvc_check") ?? ""
    }
}

class MetaDataModel {
    var map: Map!
    var card_type = ""
    var card_number = ""
    var holder_name = ""
    
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        card_type =  map.value("card_type") ?? ""
        card_number =  map.value("card_number") ?? ""
        holder_name =  map.value("holder_name") ?? ""
    }
}

class CardDataModel {
    var map: Map!
    var brand = ""
    var country = ""
    var exp_month = ""
    var exp_year = ""
    var fingerprint = ""
    var funding = ""
    var generated_from = ""
    var last4 = ""
    var wallet = ""
    var checks = ChecksDataModel()
    var metadata = MetaDataModel()
    
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj)
        
        wallet =  map.value("wallet") ?? ""
        last4 =  map.value("last4") ?? ""
        generated_from =  map.value("generated_from") ?? ""
        funding =  map.value("funding") ?? ""
        fingerprint =  map.value("fingerprint") ?? ""
        exp_year =  map.value("exp_year") ?? ""
        checks = ChecksDataModel(responseObj: responseObj["checks"] as? [String : Any] ?? [String : Any]())
        metadata = MetaDataModel(responseObj: responseObj["metadata"] as? [String : Any] ?? [String : Any]())
        brand =  map.value("brand") ?? ""
        country =  map.value("country") ?? ""
        exp_month =  map.value("exp_month") ?? ""
    }
}

class BillingDetailsDataModel {
    var map: Map!
    var address = AddressDataModel()
    var email = ""
    var name = ""
    var phone = ""
    
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        address = AddressDataModel(responseObj: responseObj["address"] as? [String : Any] ?? [String : Any]())
        email =  map.value("email") ?? ""
        name =  map.value("name") ?? ""
        phone =  map.value("phone") ?? ""
    }
}

class AddressDataModel {
    var map: Map!
    var city = ""
    var country = ""
    var line1 = ""
    var line2 = ""
    var postal_code = ""
    var state = ""
    
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        city = map.value("city") ?? ""
        country =  map.value("country") ?? ""
        line1 =  map.value("line1") ?? ""
        line2 =  map.value("line2") ?? ""
        postal_code =  map.value("postal_code") ?? ""
        state = map.value("state") ?? ""
    }
}
