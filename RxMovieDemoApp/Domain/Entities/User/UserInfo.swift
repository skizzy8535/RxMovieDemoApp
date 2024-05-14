//
//  UserInfo.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/7.
//

import Foundation


struct UserInfo: Codable {
    var userToken: String?
    var login: String?
    var errorCode: Int?
    var message: String?

    enum CodingKeys: String,CodingKey {
        case userToken = "User-Token"
        case login
        case errorCode = "error_code"
        case message
    }
}
