//
//  LoginLoadDelegate.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/24.
//

import Foundation


protocol LoginLoadDelegate:LoadingDelegate {
    func doVerifyAccountAction()
    func showSuccessMessage()
    func doRetrieveSaveAccountInfo()
}


