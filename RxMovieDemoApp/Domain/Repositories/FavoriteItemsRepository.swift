//
//  FavoriteItemsRepository.swift
//  RxMovieDemoApp
//
//  Created by NeferUser on 2024/4/23.
//

import Foundation
import RxSwift
import RxRelay
import Alamofire
import RxAlamofire

enum FavoriteItemsError:Error {
    case favoritesFetchError
}

protocol FavoriteItemsRepository {

    func getFavoriteMovieRecords(completion:@escaping (Result<FavoriteRecords,Error>) -> Void )
    func addFavoriteMovie(movie:PostFavoriteRecordModel)
    func deleteMovieFromFavorite(item: FavoriteDeleted)

}


class MockFavoriteItemsRepository:FavoriteItemsRepository {

    var mockFavoriteMovieRecords:Result<FavoriteRecords, Error> = .failure(FavoriteItemsError.favoritesFetchError)


    func getFavoriteMovieRecords(completion: @escaping (Result<FavoriteRecords, Error>) -> Void) {
        completion(mockFavoriteMovieRecords)
    }
    
    func addFavoriteMovie(movie: PostFavoriteRecordModel){
        //
    }
    
    func deleteMovieFromFavorite(item: FavoriteDeleted) {
        //
    }
//    

}
