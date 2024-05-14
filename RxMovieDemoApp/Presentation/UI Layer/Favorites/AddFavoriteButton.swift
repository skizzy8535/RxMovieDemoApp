//
//  AddFavoriteButton.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/4.
//


import UIKit
import RxSwift
import RxRelay


class AddFavoriteButton: UIButton {

    private let disposeBag = DisposeBag()
    private let viewModel = FavoritesViewModel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.tintColor = .red
        self.setBackgroundImage(UIImage(systemName: "heart"), for: .normal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func setStatus(status:Bool) {
        if (status) {
            self.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            self.setBackgroundImage(UIImage(systemName: "heart"), for: .normal)
        }
    }

    func setAddFavorite (favorites:PostFavoriteRecordModel) {
        viewModel.addToFavorites(movie: favorites)
        self.setStatus(status: true)
        self.layoutIfNeeded()
    }

    func deleteAddFavorite (item:FavoriteDeleted) {
        viewModel.deleteFromFavorites(item: item) {
            DispatchQueue.main.async {
                self.setStatus(status: false)
            }
        }
    }

}

