//
//  LoadingDelegate.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/22.
//

import Foundation

protocol LoadingDelegate {
    func didChange(isLoading:Bool)
    func showErrorMessage()
}
