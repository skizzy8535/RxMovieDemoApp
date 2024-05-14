//
//  MockFavoriteItemsLoadDelegate.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/26.
//

import Foundation


class MockFavoriteItemsLoadDelegate:MovieFavsLoadingDelegate {


    var didCallShowIndicatorView:Bool = false
    var didCallShowErrorMessage:Bool = false
    var didCallFavsDisplayItems:Bool = false


    func didChange(isLoading: Bool) {
        didCallShowIndicatorView = true
    }
    
    func showErrorMessage() {
        didCallShowErrorMessage = true
    }
    
    func presentFavMovieItems() {
        didCallFavsDisplayItems = true
    }



}
