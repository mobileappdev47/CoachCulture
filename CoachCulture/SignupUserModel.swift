//
//  SignupUserModel.swift
//  CoachCulture
//
//  Created by Mayur Boghani on 29/10/21.
//

import Foundation

struct SignupUserModel: Codable {

    let message : String?
    let user : User?
    let errors : ErrorsDataModel?
    
    enum CodingKeys: String, CodingKey {
        case message = "message"
        case errors =  "errors"
        case user
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        user = try values.decodeIfPresent(User.self, forKey: .user)
        errors = try values.decodeIfPresent(ErrorsDataModel.self, forKey: .errors)
    }
}

struct User: Codable {

    let countrycode : String?
    let createdAt : String?
    let email : String?
    let id : Int?
    let phonecode : String?
    let phoneno : String?
    let role : String?
    let status : String?
    let updatedAt : String?
    let username : String?
//    let verificationCode : Int?


    enum CodingKeys: String, CodingKey {
        case countrycode = "countrycode"
        case createdAt = "created_at"
        case email = "email"
        case id = "id"
        case phonecode = "phonecode"
        case phoneno = "phoneno"
        case role = "role"
        case status = "status"
        case updatedAt = "updated_at"
        case username = "username"
//        case verificationCode = "verification_code"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        countrycode = try values.decodeIfPresent(String.self, forKey: .countrycode)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        phonecode = try values.decodeIfPresent(String.self, forKey: .phonecode)
        phoneno = try values.decodeIfPresent(String.self, forKey: .phoneno)
        role = try values.decodeIfPresent(String.self, forKey: .role)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        username = try values.decodeIfPresent(String.self, forKey: .username)
//        verificationCode = try values.decodeIfPresent(Int.self, forKey: .verificationCode)
    }
}


struct LoginUserModel : Codable {

    let data : LoginUserData?
    let message : String?
    let success : Bool?


    enum CodingKeys: String, CodingKey {
        case data
        case message = "message"
        case success = "success"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent(LoginUserData.self, forKey: .data)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        success = try values.decodeIfPresent(Bool.self, forKey: .success)
    }


}


struct LoginUserData : Codable {

    let accessToken : String?
    let expiresIn : Int?
    let tokenType : String?
    let user : User?


    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
        case user
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try values.decodeIfPresent(String.self, forKey: .accessToken)
        expiresIn = try values.decodeIfPresent(Int.self, forKey: .expiresIn)
        tokenType = try values.decodeIfPresent(String.self, forKey: .tokenType)
        user = try values.decodeIfPresent(User.self, forKey: .user)
    }


}
