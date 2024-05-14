//
//  MovieDetailViewModel.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/2/24.

//

import Foundation
import RxSwift
import RxCocoa

class MovieDetailViewModel {

    var delegate:MovieDetailLoadingDelegate?
    let movieDetailData = BehaviorRelay<MovieDetail?>(value: nil)
    private let disposeBag = DisposeBag()
    private let movieFetchService:MovieFetchRepository?
    init(contentId: Int,movieFetchService:MovieFetchRepository = MovieFetchService()) {
        self.movieFetchService = movieFetchService
        self.requestData(contentId: contentId)
    }

    func requestData(contentId: Int) {

        self.delegate?.didChange(isLoading: true)


        let url = MovieUseCase.configureUrlString(id: contentId)

        movieFetchService?.fetchMovieDetail(url: url, completion: { [self] result in

            switch result {
            case .success(let detailItems):
                self.movieDetailData.accept(detailItems)

                self.delegate?.presentMovieDetail()
                self.delegate?.didChange(isLoading: false)

            case .failure(let error):
                self.delegate?.showErrorMessage()
                self.delegate?.didChange(isLoading: false)

            }
        })

    }

}
