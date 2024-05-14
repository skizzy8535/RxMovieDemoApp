//
//  FavoritesViewController.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/2/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import JGProgressHUD
import RxTheme


class FavoritesViewController: UIViewController {
    private let viewModel = FavoritesViewModel()
    private let disposeBag = DisposeBag()

    private lazy var backButton :UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.tintColor = .white
        return button
    }()

    private var titleLabel :UILabel = {
        let label = UILabel()
        label.text = "Favorite Movies"
        label.textAlignment = .center
        return label
    }()


    private let hud : JGProgressHUD = {
        let hud = JGProgressHUD()
        hud.textLabel.text = "Loading ..."
        hud.detailTextLabel.text = "Please Wait"
        return hud
    }()

    private lazy var movieCollectionView:UICollectionView = {
        let defaultSize = self.view.bounds.width / 2
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: defaultSize - 15, height: 180)
        layout.estimatedItemSize = .zero
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.register(FavoritesCollectionViewCell.self, forCellWithReuseIdentifier: "FavoritesCollectionViewCell")
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchFavorites()
        viewModel.delegate = self
        setLayout()
        setData()
        setupTheme()
    }


    private func setLayout(){
        self.view.addSubview(backButton)
        self.view.addSubview(titleLabel)
        self.view.addSubview(movieCollectionView)

        backButton.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(5)
            make.left.equalToSuperview().offset(10)
            make.width.height.equalTo(30)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(5)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(35)
        }


        movieCollectionView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
        }
    }

    private func setData() {
        viewModel.favoriteMovieList.subscribe { _ in
            self.movieCollectionView.reloadData()
        }.disposed(by: self.disposeBag)

    }

    @objc private func backButtonAction() {
            self.dismiss(animated: true,completion: nil)
    }
}

extension FavoritesViewController:UICollectionViewDelegate,UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.favoriteMovieList.value.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoritesCollectionViewCell", for: indexPath) as! FavoritesCollectionViewCell
        let item = viewModel.favoriteMovieList.value[indexPath.item]
        cell.delegate = self
        cell.configureCell(item: item,id:item.id)
        cell.configFavStatus(isFavorite:true)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Select at \(indexPath.item)")
        let contentID = viewModel.favoriteMovieList.value[indexPath.item].fields.movieID
        let movieDetailsVC = MovieDetailsViewController(id: contentID,popType: .withoutNavPresent)
        movieDetailsVC.modalPresentationStyle = .fullScreen
        self.present(movieDetailsVC, animated: true)
    }

}

extension FavoritesViewController:FavoritesCollectionViewCellDelegate{
    func didTapButton(in cell: UICollectionViewCell) {


        if let indexPath = movieCollectionView.indexPath(for: cell) ,
           let favCell = cell as? FavoritesCollectionViewCell {

            let newIsFavorite = !favCell.isFavorite
            favCell.isFavorite = newIsFavorite

            let item = viewModel.favoriteMovieList.value[indexPath.item]
            let contentID = favCell.contentID

            if (newIsFavorite) {

                guard let userInfo = FetchUserUseCase.readFile() else {
                    print("Can't get User name")
                    return
                }

                let postModel = PostFavoriteRecordModel(fields:
                                                            FavoriteItems(userName: userInfo.login ?? "YuChen Lin",
                                                                          movieID: item.fields.movieID,
                                                                          movieName: item.fields.movieName,
                                                                          posterURL: item.fields.posterURL))
                favCell.collectBtn.setAddFavorite(favorites: postModel)

            } else {

                let readyDeleteItem =  FavoriteDeleted(id:contentID,deleted: true)
                print(readyDeleteItem)
                favCell.collectBtn.deleteAddFavorite(item: readyDeleteItem)

            }

        }
    }
}


extension FavoritesViewController:MovieFavsLoadingDelegate{


    func didChange(isLoading: Bool) {
        if isLoading {
            hud.show(in: self.view)
        } else {
            hud.dismiss()
        }
    }

    func showErrorMessage(error: String) {
        hud.textLabel.text = "Fetch Error"
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 3.0)
    }
}


extension FavoritesViewController:ThemeChangeDelegate {
    func setupTheme() {
        self.view.theme.backgroundColor = themeService.attribute {$0.backgroundColor}
        self.movieCollectionView.theme.backgroundColor = themeService.attribute {$0.backgroundColor}
        self.titleLabel.theme.textColor = themeService.attribute{$0.textColor}
        self.backButton.theme.tintColor = themeService.attribute{$0.backButtonColor}
    }
}

