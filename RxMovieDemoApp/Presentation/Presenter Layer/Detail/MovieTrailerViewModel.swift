//
//  MovieTrailerViewModel.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/3/25.
//

import Foundation
import RxSwift
import RxRelay
import RxDataSources
import RxCocoa


class MovieTrailerViewModel {

    private let movieFetchService:MovieFetchRepository?

    let disposeBag = DisposeBag()
    var trailerMovieModels:BehaviorRelay<[MovieTrailerDetail]> = BehaviorRelay(value: [])

    init(contentID: String,
         movieFetchService:MovieFetchRepository = MovieFetchService()) {
        self.movieFetchService = movieFetchService
        self.fetchTrailer(contentID: contentID)

    }


  private func fetchTrailer (contentID:String) {

     let url = MovieUseCase.configureUrlString(trailerID: contentID)


      movieFetchService?.fetchPlayTrailer(url: url, completion: { [self] result in
          switch result {
          case .success(let trailers):
              let trailerModels = Observable.just(self.parseTrailerListData(trailer: trailers))
              trailerModels
                  .bind(to: trailerMovieModels)
                  .disposed(by: self.disposeBag)
          case .failure(let error):
              print("Error \(error)")
          }
      })

    }

    private func parseTrailerListData(trailer:MovieTrailer) -> [MovieTrailerDetail] {

        return trailer.results.map { data in
            return MovieTrailerDetail(name: data.name,
                                           key: data.key,
                                           published_at: data.published_at)
        }
    }



}
