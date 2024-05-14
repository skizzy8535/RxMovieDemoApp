//
//  MovieListFetchSpecTests.swift
//  RxMovieDemoAppTests
//
//  Created by YuChen Lin on 2024/4/25.
//

import Foundation
import Quick
import Nimble
@testable import RxMovieDemoApp

class MovieListFetchSpecTests: QuickSpec {
    override class func spec() {
        var delegate:MockMovieHomeLoadDelegate!
        var repository:MockMovieFetchRepository!
        var movieHomeViewModel:MovieHomeFetchViewModel!
            describe("Get Home Movie"){  // Given

                func getHomeListMovieToViewModel(result: Result<MovieHomeList,Error> ) {
                    repository.mockHomeListResult = result
                    movieHomeViewModel.setAll()
                }

                func getDummyHomeListMovie() -> Result<MovieHomeList,Error> {
                    return .success(MovieHomeList(results: [
                        MovieHomeListData(id: 1096197, title: "No Way Up", backdrop_path: "/4woSOUD0equAYzvwhWBHIJDCM88.jpg",
                                          poster_path: "/hu40Uxp9WtpL34jv3zyWLb5zEVY.jpg", vote_average: 6.37)
                    ]))
                }

                beforeEach {
                    delegate = MockMovieHomeLoadDelegate()
                    repository = MockMovieFetchRepository()
                    movieHomeViewModel = MovieHomeFetchViewModel(movieFetchService: repository)
                }

                context("When I load Successful") { // When
                    beforeEach {
                      getHomeListMovieToViewModel(result: getDummyHomeListMovie())
                    }

                    it("should show on Home screen"){ // Then
                        expect(movieHomeViewModel.nowPlayingMovie.value).toNot(beNil())
                        
                    }

                }

                context("When I load failed") { // When
                    beforeEach {
                        getHomeListMovieToViewModel(result: .failure(MovieError.movieHomeListError))
                        delegate.showErrorMessage() 
                    }

                    it("should show error"){ // Then
                        expect(delegate.didCallShowErrorMessage).to(beTrue())
                    }
                }
            }
        }
}
