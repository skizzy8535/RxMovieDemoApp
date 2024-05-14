//
//  FavoriteItemsRepository.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/23.
//

import Foundation
import RxSwift
import RxRelay
import Alamofire
import RxAlamofire

enum FavoriteItemsError:String,Error {
    case favoritesFetchError
    case addToFavsError
    case deleteFromFavsError
    case checkItemError
}

protocol FavoriteItemsRepository {
    func getFavoriteMovieRecords(completion:@escaping (Result<FavoriteRecords,Error>) -> Void )
    func addFavoriteMovie(movie:PostFavoriteRecordModel)
    func deleteMovieFromFavorite(item: FavoriteDeleted)
    func checkIfIsFavsMovie(id: Int, completion: @escaping (Result<(Bool, String), Error>) -> Void)
}


class MockFavoriteItemsRepository:FavoriteItemsRepository {

    var mockFavoriteMovieRecords:Result<FavoriteRecords, Error> = .failure(FavoriteItemsError.favoritesFetchError)
    var mockAddToFavorites:Result<PostFavoriteRecordModel, Error> = .failure(FavoriteItemsError.favoritesFetchError)
    var mockDeleteFromFavorites:Result<FavoriteDeleted, Error> = .failure(FavoriteItemsError.favoritesFetchError)
    var mockCheckIfFavs:Result<(Bool,String),Error> = .failure(FavoriteItemsError.favoritesFetchError)

    var haveGetFavroites:Bool = false
    var haveAddedToFavorite:Bool = false
    var haveDeleteFromFavorite:Bool = false
    var checkIfUniqueMovie:Bool = false

    func getFavoriteMovieRecords(completion: @escaping (Result<FavoriteRecords, Error>) -> Void) {
        completion(mockFavoriteMovieRecords)
    }


    func addFavoriteMovie(movie: PostFavoriteRecordModel) {
        haveAddedToFavorite = true

    }

    func deleteMovieFromFavorite(item: FavoriteDeleted) {
        haveDeleteFromFavorite = true
    }


   func checkIfIsFavsMovie(id: Int, completion: @escaping (Result<(Bool, String), Error>) -> Void) {
       completion(mockCheckIfFavs)
    }
}
