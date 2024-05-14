//
//  UserRepository.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/19.
//
import Foundation
import RxSwift
import RxRelay
import RxCocoa

enum UserInfoStatus{
    case login
    case register
}

enum UserInfoError:String,Error {
    case invalidInfo
    case decodeError
    case encodeError
}


protocol UserRepository {
    func sendRequest(user:User,status: UserInfoStatus, completion: @escaping (Result<UserInfo, Error>) -> Void)
    func doLogOutRequest(completion:@escaping (Result<Bool,Error> )->Void )
}



class MockUserRepository:UserRepository {
    
    var mockUserInfoResult :Result<UserInfo, Error> = .failure(UserInfoError.invalidInfo)
    var mockUserLogResult :Result<Bool, Error> = .failure(false as! Error)

    func sendRequest(user: User, status: UserInfoStatus, completion: @escaping (Result<UserInfo, Error>) -> Void) {
        completion(mockUserInfoResult)
    }

    func doLogOutRequest(completion: @escaping (Result<Bool, Error>) -> Void) {
        completion(mockUserLogResult)
    }
}
