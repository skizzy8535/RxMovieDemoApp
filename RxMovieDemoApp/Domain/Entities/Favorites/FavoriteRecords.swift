//
//  FavoriteRecordBody.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/5.
//

import Foundation


struct FavoriteRecords:Codable {
    var records: [GetFavoriteRecordModel]
}


struct GetFavoriteRecordModel:Codable {
    var id: String
    var fields:FavoriteItems
}

struct PostFavoriteRecordModel:Codable {
    var fields:FavoriteItems
}


struct FavoriteItems:Codable {
    var userName:String
    var movieID :Int
    var movieName:String
    var posterURL:String?
}


struct FavoriteDeleted:Codable {
    var id:String
    var deleted:Bool
}
