//
//  MovieDetailsViewController.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/2/24.
//

import SnapKit
import UIKit
import RxSwift
import RxCocoa
import RxRelay
import Kingfisher
import YoutubePlayerView

enum PopType {
    case withNavPresent
    case withoutNavPresent
}
class MovieDetailsViewController: UIViewController {

    private let detailViewModel: MovieDetailViewModel
    private let addCollectionViewModel = FavoritesViewModel()
    private var contentID :Int = 0
    private let disposeBag = DisposeBag()
    private var popType :PopType = .withNavPresent
    private var posterStr = ""
    private var status = false
    lazy var detailScrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.bounces = false
        return scrollView
    }()

    let contentView = UIView()

    private lazy var backButton :UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.tintColor = .white
        return button
    }()

    lazy var backdropImage:UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.isUserInteractionEnabled = true
        imgView.backgroundColor = UIColor.init(hex: "EEEEEE")
        return imgView
    }()

    lazy var titleLabel :UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    lazy var sublineLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .lightGray
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return label
    }()

    lazy var runtimeView:IconLabelView = {
        let view = IconLabelView()
        view.icon.image = UIImage(systemName: "clock")
        return view
    }()

    lazy var ratingView:IconLabelView = {
        let view = IconLabelView()
        view.icon.tintColor = .orange
        view.icon.image = UIImage(systemName: "star.fill")
        return view
    }()

    lazy var combineRateView:UIStackView = {
        let stackView = UIStackView()
        stackView.addArrangedSubview(runtimeView)
        stackView.addArrangedSubview(ratingView)
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.spacing = 5
        return stackView
    }()

    lazy var mainInfoStackView : UIStackView = {
        let stackview = UIStackView()
        stackview.addArrangedSubview(titleLabel)
        stackview.addArrangedSubview(sublineLabel)
        stackview.addArrangedSubview(combineRateView)
        stackview.axis = .vertical
        stackview.distribution = .fill
        stackview.alignment = .leading
        stackview.spacing = 5
        stackview.isLayoutMarginsRelativeArrangement = true
        stackview.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        return stackview
    }()


    lazy var favsButton =  AddFavoriteButton()

    lazy var descriptionView : MovieDescriptionView = {
        let overallView = MovieDescriptionView()
        overallView.titleLabel.text = "Overview"
        return overallView
    }()

    lazy var doubleColumnView : DoubleColumnDescriptionView = {
        let columnView = DoubleColumnDescriptionView()
        columnView.leftDescription.titleLabel.text = "Release Date"
        columnView.rightDescription.titleLabel.text = "Genre"
        return columnView
    }()

    lazy var segmentView:CustomSegent = {
        let seg = CustomSegent(frame: .zero, segmentTitles: ["Trailers","Images","Similar"])
        seg.setSegmentStyleColor(color: AppConstant.COMMON_SUB_COLOR)
        seg.delegate = self
        return seg
    }()

    let blankView = UIView()

    private lazy var trailerView:MovieTrailerView = {
        let view = MovieTrailerView(id:contentID)
        view.delegate = self
        return view
    }()

    private lazy var posterView :MoviePosterView = {
        let view = MoviePosterView(id:contentID)
        return view
    }()

    private lazy var similarView : MovieSimilarView = {
        let view = MovieSimilarView(id: contentID)
        return view
    }()

    init (id: Int,popType:PopType) {
        self.detailViewModel = MovieDetailViewModel(contentId: id)
        self.contentID = id
        self.popType = popType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        setData()
        setBind()
    }

    private func setLayout() {
        self.view.backgroundColor = AppConstant.COMMON_MAIN_COLOR
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        self.view.addSubview(detailScrollView)
        detailScrollView.addSubview(contentView)

        detailScrollView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        contentView.addSubview(backdropImage)
        backdropImage.addSubview(backButton)
        contentView.addSubview(mainInfoStackView)
        contentView.addSubview(favsButton)
        contentView.addSubview(descriptionView)
        contentView.addSubview(doubleColumnView)
        contentView.addSubview(segmentView)

        contentView.addSubview(trailerView)
        contentView.addSubview(posterView)
        contentView.addSubview(similarView)

        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(45)
            make.left.equalToSuperview().offset(10)
            make.width.height.equalTo(30)
        }

        backdropImage.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(backdropImage.snp.width).multipliedBy(0.7)
        }

        mainInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(backdropImage.snp.bottom)
            make.left.equalToSuperview()
            make.width.equalTo(self.view.snp.width).multipliedBy(0.9)
            make.height.greaterThanOrEqualTo(self.view.snp.width).multipliedBy(0.2)
        }

        favsButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.descriptionView.snp.top).offset(-10)
            make.right.equalToSuperview().offset(-10)
            make.left.equalTo(mainInfoStackView.snp.right).offset(10)
            make.height.equalTo(favsButton.snp.width)
        }

        descriptionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(mainInfoStackView.snp.bottom)
        }

        doubleColumnView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(descriptionView.snp.bottom)
        }

        segmentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(doubleColumnView.snp.bottom)
            make.height.equalTo(45)
        }

        doAlignSegment(view: trailerView)
        doAlignSegment(view: posterView)
        doAlignSegment(view: similarView)
    }

    private func setData() {
        detailViewModel.movieDetailData
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { model in
                if let model = model {
                    self.applyDetailData(data: model)
                }
            })
            .disposed(by: self.disposeBag)

        addCollectionViewModel.handleSingleMovieStatus(id: self.contentID)
        addCollectionViewModel.ifUniqleFavs.observe(on: MainScheduler.instance).subscribe(onNext:{ isEnable in
            self.favsButton.setStatus(status: isEnable)
            self.status = isEnable
        }) .disposed(by: self.disposeBag)
    }


    private func setBind() {
        favsButton.rx
            .tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance) // Throttle here
            .subscribe { _ in
            self.addCollectionViewModel.handleSingleMovieStatus(id: self.contentID)

            self.status = !self.status

            if (self.status) {

                guard let userInfo = FetchUserUseCase.readFile() else {
                    print("Can't get User name")
                    return
                }

                let postModel = PostFavoriteRecordModel(fields:
                                                            FavoriteItems(userName: userInfo.login ?? "YuChen Lin",
                                                                          movieID: self.contentID,
                                                                          movieName: self.titleLabel.text!, posterURL: self.posterStr))
                self.favsButton.setAddFavorite(favorites: postModel)
            } else {

                if (self.addCollectionViewModel.uniqID.value != "") {
                    let readyDeleteItem =  FavoriteDeleted(id:self.addCollectionViewModel.uniqID.value,deleted: true)
                    print(readyDeleteItem)
                    self.favsButton.deleteAddFavorite(item: readyDeleteItem)

                }
            }
        }.disposed(by: self.disposeBag)
    }




    private func applyDetailData (data:MovieDetail) {

        if let backdropPath = data.backdrop_path {
            posterStr = MovieUseCase.configureUrlString(imagePath: backdropPath)!
            let imageSource = KF.ImageResource(downloadURL: URL(string: MovieUseCase.configureUrlString(imagePath: backdropPath)!)!)
            self.backdropImage.kf.setImage(with: imageSource)
        } else if let posterPath = data.poster_path  {
            let imageSource = KF.ImageResource(downloadURL: URL(string: MovieUseCase.configureUrlString(imagePath: posterPath)!)!)
            self.backdropImage.kf.setImage(with: imageSource)
            backdropImage.clipsToBounds = true
        } else {
            backdropImage.contentMode = .scaleAspectFit
            backdropImage.clipsToBounds = true
            self.backdropImage.image = UIImage(named: "noImageYet")
        }

        if let runtime = data.runtime {
            self.runtimeView.itemLabel.text = "\(runtime) min"
        } else {
            self.runtimeView.isHidden = true
        }

        if let voteAverage = data.vote_average {
            self.ratingView.itemLabel.text = String(voteAverage)
        } else {
            self.ratingView.isHidden = true
        }

        self.titleLabel.text = data.title
        self.sublineLabel.text = data.tagline
        self.descriptionView.contentLabel.text = data.overview

        self.doubleColumnView.leftDescription.contentLabel.text = data.release_date?.replacingOccurrences(of: "-", with: ".")

        let genres = data.genres?.compactMap { $0.name }.joined(separator: ", ")
        self.doubleColumnView.rightDescription.contentLabel.text = genres

    }

    @objc private func backButtonAction() {
        if (self.popType == .withNavPresent) {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true,completion: nil)

        }
    }

    private func doAlignSegment(view:UIView) {
        view.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(segmentView.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
            make.height.equalTo(350)
        }

        posterView.isHidden = true
        similarView.isHidden = true
    }
}

extension MovieDetailsViewController: CustomSegmentDelegate {
    func change(to index: Int) {
        trailerView.isHidden = index == 0 ? false : true
        posterView.isHidden = index == 1 ? false : true
        similarView.isHidden = index == 2 ? false : true
    }
}

extension MovieDetailsViewController:ClickTrailerDelegate {

    func clickTrailer(key: String) {

        blankView.backgroundColor = .black.withAlphaComponent(0.75)

        let playerView = YoutubePlayerView()
        let closeButton = UIButton()
        closeButton.tintColor = .white
        closeButton.setBackgroundImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeBlankView), for: .touchUpInside)

        view.addSubview(blankView)
        blankView.addSubview(playerView)
        blankView.addSubview(closeButton)

        blankView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        playerView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(blankView.snp.width).multipliedBy(0.9)
        }

        closeButton.snp.makeConstraints { make in
            make.top.equalTo(playerView.snp.top).offset(-35)
            make.trailing.equalToSuperview()
            make.width.height.equalTo(30)
        }

        playerView.loadWithVideoId(key)

    }

    @objc private func closeBlankView() {
        view.subviews.forEach { subview in
            if subview == blankView {
                subview.removeFromSuperview()
            }
        }
    }

}

extension MovieDetailsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
