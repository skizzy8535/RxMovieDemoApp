//
//  LoginViewModel.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/22.
//

import Foundation


class LoginViewModel {

    var delegate:LoginLoadDelegate?
    private let userLoginService:UserRepository?

    init(userLoginService: UserRepository? = UserService()) {
        self.userLoginService = userLoginService
    }


    func doRetrieveInfo(){
        self.delegate?.doRetrieveSaveAccountInfo()
    }

    func doUserLogin(userName:String,password:String ,status:UserInfoStatus) {

//        self.delegate?.didChange(isLoading: true)

        var userData :User = User(user: UserDetail(login: userName, password: password))

        userLoginService?.sendRequest(user: userData, status: status, completion: { result in

            switch result {
              case .success(let item):
                self.delegate?.showSuccessMessage()
                UserReponseUseCase.saveNewUserStatus(userResponse: item)
                self.delegate?.doVerifyAccountAction()
                self.delegate?.didChange(isLoading: true)

              case .failure(let error):
             //   self.delegate?.showErrorMessage()
                self.delegate?.didChange(isLoading: false)

            }
        })

    }

}


