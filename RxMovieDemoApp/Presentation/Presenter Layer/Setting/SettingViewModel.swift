//
//  SettingViewModel.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/3.
//

import Foundation
import RxSwift
import RxCocoa
import LocalAuthentication

class SettingViewModel {

    var delegate: SettingViewDelegate?
    private let disposeBag = DisposeBag()

    var userLogoutService:UserRepository?
     init(userLogoutService: UserRepository = UserService()) {
         self.userLogoutService = userLogoutService
     }

    var appBeingUnlocked:Bool = false
    var enrollmentError:Bool = false

    let settingItems = Observable.just([
        SettingSection(header: "General", items: [
            .titleCellWithSwitch(title: "Authentication"),
            .titleCellInit(title: "Watch List"),
            .titleCellWithSwitch(title: "Light Mode"),
            .titleCellInit(title: "Log Out"),
        ])
    ])


    func checkIfBioMetricsAvailable() -> Bool {

        let context = LAContext()
        var error:NSError?

        if let error = error {
            print(error.localizedDescription)
        }


        let isBiometricAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

        if isBiometricAvailable {
            enrollmentError = false
        } else {
            enrollmentError = true
        }


        return isBiometricAvailable
    }

    func appLockStateChange(lockState:Bool) {
        let laContext = LAContext()


        if checkIfBioMetricsAvailable() {
            var reason = ""
            if lockState {
                reason = "Provice Touch ID/Face ID to enable App Lock"
            } else {
                reason = "Provice Touch ID/Face ID to disable App Lock"
            }
            laContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in

                if success {
                    if lockState {
                        DispatchQueue.main.async {
                            self.enableAppLock()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.disableAppLock()
                        }
                    }
                } else {
                    if let error = error {
                        DispatchQueue.main.async {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        } else {
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }
    }

    func getAppLockState() -> Bool {
        appBeingUnlocked = UserDefaults.standard.bool(forKey: "appLockEnabled")
        return UserDefaults.standard.bool(forKey: "appLockEnabled")
    }

    func enableAppLock() {
        UserDefaults.standard.set(true, forKey: "appLockEnabled")
        appBeingUnlocked = true
    }

    func disableAppLock() {
        UserDefaults.standard.set(false, forKey: "appLockEnabled")
        appBeingUnlocked = false
    }


    func appLockValidation() {

        let laContext = LAContext()
        if checkIfBioMetricsAvailable() {
            let reason = "Enable App Lock"
            laContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in

                DispatchQueue.main.async {
                    guard success ,error == nil else {
                        print(error?.localizedDescription)
                        return
                    }
                }
            }
        }  else {
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }
    }



    func doUserLogOut() {
        self.delegate?.didChange(isLoading: true)
        userLogoutService?.doLogOutRequest(completion: { result in
            switch result {
              case .success(let _):
                self.delegate?.doLogOutAlert()
                self.delegate?.didChange(isLoading: false)
              case .failure(let error):
                self.delegate?.showErrorMessage()
                self.delegate?.didChange(isLoading: false)

            }

        })
    }
}
