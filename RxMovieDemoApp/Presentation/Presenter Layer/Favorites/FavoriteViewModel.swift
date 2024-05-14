//
//  FavoriteViewModel.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/19.
//

import Foundation
import RxSwift
import RxRelay

enum FetchFavoriteError:String,Error {
    case invalidFetch
    case decodeError
    case encodeError
}

class FavoritesViewModel {
    var delegate: MovieFavsLoadingDelegate?
    private let disposeBag = DisposeBag()

    var favoriteMovieList :BehaviorRelay<[GetFavoriteRecordModel]> = BehaviorRelay(value:[])
    var recentFavs:BehaviorRelay<PostFavoriteRecordModel?> = BehaviorRelay(value: nil)
    var recentDelete:BehaviorRelay<FavoriteDeleted?> = BehaviorRelay(value: nil)
    var ifItsUniqueID :BehaviorRelay<String?> = BehaviorRelay(value: nil)

    var favsItemService:FavoriteItemsRepository?

    init(favsItemService: FavoriteItemsRepository = FavoriteItemsService()) {
        self.favsItemService = favsItemService
    }


    func fetchFavorites() {
        self.delegate?.didChange(isLoading: true)
        favsItemService?.getFavoriteMovieRecords(completion: { result in
            switch result {
            case .success(let fullRecord):
                self.favoriteMovieList.accept(fullRecord.records)
                self.delegate?.presentFavMovieItems()
                self.delegate?.didChange(isLoading: false)
            case .failure(let error):
                self.delegate?.showErrorMessage()
                self.delegate?.didChange(isLoading: false)
            }
        })
    }


    func checkIfIsFavsMovie(id:Int,completion: @escaping (Result<(Bool, String), Error>) -> Void) {

        favsItemService?.checkIfIsFavsMovie(id: id, completion: { result in
            switch result {
            case .success(let (isUnique, uniqueID)):

                if isUnique {
                    self.ifItsUniqueID.accept(uniqueID)
                    completion(.success((true, uniqueID)))
                } else {
                    self.ifItsUniqueID.accept("")
                    completion(.success((false, "")))

                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        })


    }


    func addToFavorites(movie:PostFavoriteRecordModel) {
        recentFavs.accept(movie)
        favsItemService?.addFavoriteMovie(movie: movie)
    }


    func deleteFromFavorites (item: FavoriteDeleted) {
        recentDelete.accept(item)
        favsItemService?.deleteMovieFromFavorite(item:item)
    }
}

