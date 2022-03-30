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

struct ErrorsDataModel: Codable {

    var email : [String]?
    var phoneno : [String]?
    var username : [String]?
    
    enum CodingKeys: String, CodingKey {
        case email = "email"
        case phoneno = "phoneno"
        case username = "username"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        email = try values.decodeIfPresent([String].self, forKey: .email)
        phoneno = try values.decodeIfPresent([String].self, forKey: .phoneno)
        username = try values.decodeIfPresent([String].self, forKey: .username)
    }
}

struct EmailDataModel: Codable {

    let email : String?
    let phoneno : String?
    
    enum CodingKeys: String, CodingKey {
        case email = "email"
        case phoneno = "phoneno"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        phoneno = try values.decodeIfPresent(String.self, forKey: .phoneno)
    }
}
