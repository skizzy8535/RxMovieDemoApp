//
//  MovieSimilarities.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/3/20.
//

import Foundation

struct MovieSimilarities:Codable {
    let results:[MovieSimilaritiesDetail]
}


struct MovieSimilaritiesDetail:Codable,Hashable {
    let id:Int
    let poster_path:String?
    let vote_average:Double

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    static func == (lhs:MovieSimilaritiesDetail , rhs:MovieSimilaritiesDetail) -> Bool {
        return lhs.id == rhs.id
    }
}

