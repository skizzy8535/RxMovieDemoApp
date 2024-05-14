//
//  MovieExploreFilterView.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/2/21.
//

import UIKit

class MovieExploreFilterView: UIView {

    private let filterViewLbl:UILabel  = {
        let label = UILabel()
        label.text = "Sort & Filter"
        label.textColor = AppConstant.COMMON_SUB_COLOR
        label.font = .systemFont(ofSize: 25, weight: .medium)
        return label
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
