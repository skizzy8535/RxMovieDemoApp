//
//  MovieDownloadProvider.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/7.
//

import Foundation
import Alamofire

protocol DownloadProviderProtocol {
    func fetchMovieItems (url:String,
                          onComplete: @escaping (Result<Data,Error>) -> Void )
}

class MovieDownloadProvider: DownloadProviderProtocol{

    func fetchMovieItems (url:String,
                          onComplete: @escaping (Result<Data,Error>) -> Void ) {

        AF.request(url).response { response in

            print(response.request?.url?.absoluteString ?? "")

            if let error = response.error {
                onComplete(.failure(error))
                return
            }

            guard let data = response.data else {
                if let httpResponse = response.response {
                    onComplete(.failure(NSError(domain: "Response Error",
                                                code: httpResponse.statusCode,
                                                userInfo: nil)))
                }
                return
            }

            onComplete(.success(data))

        }

    }

}
