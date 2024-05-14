//
//  InstructionViewController.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/3/28.
//

import UIKit

class InstructionViewController: UIViewController {


    private let stackView = UIStackView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subTitleLabel = UILabel()

    init(imageName:String,titleText:String,subTitleText:String) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = UIImage(named: imageName)
        titleLabel.text = titleText
        subTitleLabel.text = subTitleText
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setInstructionStyle()
        setLayout()
    }

    func setInstructionStyle() {
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 20

        imageView.contentMode = .scaleAspectFit

        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)

        subTitleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        subTitleLabel.textAlignment = .center
        subTitleLabel.numberOfLines = 0
    }

    func setLayout() {
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subTitleLabel)

        view.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        imageView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(view.snp.width).multipliedBy(0.5)
        }

        subTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.view.snp.left).offset(16)
            make.right.equalTo(self.view.snp.right).offset(-16)
        }
    }




}
