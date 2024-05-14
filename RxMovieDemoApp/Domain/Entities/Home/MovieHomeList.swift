//
//  HomeMovieList.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/2/22.
//

import Foundation


struct HomeMovieList:Codable {
    let results:[HomeMovieListData]
}

struct HomeMovieListData:Codable,Hashable{

    let id:Int?
    let title:String?
    let backdrop_path:String?
    let poster_path :String?
    let vote_average: Double

    init(id: Int?, title: String?,backdrop_path:String? ,poster_path: String?,vote_average:Double) {
        self.id = id
        self.title = title
        self.backdrop_path = backdrop_path
        self.poster_path = poster_path
        self.vote_average = vote_average
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    static func == (lhs:HomeMovieListData,rhs:HomeMovieListData) -> Bool{
        return lhs.id == rhs.id
    }

}
