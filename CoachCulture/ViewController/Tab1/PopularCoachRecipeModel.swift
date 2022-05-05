//
//  PopularCoachRecipeModel.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 20/12/21.
//

import Foundation
import UIKit

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

// MARK: - Welcome
class Welcome {
    var map: Map!
    let object: String
    var data: [Datum] = []
    let hasMore: Bool
    let url: String

    enum CodingKeys: String {
        case object, data
        case hasMore = "has_more"
        case url
    }
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj)
        self.object = map.value("object") ?? ""
        let data1 = responseObj["data"]
        self.data.append(Datum(responseObj: data1 as? [String : Any] ?? [String:Any]()))
        self.hasMore = ((map.value("hasMore") ?? "") != nil)
        self.url = map.value("url") ?? ""
    }
}

// MARK: - Datum
class Datum {
    var map: Map!
    let id, object: String
    let brand, country, customer, cvcCheck: String
    let expMonth, expYear: Int
    let fingerprint, funding, last4: String
    let metadata: Metadata
    let name: String

    enum CodingKeys: String {
        case id, object
        case addressCity = "address_city"
        case addressCountry = "address_country"
        case addressLine1 = "address_line1"
        case addressLine1Check = "address_line1_check"
        case addressLine2 = "address_line2"
        case addressState = "address_state"
        case addressZip = "address_zip"
        case addressZipCheck = "address_zip_check"
        case brand, country, customer
        case cvcCheck = "cvc_check"
        case dynamicLast4 = "dynamic_last4"
        case expMonth = "exp_month"
        case expYear = "exp_year"
        case fingerprint, funding, last4, metadata, name
        case tokenizationMethod = "tokenization_method"
    }
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj)
        self.id = map.value("id") ?? ""
        self.object = map.value("object") ?? ""
        self.brand = map.value("brand") ?? ""
        self.country = map.value("country") ?? ""
        self.customer = map.value("customer") ?? ""
        self.cvcCheck = map.value("cvc_check") ?? ""
        self.expMonth = map.value("exp_month") ?? 0
        self.expYear = map.value("exp_year") ?? 0
        self.fingerprint = map.value("fingerprint") ?? ""
        self.funding = map.value("funding") ?? ""
        self.last4 = map.value("last4") ?? ""
        self.metadata = Metadata.init(responseObj: responseObj["metadata"] as? [String:Any] ?? [String:Any]())
        self.name = map.value("name") ?? ""
    }
}

// MARK: - Metadata
class Metadata: Codable {
    var map: Map!
    let cardNumber: String

    enum CodingKeys: String, CodingKey {
        case cardNumber = "card_number"
    }
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj)
        self.cardNumber = map.value("card_number") ?? ""
    }
}
/*
// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}



class StripeCardsDataModel {
    var map: Map!
    var object = ""
    var data = CardDataModel()
    var url = ""
    var has_more = false

    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        object =  map.value("object") ?? ""
        data = CardDataModel(responseObj: responseObj["card"] as? [String : Any] ?? [String : Any]())
        url = map.value("url") ?? ""
        has_more = map.value("has_more") ?? true
    }
    
    class func getCardDictionary(from responseModel: StripeCardsDataModel) -> [String:Any]? {
        var cardTempDict = [String:Any]()
        
        cardTempDict["object"] =  responseModel.object
        cardTempDict["url"] =  responseModel.url
        cardTempDict["data"] = CardDataModel.getCardDataDictionary(from: responseModel.data)
        cardTempDict["has_more"] =  responseModel.has_more
        cardTempDict["object"] =  responseModel.object
        return cardTempDict
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
    
    class func getChecksDataDictionary(from responseModel: ChecksDataModel) -> [String:Any]? {
        var checksDataTempDict = [String:Any]()
        
        checksDataTempDict["address_line1_check"] = responseModel.address_line1_check
        checksDataTempDict["address_postal_code_check"] =  responseModel.address_postal_code_check
        checksDataTempDict["cvc_check"] = responseModel.cvc_check
        return checksDataTempDict
    }
}

class MetaDataModel {
    var map: Map!
    var card_number = ""
    
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        card_number =  map.value("card_number") ?? ""
    }
    
    class func getMetadataDictionary(from responseModel: MetaDataModel) -> [String:Any]? {
        var metaDataTempDict = [String:Any]()
        
        metaDataTempDict["card_number"] =  responseModel.card_number
        return metaDataTempDict
    }
}

class CardDataModel {
    var map: Map!
    var id = ""
    var object = ""
    var address_city = ""
    var address_country = ""
    var address_line1 = ""
    var address_line1_check = ""
    var address_line2 = ""
    var address_state = ""
    var address_zip = ""
    var address_zip_check = ""
    var brand = ""
    var country = ""
    var customer = ""
    var cvc_check = ""
    var dynamic_last4 = ""
    var exp_month = ""
    var exp_year = ""
    var fingerprint = ""
    var funding = ""
    var tokenization_method = ""
    var last4 = ""
    var name = ""
    var metadata = MetaDataModel()
    
    init() {}
    
    init(responseObj: [String : Any]) {
        map                      = Map(data: responseObj)
        id                       = map.value("id") ?? ""
        object                   = map.value("object") ?? ""
        address_city             = map.value("address_city") ?? ""
        address_country          = map.value("address_country") ?? ""
        address_line1            = map.value("address_line1") ?? ""
        address_line1_check      = map.value("address_line1_check") ?? ""
        address_line2            = map.value("address_line2") ?? ""
        address_state            = map.value("address_state") ?? ""
        address_zip              = map.value("address_zip") ?? ""
        address_zip_check        = map.value("address_zip_check") ?? ""
        brand                    = map.value("brand") ?? ""
        country                  = map.value("country") ?? ""
        customer                 = map.value("customer") ?? ""
        cvc_check                = map.value("cvc_check") ?? ""
        dynamic_last4            = map.value("dynamic_last4") ?? ""
        exp_month                = map.value("exp_month") ?? ""
        exp_year                 = map.value("exp_year") ?? ""
        fingerprint              = map.value("fingerprint") ?? ""
        funding                  = map.value("funding") ?? ""
        tokenization_method      = map.value("tokenization_method") ?? ""
        last4                    = map.value("last4") ?? ""
        name                     = map.value("name") ?? ""
        metadata                 = MetaDataModel(responseObj: responseObj["metadata"] as? [String : Any] ?? [String : Any]())
    }
    
    class func getCardDataDictionary(from responseModel: CardDataModel) -> [String:Any]? {
        var cardDataTempDict = [String:Any]()
        
        cardDataTempDict["metadata"] = MetaDataModel.getMetadataDictionary(from: responseModel.metadata)
        cardDataTempDict["map"] = responseModel.map
        cardDataTempDict["id"] = responseModel.id
        cardDataTempDict["object"] = responseModel.object
        cardDataTempDict["address_city"] = responseModel.address_city
        cardDataTempDict["address_country"] = responseModel.address_country
        cardDataTempDict["address_line1"] = responseModel.address_line1
        cardDataTempDict["address_line1_check"] = responseModel.address_line1_check
        cardDataTempDict["address_line2"] = responseModel.address_line2
        cardDataTempDict["address_state"] = responseModel.address_state
        cardDataTempDict["address_zip"] = responseModel.address_zip
        cardDataTempDict["address_zip_check"] = responseModel.address_zip_check
        cardDataTempDict["brand"] = responseModel.brand
        cardDataTempDict["country"] = responseModel.country
        cardDataTempDict["customer"] = responseModel.customer
        cardDataTempDict["cvc_check"] = responseModel.cvc_check
        cardDataTempDict["dynamic_last4"] = responseModel.dynamic_last4
        cardDataTempDict["exp_month"] = responseModel.exp_month
        cardDataTempDict["exp_year"] = responseModel.exp_year
        cardDataTempDict["fingerprint"] = responseModel.fingerprint
        cardDataTempDict["funding"] = responseModel.funding
        cardDataTempDict["tokenization_method"] = responseModel.tokenization_method
        cardDataTempDict["last4"] = responseModel.last4
        cardDataTempDict["name"] = responseModel.name
        return cardDataTempDict
    }
}
/*
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
    
    class func getBillingDetailsDictionary(from responseModel: BillingDetailsDataModel) -> [String:Any]? {
        var billingDetailsTempDict = [String:Any]()
        
        billingDetailsTempDict["address"] = AddressDataModel.getAddressDataDictionary(from: responseModel.address)
        billingDetailsTempDict["email"] =  responseModel.email
        billingDetailsTempDict["name"] = responseModel.name
        billingDetailsTempDict["phone"] = responseModel.phone
        return billingDetailsTempDict
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
    
    class func getAddressDataDictionary(from responseModel: AddressDataModel) -> [String:Any]? {
        var addressDataTempDict = [String:Any]()
        
        addressDataTempDict["city"] = responseModel.city
        addressDataTempDict["country"] =  responseModel.country
        addressDataTempDict["line1"] = responseModel.line1
        addressDataTempDict["line2"] = responseModel.line2
        addressDataTempDict["postal_code"] = responseModel.postal_code
        addressDataTempDict["state"] = responseModel.state
        return addressDataTempDict
    }
}
 */*/
