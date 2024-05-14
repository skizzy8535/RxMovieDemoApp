//
//  RegisterViewModel.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/22.
//

import Foundation


class RegisterViewModel {

    var delegate:RegisterLoadDelegate?
    private let userRegisterService:UserRepository?

    init(userRegisterService: UserRepository? = UserService()) {
        self.userRegisterService = userRegisterService
    }


    func doUserRegister(user:String,password:String ,status:UserInfoStatus) {
        self.delegate?.didChange(isLoading: true)
        var userData :User?
            userData = User(user: UserDetail(login: user, password: password))

            userRegisterService?.sendRequest(user: userData!, status: status, completion: { result in
                switch result {
                case .success(let item):
                    UserReponseUseCase.saveNewUserStatus(userResponse: item)
                    self.delegate?.doRegisterAccountAction()
                    self.delegate?.didChange(isLoading: false)
                case .failure(let error):
                    print(error)
                    self.delegate?.showErrorMessage()
                    self.delegate?.didChange(isLoading: false)
                }
            })
    }

}

