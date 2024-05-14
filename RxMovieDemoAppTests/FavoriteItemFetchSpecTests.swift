//
//  FavoriteItemFetchSpecTests.swift
//  RxMovieDemoAppTests
//
//  Created by NeferUser on 2024/4/26.
//

import Foundation
import Quick
import Nimble
@testable import RxMovieDemoApp


class FavoriteItemFetchSpecTests: QuickSpec {

    override class func spec() {

        var delegate:MockFavsLoadingDelegate!
        var repository:MockFavoriteItemsRepository!
        var favsViewModel:FavoritesViewModel!


        describe("Get Favorites Items") {

            func mockGetFavsMovies(favs:Result<FavoriteRecords,Error>) {
                repository.mockFavoriteMovieRecords = favs
                favsViewModel.fetchFavorites()
            }

            func mockAddFavsMovies(addItem:Result<PostFavoriteRecordModel,Error>) {
                repository.mockAddToFavorites = addItem
                switch addItem {
                  case .success(let newFavMovie):
                    favsViewModel.favsItemService?.addFavoriteMovie(movie: newFavMovie)
                  case .failure(let error):
                    print("Error occurred: \(error)")
                }
            }

            func mockDeleteMovie(deletedItem:Result<FavoriteDeleted,Error> ) {
                repository.mockDeleteFromFavorites = deletedItem
                switch deletedItem {
                  case .success(let deleteMovie):
                    favsViewModel.favsItemService?.deleteMovieFromFavorite(item: deleteMovie)
                case .failure(let error):
                    print("Error occurred: \(error)")
                }
            }



            func mockCheckUniqleMovie() {


//                repository.mockDeleteFromFavorites = deletedItem
//                switch deletedItem {
//                  case .success(let deleteMovie):
//                    favsViewModel.favsItemService?.deleteMovieFromFavorite(item: deleteMovie)
//                case .failure(let error):
//                    print("Error occurred: \(error)")
//                }
            }




            beforeEach {
                delegate = MockFavsLoadingDelegate()
                repository = MockFavoriteItemsRepository()
                favsViewModel = FavoritesViewModel(favsItemService: repository)
            }



        }
    }
}
