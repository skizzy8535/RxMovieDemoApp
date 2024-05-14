//
//  SetItemWithImgCell.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/2/1.
//

import UIKit
import SnapKit

class SetItemWithImgCell: UITableViewCell {

    private var itemImage = UIImageView()

    private var itemTitle: UILabel = {
        let label = UILabel()
        label.textColor = .white
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func setSettingItems(itemName:String,imgName:String){
        itemTitle.text = itemName
        itemImage.image = UIImage(named: "\(imgName)")
    }


    private func setLayout() {

        contentView.addSubview(itemImage)
        contentView.addSubview(itemTitle)

        itemImage.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.height.equalTo(25)
            make.width.equalTo(20)
        }

        itemTitle.snp.makeConstraints { make in
            make.left.equalTo(itemImage).offset(20)
            make.top.bottom.equalToSuperview().inset(5)
            make.right.equalToSuperview().offset(-10)
        }

    }
}
