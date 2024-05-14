//
//  MovieFetchService.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/25.
//

import Foundation
import RxRelay
import Alamofire

class MovieFetchService: MovieFetchRepository {

    private var provider: DownloadProviderProtocol?

    init(provider: DownloadProviderProtocol = MovieDownloadProvider()) {
        self.provider = provider
    }


    func fetchHomeDisplay(url: String, completion: @escaping (Result<MovieHomeList, Error>) -> Void) {
        self.provider?.fetchMovieItems(url: url) { result in
            switch result {
                
            case .success(let items):
                if let movieHomeItems = try? JSONDecoder().decode(MovieHomeList.self, from: items) {
                    completion(.success(movieHomeItems))
                } else {
                    completion(.failure(MovieError.movieHomeListError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }


    func fetchMovieExploreList(url: String, completion: @escaping (Result<MovieExploreList, Error>) -> Void) {
        self.provider?.fetchMovieItems(url: url) { result in

            switch result {
            case .success(let items):
                if let movieExploreItems = try? JSONDecoder().decode(MovieExploreList.self, from: items) {
                    completion(.success(movieExploreItems))
                } else {
                    completion(.failure(MovieError.movieExploreListError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchMovieDetail(url: String, completion: @escaping (Result<MovieDetail, Error>) -> Void) {
        self.provider?.fetchMovieItems(url: url) { result in

            switch result {
            case .success(let items):
                if let movieDetail = try? JSONDecoder().decode(MovieDetail.self, from: items) {
                    completion(.success(movieDetail))

                } else {
                    completion(.failure(MovieError.movieDetailError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchPlayTrailer(url: String, completion: @escaping (Result<MovieTrailer, Error>) -> Void) {
        self.provider?.fetchMovieItems(url: url) { result in

            switch result {
            case .success(let items):
                if let movieTrailers = try? JSONDecoder().decode(MovieTrailer.self, from: items) {
                    completion(.success(movieTrailers))
                } else {
                    completion(.failure(MovieError.movieTrailerError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchMoviePoster(url: String, completion: @escaping (Result<MoviePoster, Error>) -> Void) {
        self.provider?.fetchMovieItems(url: url) { result in

            switch result {
            case .success(let items):
                if let moviePosters = try? JSONDecoder().decode(MoviePoster.self, from: items) {
                    completion(.success(moviePosters))
                } else {
                    completion(.failure(MovieError.moviePosterError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchMovieSimilarities(url: String, completion: @escaping (Result<MovieSimilarities, Error>) -> Void) {
        self.provider?.fetchMovieItems(url: url) { result in
            switch result {

            case .success(let items):
                if let movieSimilarities = try? JSONDecoder().decode(MovieSimilarities.self, from: items) {
                    completion(.success(movieSimilarities))
                } else {
                    completion(.failure(MovieError.movieSimilaritiesError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}
