//
//  MoviePosterViewModel.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/19.
//

import Foundation
import RxSwift
import RxRelay


class MoviePosterViewModel {

    var moviePosters:BehaviorRelay<[MoviePosterDetail]> = BehaviorRelay(value:[])
    private let disposeBag = DisposeBag()

    private let movieFetchService:MovieFetchRepository?


    init(id:String,movieFetchService:MovieFetchRepository = MovieFetchService()) {
        self.movieFetchService = movieFetchService
        self.fetchMoviePoster(id:id)
    }

    private func fetchMoviePoster (id:String){
        let url = MovieUseCase.configureUrlString(posterKey: id)

        movieFetchService?.fetchMoviePoster(url: url, completion: { [self] result in
            switch result {
            case .success(let posters):
                let posterModels = Observable.just(self.parsePosterData(poster: posters))
                posterModels
                    .bind(to: moviePosters)
                    .disposed(by: self.disposeBag)
            case .failure(let error):
                print("Error \(error)")
            }
        })
    }

    private func parsePosterData(poster:MoviePoster) -> [MoviePosterDetail] {
        return poster.backdrops.map { model in
            MoviePosterDetail(aspect_ratio: model.aspect_ratio,
                                   file_path: model.file_path)

        }
    }
}
