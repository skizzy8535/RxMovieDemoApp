//
//  MockMovieLoadDelegate.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/26.
//

import Foundation

class MockMovieHomeLoadDelegate:MovieHomeLoadingDelegate {
    
    var didCallShowIndicatorView:Bool = false
    var didCallShowErrorMessage:Bool = false
    var didCallShowHomeDisplayItems:Bool = false


    func presentHomeDisplayItems(nowPlayingMovies: [MovieHomeListData], popularMovies: [MovieHomeListData], upcomingMovies: [MovieHomeListData], topRatedMovies: [MovieHomeListData]) {
        didCallShowHomeDisplayItems = true
    }

    func didChange(isLoading: Bool) {
        didCallShowIndicatorView = true
    }
    
    func showErrorMessage() {
        didCallShowErrorMessage = true
    }
    

}
