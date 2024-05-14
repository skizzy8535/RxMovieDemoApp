//
//  FavoriteItemsServicw.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/25.
//

import Foundation
import RxSwift
import Alamofire
import RxAlamofire

class FavoriteItemsService: FavoriteItemsRepository {

    private let disposeBag = DisposeBag()


    func getFavoriteMovieRecords(completion: @escaping (Result<FavoriteRecords, Error>) -> Void) {
        let url = URL(string: AppConstant.AIRTABLE_API_BASEURL)!
        let headers:HTTPHeaders = ["Authorization": "Bearer \(AppConstant.AIRTABLE_TOKEN)"]

        RxAlamofire.requestData(.get, url, headers: headers)
            .subscribe(onNext: { [weak self] (response, data) in

                if let records = try? JSONDecoder().decode(FavoriteRecords.self, from: data) {
                    completion(.success(records))
                }

            }, onError: { error in
                completion(.failure(error))

            })

            .disposed(by: disposeBag)
    }

    func addFavoriteMovie(movie: PostFavoriteRecordModel){
        let url = URL(string: AppConstant.AIRTABLE_API_BASEURL)!
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("Bearer \(AppConstant.AIRTABLE_TOKEN)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("\(AppConstant.CONTENTTYPE_JSON)", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        let encoder = JSONEncoder()

        do {
            let movieData = try encoder.encode(movie)
            urlRequest.httpBody = movieData

            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in

                if let resultData = data  {
                    let result = try! JSONDecoder().decode(GetFavoriteRecordModel.self, from: resultData)
                    print(result)
                }
            }
            task.resume()
        } catch {
            print(FetchFavoriteError.encodeError)
        }
    }

    func deleteMovieFromFavorite(item: FavoriteDeleted) {
        let url = URL(string: "\(AppConstant.AIRTABLE_API_BASEURL)/\(item.id)")!

        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("Bearer \(AppConstant.AIRTABLE_TOKEN)", forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = "DELETE"

        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in


            if let error = error {
                print("Error deleting movie from favorites: \(error)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Delete Success")
            } else {
                print("Unexpected response while deleting movie from favorites")
            }
        }
        task.resume()
    }


    func checkIfIsFavsMovie(id: Int, completion: @escaping (Result<(Bool, String), Error>) -> Void) {

        self.getFavoriteMovieRecords { result in
            switch result {
              case .success(let fullResult):

                guard let uniqFavsID = fullResult.records.first(where: {$0.fields.movieID == id}) else  {
                    completion(.success((false,"")))
                    return
                }

                completion(.success((true,uniqFavsID.id)))

               case .failure(let _):
                completion(.failure(FavoriteItemsError.addToFavsError))
            }
        }
    }

}
