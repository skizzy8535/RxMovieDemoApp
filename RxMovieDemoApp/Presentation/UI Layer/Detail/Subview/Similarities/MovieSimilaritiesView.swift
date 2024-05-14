//
//  MovieSimilaritiesView.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/3/20.
//

import SnapKit
import UIKit
import RxSwift
import RxCocoa
import RxRelay
import RxDataSources


class MovieSimilarView: UIView {

    private let disposeBag = DisposeBag()

    private let similarViewModel: MovieSimilarViewModel

    var similarView :UICollectionView = {

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 170, height: 240)
        layout.estimatedItemSize = .zero
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MovieSimilaritiesCell.self, forCellWithReuseIdentifier: "MovieSimilaritiesCell")
        collectionView.backgroundColor = AppConstant.COMMON_MAIN_COLOR
        collectionView.contentInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        return collectionView
    }()


    init(id: Int) {
        self.similarViewModel = MovieSimilarViewModel(contentID: id)
        super.init(frame: .zero)
        self.backgroundColor = AppConstant.COMMON_MAIN_COLOR
        setLayout()
        bindViewModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setLayout() {
        self.addSubview(similarView)

        similarView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func bindViewModel() {
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, MovieSimilaritiesDetail>>(
            configureCell: { _, collectionView, indexPath, item in

                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieSimilaritiesCell", for: indexPath) as! MovieSimilaritiesCell
                cell.backgroundColor = AppConstant.COMMON_MAIN_COLOR
                cell.configCell(imgURL: item.poster_path ?? "", voteRate: item.vote_average)
                return cell
            })

        similarViewModel.similarMovies
            .map {[SectionModel(model: "", items: $0)]}
            .bind(to: similarView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        self.similarView.reloadData()
    }


}

