//
//  FavoriteItemFetchSpecTests.swift
//  RxMovieDemoAppTests
//
//  Created by YuChen Lin on 2024/4/26.
//

import Foundation
import Quick
import Nimble
@testable import RxMovieDemoApp


class FavoriteItemFetchSpecTests: QuickSpec {

    override class func spec() {
        var delegate:MockFavoriteItemsLoadDelegate!
        var repository:MockFavoriteItemsRepository!
        var favsViewModel:FavoritesViewModel!
        
        
        beforeEach {
            delegate = MockFavoriteItemsLoadDelegate()
            repository = MockFavoriteItemsRepository()
            favsViewModel = FavoritesViewModel(favsItemService: repository)
        }
        
        

        describe("Get Favorites Items") {
            func mockGetFavsMovies(favs:Result<FavoriteRecords,Error>) {
                repository.mockFavoriteMovieRecords = favs
                favsViewModel.fetchFavorites()
            }

            func mockGetDummyFavs() -> Result<FavoriteRecords,Error> {
                return .success(FavoriteRecords(records: [
                    GetFavoriteRecordModel(id: "recYzmjwETYzFkiys",fields:
                                            FavoriteItems(userName: "Joe Random", movieID: 634492,
                                                          movieName: "Madame Web", posterURL: "https://image.tmdb.org/t/p/original//pwGmXVKUgKN13psUjlhC9zBcq1o.jpg"))
                ]))
            }


            context("When I load Successful") { 
                beforeEach {
                    mockGetFavsMovies(favs: mockGetDummyFavs())
                }

                it("should show on Favorite screen"){
                    expect(favsViewModel.favoriteMovieList.value).toNot(beNil())

                }

            }

            context("When I load failed") { 
                beforeEach {
                    mockGetFavsMovies(favs: .failure(FavoriteItemsError.favoritesFetchError))
                    delegate.showErrorMessage()
                }

                it("should show error"){ // Then
                    expect(delegate.didCallShowErrorMessage).to(beTrue())
                }
            }

        }

        describe("Add To Favorites") {

            func mockAddFavsMovies(addItem:Result<PostFavoriteRecordModel,Error>) {
                repository.mockAddToFavorites = addItem

                switch addItem {
                case .success(let newFavMovie):
                    favsViewModel.addToFavorites(movie: newFavMovie)
                case .failure(let error):
                    print("Error occurred: \(error)")
                }
            }

            func mockAddDummyFavs() -> Result<PostFavoriteRecordModel,Error> {
                return .success(PostFavoriteRecordModel(fields:
                                                            FavoriteItems(userName: "avian", movieID: 856289,
                                                                          movieName: "Creation of the Gods I: Kingdom of Storms",
                                                                          posterURL: "https://image.tmdb.org/t/p/original//2C3CdVzINUm5Cm1lrbT2uiRstwX.jpg")))
            }


            context("When I Add Successful") { 
                beforeEach {
                    mockAddFavsMovies(addItem: mockAddDummyFavs())

                }

                it("should add to favorites"){
                    expect(favsViewModel.recentFavs.value).toNot(beNil())

                }

            }

            context("When I Add failed") { 
                beforeEach {
                    mockAddFavsMovies(addItem:.failure(FavoriteItemsError.addToFavsError))
                    delegate.showErrorMessage()
                }

                it("should show error"){
                    expect(delegate.didCallShowErrorMessage).to(beTrue())
                }
            }

        }

        describe("Delete From Favorites") {

            func mockDeleteMovie(deletedItem:Result<FavoriteDeleted,Error> ) {
                repository.mockDeleteFromFavorites = deletedItem
                switch deletedItem {
                case .success(let deleteMovie):
                    favsViewModel.deleteFromFavorites(item: deleteMovie)

                case .failure(let error):
                    print("Error occurred: \(error)")
                }
            }

            func mockNextDeleteMovie() -> Result<FavoriteDeleted,Error> {
                return .success(FavoriteDeleted(id: "recYzmjwETYzFkiys", deleted: true))
            }

            context("When I Delete Successful") { 
                beforeEach {
                    mockDeleteMovie(deletedItem: mockNextDeleteMovie())
                }

                it("should delete from favorites"){
                     expect(favsViewModel.recentDelete.value).toNot(beNil())

                }

            }

            context("When I Delete failed") {
                beforeEach {
                    mockDeleteMovie(deletedItem:.failure(FavoriteItemsError.deleteFromFavsError))
                    delegate.showErrorMessage()
                }

                it("should show error"){
                    expect(delegate.didCallShowErrorMessage).to(beTrue())
                }
            }
        }


        describe("Check If movie is in Favorites") {
            
            func mockCheckResults(id: Int, checkBool: Result<(Bool,String),Error>) {
                repository.mockCheckIfFavs = checkBool

                switch checkBool {
                case .success(let (isUnique, resultID)):
                    favsViewModel.ifItsUniqueID.accept(resultID)
                case .failure(let error):
                    delegate.showErrorMessage()
                    print("Error occurred: \(error)")
                }
                
            }
            


            func mockResults() -> Result<(Bool,String),Error> {
                return .success((true,"recYzmjwETYzFkiys"))
            }

            context("When Check is available") {
                beforeEach {
                    mockCheckResults(id: 35678, checkBool: mockResults())

                }

                it("should check from favorites"){
                    expect(favsViewModel.ifItsUniqueID.value).toNot(beNil())
                }

            }

            context("When Check is invalid") {
                beforeEach {
                    mockCheckResults(id: 1222, checkBool: .failure(FavoriteItemsError.checkItemError))
                    delegate.showErrorMessage()

                }

                it("should show error"){
                    expect(delegate.didCallShowErrorMessage).to(beTrue())
                }
            }

        }

    }
}
