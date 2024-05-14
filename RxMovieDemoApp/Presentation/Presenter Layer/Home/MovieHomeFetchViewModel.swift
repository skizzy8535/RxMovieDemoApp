//
//  MovieHomeFetchViewModel.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/1/22.
//

import Foundation
import RxSwift
import RxRelay

class MovieHomeFetchViewModel{

   var delegate: MovieHomeLoadingDelegate?
   private let disposeBag = DisposeBag()

    var movieFetchService:MovieFetchRepository?
    init(movieFetchService: MovieFetchRepository = MovieFetchService()) {
        self.movieFetchService = movieFetchService
    }
    var nowPlayingMovie:BehaviorRelay<[MovieHomeListData]> = BehaviorRelay(value: [])
    var popularMovie:BehaviorRelay<[MovieHomeListData]> = BehaviorRelay(value: [])
    var upcomingMovie:BehaviorRelay<[MovieHomeListData]> = BehaviorRelay(value: [])
    var topRatedMovie:BehaviorRelay<[MovieHomeListData]> = BehaviorRelay(value: [])

    func setAll() {
        fetchNowPlaying()
        fetchPopular()
        fetchUpcoming()
        fetchTopRated()
        setResultToHomeScreen()
    }

    func setResultToHomeScreen(){
        self.delegate?.didChange(isLoading: true)

        Observable.zip(nowPlayingMovie, popularMovie, upcomingMovie,topRatedMovie)
            .subscribe(onNext: { [weak self] (nowPlaying, popular, upcoming, topRated) in
                guard let self = self else { return }
                self.delegate?.presentHomeDisplayItems(nowPlayingMovies: nowPlaying,
                                                       popularMovies: popular,
                                                       upcomingMovies: upcoming,
                                                       topRatedMovies: topRated)

                self.delegate?.didChange(isLoading: false)
            }, onError: { [weak self] error in
                self?.delegate?.showErrorMessage()
                self?.delegate?.didChange(isLoading: false)

            })
            .disposed(by: disposeBag)
    }

    private func fetchNowPlaying() {
          let nowPlayingURL = MovieUseCase.configureUrlString(genre: .nowPlaying)
          movieFetchService?.fetchHomeDisplay(url: nowPlayingURL) { [weak self] result in
              guard let self = self else { return }

              switch result {
              case .success(let nowPlayingMovies):
                  let parsedMovies = self.parseMovieHomeListData(model: nowPlayingMovies)
                  self.nowPlayingMovie.accept(parsedMovies)

              case .failure(let error):
                  print(error)
              }
          }
      }

    private func fetchPopular() {

        let popularURL = MovieUseCase.configureUrlString(genre: .popular)
          movieFetchService?.fetchHomeDisplay(url: popularURL) { [weak self] result in
              guard let self = self else { return }

              switch result {
              case .success(let popularMovies):
                  let parsedMovies = self.parseMovieHomeListData(model: popularMovies)
                  self.popularMovie.accept(parsedMovies)

              case .failure(let error):
                  print(error)
              }
          }
      }

    private func fetchUpcoming() {
         let upcomingURL = MovieUseCase.configureUrlString(genre: .upcoming)
          movieFetchService?.fetchHomeDisplay(url: upcomingURL) { [weak self] result in
              guard let self = self else { return }

              switch result {
              case .success(let upcomingMovies):
                  let parsedMovies = self.parseMovieHomeListData(model: upcomingMovies)
                  self.upcomingMovie.accept(parsedMovies)

              case .failure(let error):
                  print(error)
              }
          }
      }

    private func fetchTopRated() {
          let topRatedURL = MovieUseCase.configureUrlString(genre: .topRated)
          movieFetchService?.fetchHomeDisplay(url: topRatedURL) { [weak self] result in
              guard let self = self else { return }

              switch result {
              case .success(let topRatedMovies):
                  let parsedMovies = self.parseMovieHomeListData(model: topRatedMovies)
                  self.topRatedMovie.accept(parsedMovies)

              case .failure(let error):
                  print(error)
              }
          }
      }

    private func parseMovieHomeListData(model:MovieHomeList) -> [MovieHomeListData] {

        return model.results.map { listData in
            return MovieHomeListData(id: listData.id,
                                 title: listData.title,
                                 backdrop_path: listData.backdrop_path,
                                 poster_path: listData.poster_path,
                                 vote_average :listData.vote_average)
        }
    }

}


