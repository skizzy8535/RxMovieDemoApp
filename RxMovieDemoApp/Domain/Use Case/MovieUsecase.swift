//
//  MovieUseCase.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/3/6.
//

import Foundation


enum PlayingGenre:String{
    case nowPlaying = "now_playing"
    case popular = "popular"
    case topRated = "top_rated"
    case upcoming = "upcoming"
}


protocol MovieUseCaseProtocol {
    static func configureUrlString(genre: PlayingGenre) -> String     // Movie list
    static func configureUrlString(id: Int) -> String     // Movie detail
    static func configureUrlString(imagePath: String?) -> String?   // Image Path
    static func configureUrlString(keyword: String, page: Int) -> String   // Keyword search
    static func configureUrlString(trailerID:String) -> String //  Get Trailer
    static func configureUrlString(thumbnailKey:String) -> String // Get Trailer ThumbNail
    static func configureUrlString(videoKey:String) -> String // Play Trailer
    static func configureUrlString(posterKey:String) -> String  // Get Poster Sets
    static func configureUrlString(similarID: Int) -> String // Get Similar Movies
}


class MovieUseCase: MovieUseCaseProtocol {

    /// Movie list

    static func configureUrlString(genre: PlayingGenre) -> String {
        return "https://api.themoviedb.org/3/movie/\(genre.rawValue)?api_key=\(AppConstant.TMDB_API_KEY)&language=en-US"
    }

    /// Movie detail

    static func configureUrlString(id: Int) -> String {
        return "https://api.themoviedb.org/3/movie/\(id)?api_key=\(AppConstant.TMDB_API_KEY)&language=en-US"
    }

    /// Image Path

    static func configureUrlString(imagePath: String?) -> String? {
        guard let imagePath else { return nil }
        return "https://image.tmdb.org/t/p/original/\(imagePath)"
    }

    /// Keyword search

    static func configureUrlString(keyword: String, page: Int) -> String {
        return "https://api.themoviedb.org/3/search/movie?query=\(keyword)&api_key=\(AppConstant.TMDB_API_KEY)&language=en-US&page=\(page)"
    }



    /// Get Trailer

    static func configureUrlString(trailerID:String) -> String {
        return "https://api.themoviedb.org/3/movie/\(trailerID)/videos?language=en-US&api_key=\(AppConstant.TMDB_API_KEY)"
    }

    /// Get Trailer ThumbNail

    static func configureUrlString(thumbnailKey:String) -> String {
        return "https://img.youtube.com/vi/\(thumbnailKey)/mqdefault.jpg"
    }

    /// Play Trailer
    static func configureUrlString(videoKey:String) -> String {
        return "https://youtube.com/embed/\(videoKey)"
    }


    /// Get Poster Sets
    static func configureUrlString(posterKey:String) -> String {
        return "https://api.themoviedb.org/3/movie/\(posterKey)/images?&api_key=\(AppConstant.TMDB_API_KEY)"
    }



    /// Get Similar Movies
    static func configureUrlString(similarID: Int) -> String {
        return "https://api.themoviedb.org/3/movie/\(similarID)/similar?api_key=\(AppConstant.TMDB_API_KEY)&language=en-US"
    }

}
