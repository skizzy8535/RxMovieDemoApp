//
//  MovieTrailer.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/3/20.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources


struct MovieTrailer:Codable {
    let results:[MovieTrailerDetail]
}

struct MovieTrailerDetail: Codable, IdentifiableType {
    let name: String
    let key: String
    let published_at: String

    typealias Identity = String

    var identity: String {
        return key
    }
}
