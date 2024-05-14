//
//  MovieSimilaritiesViewModel.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/19.
//

import Foundation
import RxSwift
import RxRelay


class MovieSimilarViewModel{

    var similarMovies:BehaviorRelay<[MovieSimilaritiesDetail]> = BehaviorRelay(value: [])

    private let disposeBag = DisposeBag()
    private var movieFetchService:MovieFetchRepository?


    init(contentID:Int,movieFetchService:MovieFetchRepository = MovieFetchService()){
        self.movieFetchService = movieFetchService
        self.fetchSimilarMovies(id: contentID)
    }

    private func fetchSimilarMovies(id:Int) {
        let url = MovieUseCase.configureUrlString(similarID: id)

        movieFetchService?.fetchMovieSimilarities(url: url, completion: { [self] result in
            switch result {
            case .success(let similarities):
                let similaritiesModels = Observable.just(self.parseToSimilarMovieModel(similar: similarities))
                
                similaritiesModels
                    .bind(to: similarMovies)
                    .disposed(by: self.disposeBag)
            case .failure(let error):
                print("Error \(error)")
            }
        })

    }


    private func parseToSimilarMovieModel (similar:MovieSimilarities) -> [MovieSimilaritiesDetail]{
        return similar.results.map({
            MovieSimilaritiesDetail(id: $0.id, poster_path: $0.poster_path, vote_average: $0.vote_average)
        })
    }


}
