//
//  MovieTrailerView.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/3/21.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import RxDataSources


protocol ClickTrailerDelegate {
    func clickTrailer(key:String)
}


class MovieTrailerView: UIView {

    private let disposeBag = DisposeBag()

    private let trailerViewModel: MovieTrailerViewModel

    var delegate:ClickTrailerDelegate?

    lazy var trailerView :UITableView = {
        let tableView = UITableView()
        tableView.register(TrailerTableViewCell.self, forCellReuseIdentifier: "TrailerTableViewCell")
        tableView.backgroundColor = AppConstant.COMMON_MAIN_COLOR
        return tableView
    }()

    init(id:Int) {
        self.trailerViewModel = MovieTrailerViewModel(contentID: "\(id)")
        super.init(frame: .zero)
        self.backgroundColor = AppConstant.COMMON_MAIN_COLOR
        trailerView.rx.setDelegate(self).disposed(by: self.disposeBag)
        setLayout()
        bindViewModel()

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func setLayout() {
        self.addSubview(trailerView)

        trailerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }


    private func bindViewModel() {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, MovieTrailerDetail>>(
            configureCell: { _, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "TrailerTableViewCell", for: indexPath) as! TrailerTableViewCell
                cell.backgroundColor = AppConstant.COMMON_MAIN_COLOR
                cell.selectionStyle = .none
                cell.confireCell(thumbnailStr: item.key, titleStr: item.name, timeStr: item.published_at)
                return cell
            }
        )

        trailerViewModel.trailerMovieModels
            .map { [SectionModel(model: "", items: $0)] }
            .bind(to: trailerView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)


        trailerView.rx.itemSelected.subscribe(onNext: { [self] element in
            let videoKey = self.trailerViewModel.trailerMovieModels.value[element.row].key
            delegate?.clickTrailer(key: videoKey)
        }).disposed(by: self.disposeBag)

    }

}

extension MovieTrailerView :UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}

