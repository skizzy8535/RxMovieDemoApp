//
//  UserService.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/25.
//

import Foundation
import Security

class UserService :UserRepository{
    func sendRequest(user: User, status: UserInfoStatus, completion: @escaping (Result<UserInfo, Error>) -> Void) {

        var targetURL: String
        switch status {
        case .login:
            targetURL = AppConstant.SESSION_BASEURL
        case .register:
            targetURL = AppConstant.SIGNUP_BASEURL
        }

        guard let url = URL(string: targetURL) else {
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Token token=\"\(AppConstant.LOGIN_TOKEN)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue(AppConstant.CONTENTTYPE_JSON, forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()


        do {
            let data = try encoder.encode(user)

            urlRequest.httpBody = data

            print("收到使用者資料 :",String(data: urlRequest.httpBody!, encoding: .utf8) ?? "post error")

            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Status Code: \(httpResponse.statusCode)")

                }

                if let data = data,
                   let response = String(data: data, encoding: .utf8) {
                    print("Response \(response)")

                    let decoder = JSONDecoder()
                    do {
                        let item = try decoder.decode(UserInfo.self, from: data)
                        if let message = item.message {
                            print("如果遇到錯誤", message)
                            completion(.failure(UserInfoError.invalidInfo))
                        } else if let userToken = item.userToken {
                            print("如果成功", item)
                            UserResponseUseCase.saveUserToken(token: userToken)
                            completion(.success(item))
                        }
                    } catch {
                        completion(.failure(UserInfoError.decodeError))
                    }
                } else {
                    completion(.failure(UserInfoError.decodeError))

                }
            }
            task.resume()
        } catch {
            completion(.failure(UserInfoError.encodeError))
        }

    }


    func doLogOutRequest(completion:@escaping (Result<Bool,Error> )->Void ) {
        let url =  AppConstant.SESSION_BASEURL
        let savedUserToken = UserResponseUseCase.getUserToken()
        
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.httpMethod = "DELETE"
        urlRequest.setValue("Token token=\"\(AppConstant.LOGIN_TOKEN)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue(AppConstant.CONTENTTYPE_JSON, forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(savedUserToken, forHTTPHeaderField: "User-Token")

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in

            if let error = error {
                completion(.failure(error))
            }

            guard let data = data ,
                  let response = String(data: data, encoding: .utf8) else {
                completion(.failure(UserInfoError.invalidInfo))
                return
            }

            print("logged out",response)
            completion(.success(true))
            UserResponseUseCase.deleteUserToken()

        }.resume()
    }
    
    

}
