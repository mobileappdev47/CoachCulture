//
//  CoachProfileModel.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 04/12/21.
//

import Foundation



class NationalityData {
    var map: Map!
    var id = ""
    var country_nationality = ""
    var currency_symbol = ""
    var currency = ""

    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        id = map.value("id") ?? ""
        country_nationality = map.value("country_nationality") ?? ""
        currency_symbol = map.value("currency_symbol") ?? ""
        currency = map.value("currency") ?? ""

    }
    
    
    class func getData(data : [Any]) -> [NationalityData] {
        
        var arrTemp = [NationalityData]()
        for temp in data {
       
            arrTemp.append(NationalityData(responseObj: temp as? [String : Any] ?? [String : Any]()))
        }
        
        return arrTemp
    }
}

