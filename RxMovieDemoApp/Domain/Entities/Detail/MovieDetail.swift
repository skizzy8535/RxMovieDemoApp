//
//  MovieDetail.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/2/20.
//

import Foundation

struct MovieDetail:Codable {
    let poster_path:String?
    let backdrop_path:String?
    let title: String?
    let tagline: String?
    let runtime:Int?
    let vote_average:Double?
    let overview:String?
    let release_date: String?
    let genres: [Genre]?
}


struct Genre: Codable {
    let name: String?
}
