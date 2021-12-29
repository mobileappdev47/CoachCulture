//
//  ResponseDataModel.swift
//   
//
//     on 19/03/19.
//   . All rights reserved.
//

import Foundation

class ResponseDataModel {
    var map: Map!
    var success = false
    var message = ""
    
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        success = map.value("success") ?? false
        message = map.value("message") ?? ""
    }
}
