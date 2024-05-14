//  MovieListRepository.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/7.
//

import Foundation
import RxSwift


enum MovieError:String, Error{
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


class MockMovieFetchRepository: MovieFetchRepository {

    var mockHomeListResult:Result<MovieHomeList, Error> = .failure(MovieError.movieHomeListError)
    var mockExploreResult:Result<MovieExploreList, Error> = .failure(MovieError.movieExploreListError)
    var mockDetailResult:Result<MovieDetail, Error> = .failure(MovieError.movieDetailError)
    var mockTrailerResult:Result<MovieTrailer, Error> = .failure(MovieError.movieTrailerError)
    var mockPosterResult:Result<MoviePoster, Error> = .failure(MovieError.moviePosterError)
    var mockSimilaritiesResult:Result<MovieSimilarities, Error> = .failure(MovieError.movieSimilaritiesError)

    func fetchHomeDisplay(url: String, completion: @escaping (Result<MovieHomeList, Error>) -> Void) {
        completion(mockHomeListResult)
    }

    func fetchMovieExploreList(url: String, completion: @escaping (Result<MovieExploreList, Error>) -> Void) {
        completion(mockExploreResult)
    }

    func fetchMovieDetail(url: String, completion: @escaping (Result<MovieDetail, Error>) -> Void) {
        completion(mockDetailResult)
    }

    func fetchPlayTrailer(url: String, completion: @escaping (Result<MovieTrailer, Error>) -> Void) {
        completion(mockTrailerResult)
    }

    func fetchMoviePoster(url: String, completion: @escaping (Result<MoviePoster, Error>) -> Void) {
        completion(mockPosterResult)
    }

    func fetchMovieSimilarities(url: String, completion: @escaping (Result<MovieSimilarities, Error>) -> Void) {
        completion(mockSimilaritiesResult)
    }

}

