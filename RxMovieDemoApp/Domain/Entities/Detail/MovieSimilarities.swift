//
//  MovieSimilarModel.swift
//  RxMovieApp
//
//  Created by YuChen Lin on 2024/3/20.
//

import Foundation

struct MovieSimilaries:Codable {
    let results:[MovieSimilarDetailModel]
}


struct MovieSimilarDetailModel:Codable,Hashable {
    let id:Int
    let poster_path:String?
    let vote_average:Double

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    static func == (lhs:MovieSimilarDetailModel , rhs:MovieSimilarDetailModel) -> Bool {
        return lhs.id == rhs.id
    }
}

