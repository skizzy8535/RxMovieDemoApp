//
//  MoviePosterView.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/3/26.
//

import UIKit
import RxSwift


class MoviePosterView: UIView {

    private let viewModel:MoviePosterViewModel
    private let disposeBag = DisposeBag()
    private var asceptRatio = 0.7

    private lazy var posterView :UITableView = {
        let tableView = UITableView()
        tableView.register(PosterTableViewCell.self, forCellReuseIdentifier: "PosterTableViewCell")
        return tableView
    }()


    init(id:Int) {
        self.viewModel = MoviePosterViewModel(id: "\(id)")
        super.init(frame: .zero)
        setLayout()
        bindPosterData()
        setupTheme()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setLayout() {
        addSubview(posterView)
        posterView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }


    private func bindPosterData() {
        viewModel.moviePosters
            .observe(on: MainScheduler.instance)
            .bind(to: posterView.rx.items) { (tableView,indexPath,item) in
            let cell  = tableView.dequeueReusableCell(withIdentifier: "PosterTableViewCell") as! PosterTableViewCell
            cell.selectionStyle = .none
            cell.configureCell(posterPath: item.file_path, ratio: item.aspect_ratio, fixedWidth: self.posterView.bounds.width-20)
            self.asceptRatio = item.aspect_ratio
            return cell
        }.disposed(by: self.disposeBag)
    }
}


extension MoviePosterView:ThemeChangeDelegate {
    func setupTheme() {
        self.theme.backgroundColor = themeService.attribute {$0.backgroundColor}
    }
}
