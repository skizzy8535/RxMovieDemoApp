//
//  HomeMainViewController.swift
//  RxMovieDemoApp
//
//  Created by NeferUser on 2024/4/19.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import SnapKit
import Kingfisher
import JGProgressHUD
import RxTheme


enum HomeSection:String,CaseIterable{
    case nowPlayingSection = ""
    case popularSection = "Popular Movies"
    case upcomingSection = "Upcoming Series"
    case topRatedSection = "Top Rated"
}

class HomeMainViewController:UIViewController,MovieHomeLoadingDelegate {

    static let sectionHeaderElementKind = "sectionHeaderElementkind"
    private let disposeBag = DisposeBag()

    private var index = 0
    private var timer:Timer?
    private let homeViewModel = MovieHomeFetchViewModel()
    private let settingViewModel = SettingViewModel()
    private var movieDataSource :UICollectionViewDiffableDataSource<HomeSection,MovieHomeListData>! = nil

    private let hud : JGProgressHUD = {
        let hud = JGProgressHUD()
        hud.textLabel.text = "Loading ..."
        hud.detailTextLabel.text = "Please Wait"
        return hud
    }()


    private lazy var homeMovieCollectionView:UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout())
        collectionView.delegate = self
        collectionView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        collectionView.register(HomeMovieCell.self, forCellWithReuseIdentifier: "HomeMovieCell")
        collectionView.register(MovieTitleReuseView.self, forSupplementaryViewOfKind: HomeMainViewController.sectionHeaderElementKind, withReuseIdentifier: "MovieTitleReuseView")
        return collectionView
    }()



    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        homeViewModel.delegate = self
        if (settingViewModel.getAppLockState()) {
            settingViewModel.appLockValidation()
        }
        homeViewModel.fetchAll()
        setItemPlacement()
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(autoScrollBanner), userInfo: nil, repeats: true)
    }

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

    func presentHomeDisplayItems(nowPlayingMovies: [MovieHomeListData],
                                 popularMovies: [MovieHomeListData],
                                 upcomingMovies: [MovieHomeListData],
                                 topRatedMovies: [MovieHomeListData]) {

        DispatchQueue.main.async {  [weak self] in
            guard let self = self else { return }

            self.movieDataSource = UICollectionViewDiffableDataSource<HomeSection, MovieHomeListData>(collectionView: self.homeMovieCollectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
                let section = HomeSection.allCases[indexPath.section]

                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeMovieCell", for: indexPath) as? HomeMovieCell else { return UICollectionViewCell() }

                switch section {
                case .nowPlayingSection:
                    cell.title = item.title
                    cell.photoURLString =  MovieUseCase.configureUrlString(imagePath: item.backdrop_path)
                case .popularSection, .upcomingSection, .topRatedSection:
                    cell.title = ""
                    cell.photoURLString =  MovieUseCase.configureUrlString(imagePath: item.poster_path)
                }
                return cell
            })

            self.movieDataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
                let section = HomeSection.allCases[indexPath.section]

                guard let reuseView = collectionView.dequeueReusableSupplementaryView(ofKind: HomeMainViewController.sectionHeaderElementKind, withReuseIdentifier: "MovieTitleReuseView", for: indexPath) as? MovieTitleReuseView else { return nil }

                reuseView.title = section.rawValue
                reuseView.titleLabel.theme.textColor = themeService.attribute { $0.textColor }
                return reuseView
            }

            var movieSnapshot = NSDiffableDataSourceSnapshot<HomeSection, MovieHomeListData>()
            movieSnapshot.appendSections([.nowPlayingSection, .popularSection, .upcomingSection, .topRatedSection])
            movieSnapshot.appendItems(nowPlayingMovies, toSection: .nowPlayingSection)
            movieSnapshot.appendItems(popularMovies, toSection: .popularSection)
            movieSnapshot.appendItems(upcomingMovies, toSection: .upcomingSection)
            movieSnapshot.appendItems(topRatedMovies, toSection: .topRatedSection)
            self.movieDataSource.apply(movieSnapshot, animatingDifferences: false)

            setupTheme()
            self.homeMovieCollectionView.isHidden = false
        }

    }

    private func setItemPlacement(){
        self.view.addSubview(self.homeMovieCollectionView)
        self.homeMovieCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        homeMovieCollectionView.isHidden = true
    }

    @objc func autoScrollBanner(){
        guard let sectionIndex = HomeSection.allCases.firstIndex(of: .nowPlayingSection) else { return }
        let indexPath = IndexPath(item: index, section: sectionIndex)
        let count = numberOfItemsInSection(.nowPlayingSection)

        if index < count{
            homeMovieCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            index += 1
        }else if index == count{
            index = 0
            homeMovieCollectionView.scrollToItem(at: IndexPath(item: index, section: sectionIndex), at: .centeredHorizontally, animated: true)
        }
    }


    private func generateLayout()->UICollectionViewLayout{

        let layout = UICollectionViewCompositionalLayout { sectionIndex, enviroment -> NSCollectionLayoutSection? in
            let section = HomeSection.allCases[sectionIndex]
            switch section {
            case .nowPlayingSection:
                return self.getFullTypeSection()
            case .popularSection:
                return self.getLargeTypeSection()
            case .upcomingSection,.topRatedSection:
                return self.getNormalTypeSection()
            }
        }
        return layout
    }



    private func getFullTypeSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let items = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.65))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: items, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }


    private func getLargeTypeSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let items = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.53), heightDimension: .absolute(290))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: items, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let section = NSCollectionLayoutSection(group: group)

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(44))

        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: HomeMainViewController.sectionHeaderElementKind, alignment: .top)

        section.boundarySupplementaryItems = [sectionHeader]
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }

    private func getNormalTypeSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let items = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .absolute(190))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: items, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let section = NSCollectionLayoutSection(group: group)

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: HomeMainViewController.sectionHeaderElementKind, alignment: .top)

        section.boundarySupplementaryItems = [sectionHeader]
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }


}


extension HomeMainViewController:UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let item = movieDataSource.itemIdentifier(for: indexPath) ,
        let contentID = item.id else {return}

        let movieDetailsVC = MovieDetailsViewController(id: contentID,popType: .withNavPresent)
        self.navigationController?.pushViewController(movieDetailsVC, animated: true)
    }

    func numberOfItemsInSection(_ section: HomeSection) -> Int {
        guard let dataSource = movieDataSource else { return 0 }
        let snapshot = dataSource.snapshot()
        return snapshot.itemIdentifiers(inSection: section).count
    }

}

extension HomeMainViewController:ThemeChangeDelegate {
    func setupTheme() {
        self.view.theme.backgroundColor = themeService.attribute {$0.backgroundColor}
        self.homeMovieCollectionView.theme.backgroundColor = themeService.attribute {$0.backgroundColor}
    }
}
