//  MovieListRepository.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/7.
//

import Foundation
import RxSwift


enum MovieError:Error {
    case movieHomeListError
    case movieExploreListError
    case movieDetailError
    case movieTrailerError
    case moviePosterError
    case movieSimilaritiesError
}


protocol MovieFetchRepository {
    func fetchHomeDisplay (url:String ,completion :@escaping (Result<MovieHomeList,Error>) -> Void )
    func fetchMovieExploreList (url:String ,completion :@escaping (Result<MovieExploreList,Error>) -> Void )
    func fetchMovieDetail (url:String ,completion :@escaping (Result<MovieDetail,Error>) -> Void )
    func fetchPlayTrailer (url:String ,completion :@escaping (Result<MovieTrailer,Error>) -> Void )
    func fetchMoviePoster (url:String ,completion :@escaping (Result<MoviePoster,Error>) -> Void )
    func fetchMovieSimilarities (url:String ,completion :@escaping (Result<MovieSimilarities,Error>) -> Void )
}



