//
//  MockMovieDetailLoadDelegate.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/26.
//

import Foundation



class MockMovieDetailLoadDelegate:MovieDetailLoadingDelegate {

    var didCallShowIndicatorView:Bool = false
    var didCallShowErrorMessage:Bool = false
    var didCallDetailDisplayItems:Bool = false

    func didChange(isLoading: Bool) {
        didCallShowIndicatorView = true
    }

    func showErrorMessage() {
        didCallShowErrorMessage = true
    }

    func presentMovieDetail() {
        didCallDetailDisplayItems = true
    }

}
