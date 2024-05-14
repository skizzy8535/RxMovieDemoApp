//
//  MovieTrailerModel.swift
//  RxMovieApp
//
//  Created by YuChen Lin on 2024/3/20.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources


struct MovieTrailers:Codable {
    let results:[MovieTrailerDetailModel]
}

struct MovieTrailerDetailModel: Codable, IdentifiableType {
    let name: String
    let key: String
    let published_at: String

    typealias Identity = String

    var identity: String {
        return key // Assuming key is unique for each trailer
    }
}
