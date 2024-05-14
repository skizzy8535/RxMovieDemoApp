//
//  MoviePoster.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/3/20.
//

import Foundation

struct MoviePoster:Codable {
    let backdrops:[MoviePosterDetail]
}

struct MoviePosterDetail:Codable {
    let aspect_ratio: Double
    let file_path:String
}
