//
//  MovieExploreList.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/2/19.
//

import Foundation
import RxSwift
import RxDataSources

struct MovieExploreList:Codable {
    let results:[MovieExploreListData]
}

struct MovieExploreListData:Codable{

    let id :Int
    let poster_path:String?
    let vote_average:Double

    init(id: Int ,poster_path: String?, vote_average: Double) {
        self.id = id
        self.poster_path = poster_path
        self.vote_average = vote_average
    }
}
