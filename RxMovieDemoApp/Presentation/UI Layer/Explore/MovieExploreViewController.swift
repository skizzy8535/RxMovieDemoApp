//
//  MovieExploreViewController.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/1/21.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import MJRefresh

protocol MovieExploreDelegate:AnyObject {
    var exploreText:Observable<String>?{get set}
    func setMovieExploreBar()
}

 class MovieExploreViewController: UIViewController {

     var page:Int = 1

     private let disposeBag = DisposeBag()
     private let exploreViewModel = MovieExploreViewModel()

     private let searchTextSubject = BehaviorSubject<String>(value: "")
     private lazy var movieExploreBar = MovieExploreSearchBar()

     private lazy var exploreResultView:UICollectionView = {
         let defaultSize = self.view.bounds.width / 2
         let layout = UICollectionViewFlowLayout()
         layout.minimumInteritemSpacing = 5
         layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
         layout.scrollDirection = .vertical
         layout.estimatedItemSize = .zero
         layout.itemSize = CGSize(width: defaultSize - 20, height: defaultSize + 40)
         let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
         collectionView.register(MovieExploreCell.self, forCellWithReuseIdentifier: "MovieExploreCell")
         return collectionView
     }()

     private var exploreText:Observable<String>{
         return searchTextSubject
             .map{$0}
             .filter{$0.count >= 3}
             .debounce(.milliseconds(1500), scheduler: MainScheduler.instance)
     }

     private let noItemView :UIView = {
         let view = UIView()
         return view
     }()

     private let footer = MJRefreshAutoNormalFooter()

     override func viewDidLoad() {
         super.viewDidLoad()
         self.exploreResultView.rx.setDelegate(self).disposed(by: disposeBag)
         setLayout()
         setMovieExploreBar()
         setMovieExploreResult()
         doMoreExplore()
         setupTheme()
     }

     override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         navigationController?.view.setNeedsLayout()
         navigationController?.view.layoutIfNeeded()
     }

    private func setLayout(){
         self.view.addSubview(movieExploreBar)
         self.view.addSubview(exploreResultView)
         self.view.addSubview(noItemView)


         movieExploreBar.snp.makeConstraints { make in
             make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
             make.left.equalToSuperview().inset(8)
             make.right.equalTo(view.snp.right).offset(-7)
             make.height.equalTo(90)
         }

         exploreResultView.snp.makeConstraints { make in
             make.top.equalTo(movieExploreBar.snp.bottom)
             make.left.right.bottom.equalToSuperview()
         }


        noItemView.snp.makeConstraints { make in
            make.top.equalTo(movieExploreBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }


     }


     private func setMovieExploreBar(){
         movieExploreBar.searchBarStyle = .minimal
         movieExploreBar.placeholder = "Explore"
         movieExploreBar.delegate = self
         movieExploreBar.backgroundColor = .clear
         movieExploreBar.barTintColor = .white
         movieExploreBar.tintColor = UIColor.white
         self.navigationItem.titleView = movieExploreBar
         let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
         tapGesture.cancelsTouchesInView = false
         self.view.addGestureRecognizer(tapGesture)
     }


     private func setMovieExploreResult(){

         exploreText.subscribe(onNext: { txt in
             self.page = 1
             self.exploreViewModel.startExplore(keyword: txt, page: self.page)
         }).disposed(by: disposeBag)

         exploreViewModel.exploreResult.bind(to: self.exploreResultView.rx.items) {
             (collectionView,row,element) -> UICollectionViewCell in

             let indexPath = IndexPath(row: row, section: 0)
             let imageURL = MovieUseCase.configureUrlString(imagePath: element.poster_path ?? "")

             let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieExploreCell", for: indexPath) as! MovieExploreCell

             cell.configCell(imgURL: imageURL ?? "", voteRate: element.vote_average)

             return cell

         }.disposed(by: disposeBag)


          self.exploreResultView.rx.itemSelected.subscribe(onNext: { indexPath in

              let exploreID = self.exploreViewModel.exploreResult.value[indexPath.row].id

              let vc = MovieDetailsViewController(id: exploreID, popType: .withoutNavPresent)
              vc.modalPresentationStyle = .fullScreen
              self.present(vc, animated: true)

          }).disposed(by: disposeBag)

     }


     private func doMoreExplore() {
         exploreResultView.mj_footer?.isHidden = self.exploreViewModel.exploreResult.value.count <= 0 ? true : false
         self.exploreResultView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(footerRefresh))
     }

     @objc func footerRefresh(){
         self.page += 1
         self.exploreResultView.mj_footer?.isHidden = false

         DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
             self.exploreViewModel.startExplore(keyword: self.movieExploreBar.text ?? "", page: self.page)
             self.exploreResultView.mj_footer?.endRefreshing()
         }
     }

     @objc private func dismissKeyboard() {
         self.view.endEditing(true)
     }

 }

 extension MovieExploreViewController:UICollectionViewDelegate{
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return exploreViewModel.exploreResult.value.count
     }
 }

 extension MovieExploreViewController :UISearchBarDelegate {
     func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

         if searchText.isEmpty {
              self.exploreViewModel.clearExplore()
              searchTextSubject.onNext("")
              noItemView.isHidden = false
          } else {
              searchTextSubject.onNext(searchText)
              noItemView.isHidden = true
          }
     }
 }


extension MovieExploreViewController:ThemeChangeDelegate {
    func setupTheme() {
        self.view.theme.backgroundColor = themeService.attribute {$0.backgroundColor}
        noItemView.theme.backgroundColor = themeService.attribute {$0.backgroundColor}
        self.exploreResultView.theme.backgroundColor = themeService.attribute {$0.backgroundColor}
    }
}
