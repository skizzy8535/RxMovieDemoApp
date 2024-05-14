//
//  User.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/3/30.
//

import Foundation

struct User :Codable {
    var user: UserDetail
}

struct UserDetail: Codable {
    var login:String
    var email: String?
    var password: String
}
