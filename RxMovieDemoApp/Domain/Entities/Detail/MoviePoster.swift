//
//  MoviePosterModel.swift
//  RxMovieApp
//
//  Created by YuChen Lin on 2024/3/20.
//

import Foundation

struct MoviePoster:Codable {
    let backdrops:[MoviePosterDetailModel]
}

struct MoviePosterDetailModel:Codable {
    let aspect_ratio: Double
    let file_path:String
}
