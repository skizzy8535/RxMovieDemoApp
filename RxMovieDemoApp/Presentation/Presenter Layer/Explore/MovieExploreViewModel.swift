//
//  MovieExploreViewModel.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/2/16.
//

import Foundation
import RxSwift
import RxRelay


class MovieExploreViewModel {
    private let disposeBag = DisposeBag()
    private var explorePage:Int = 1
    var movieFetchService:MovieFetchRepository?

    var exploreResult:BehaviorRelay<[MovieExploreListData]> = BehaviorRelay(value: [])

    init(movieFetchService: MovieFetchRepository = MovieFetchService()) {
        self.movieFetchService = movieFetchService
    }

    func startExplore(keyword: String, page: Int) {

        if keyword.count == 0 {
            self.clearExplore()
            return
        }

        let keywordURL = MovieUseCase.configureUrlString(keyword: keyword, page: page)


        movieFetchService?.fetchMovieExploreList(url: keywordURL, completion: { [self] result in
            switch result {
            case .success(let exploreItems):
                let exploreModels = Observable.just(self.parseExploreData(exploreData: exploreItems))
                exploreModels
                    .subscribe(onNext: { data in
                        self.exploreResult.accept(self.exploreResult.value + data)
                    })
                    .disposed(by: self.disposeBag)
            case .failure(let error):
                print("Error \(error)")
            }
        })
        
    }


    func clearExplore() {
        exploreResult.accept([])
    }


    private func parseExploreData(exploreData:MovieExploreList) -> [MovieExploreListData] {
        return exploreData.results.map{ listData in
            return MovieExploreListData(id:listData.id,
                                   poster_path:listData.poster_path,
                                   vote_average:listData.vote_average)
        }
    }
}

