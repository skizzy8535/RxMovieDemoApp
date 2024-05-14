//
//  MovieLoadDelegate.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/24.
//

import Foundation

protocol MovieHomeLoadingDelegate:LoadingDelegate {
    func presentHomeDisplayItems(nowPlayingMovies: [MovieHomeListData],
                                 popularMovies: [MovieHomeListData],
                                 upcomingMovies: [MovieHomeListData],
                                 topRatedMovies: [MovieHomeListData])
}


protocol MovieDetailLoadingDelegate:LoadingDelegate {
    func presentMovieDetail()
}

protocol MovieExploreLoadingDelegate:LoadingDelegate {
    func presentMovieExploreItems()
}

protocol MovieFavsLoadingDelegate:LoadingDelegate {
    func presentFavMovieItems()
}
