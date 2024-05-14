
//
//  SettingsViewController.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/1/21.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import RxDataSources
import LocalAuthentication

 enum SectionItem {
     case titleCellInit(title: String, imageName: String)
     case titleCellWithSwitch(title: String, imageName: String)
 }

 struct SettingSection{
     var header:String
     var items:[SectionItem]
 }

 extension SettingSection:SectionModelType {
     typealias Items = SectionItem

     init(original: SettingSection, items: [Items]) {
         self = original
         self.items = items
     }
 }

class SettingsViewController: UIViewController,SetItemWithSwitchCellDelegate {

    let disposeBag = DisposeBag()

    private var iconView:UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.clipsToBounds = true
        view.layer.cornerRadius = 45
        return view
    }()

    private let nameLabel:UILabel = {
        let label = UILabel()
        label.text = "Demo Name"
        label.textColor = .white
        label.font = .systemFont(ofSize: 19,weight: .medium)
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()

    private let settingView :UITableView = {
        let tableView = UITableView()
        tableView.register(SetItemWithImgCell.self, forCellReuseIdentifier: "SetItemWithImgCell")
        tableView.register(SetItemWithSwitchCell.self, forCellReuseIdentifier: "SetItemWithSwitchCell")
        tableView.backgroundColor = AppConstant.COMMON_MAIN_COLOR
        tableView.separatorColor = .white
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return tableView
    }()

    private let viewModel = SettingViewModel()

    private var settingViewDataSoure:RxTableViewSectionedReloadDataSource<SettingSection>? = nil

    private var settingItems: Observable<[SettingSection]>? = nil

    private var saveSelectPath :[Int] = []

    private let saveSelectpathKey = "SelectPathKey"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppConstant.COMMON_MAIN_COLOR
        setLayout()
        readUserInfo()
        setItemSoure()
    }

    private func setLayout(){

        settingView.rx.setDelegate(self).disposed(by: self.disposeBag)

        self.view.addSubview(iconView)
        self.view.addSubview(nameLabel)
        self.view.addSubview(settingView)

        iconView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(90)
            make.height.equalTo(90)
        }

        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(iconView)
            make.left.equalTo(iconView.snp.right).offset(20)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(60)
        }

        settingView.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(30)
            make.left.right.bottom.equalToSuperview()
        }

    }

    private func readUserInfo () {
        if let userInfo = FetchUserUseCase.readFile() {
            self.nameLabel.text = userInfo.login!
        }
    }


    private func setItemSoure(){
        settingItems = viewModel.settingItems

        settingViewDataSoure = RxTableViewSectionedReloadDataSource(configureCell: { dataSource, tableView, indexPath, items in

            switch dataSource [indexPath]{
            case .titleCellInit(title: let title, imageName: let imageName):
                let settingImgcell = tableView.dequeueReusableCell(withIdentifier: "SetItemWithImgCell", for: indexPath) as! SetItemWithImgCell
                settingImgcell.backgroundColor = .clear
                settingImgcell.selectionStyle = .none
                settingImgcell.setSettingItems(itemName: title, imgName: imageName)
                return settingImgcell

            case .titleCellWithSwitch(title: let title, imageName: let imageName):
                let settingSwitchcell = tableView.dequeueReusableCell(withIdentifier: "SetItemWithSwitchCell", for: indexPath) as! SetItemWithSwitchCell
                settingSwitchcell.backgroundColor = .clear
                settingSwitchcell.delegate = self

                if let savedIndices = UserDefaults.standard.array(forKey: self.saveSelectpathKey) as? [Int] {
                    self.saveSelectPath = savedIndices
                }

                let isOn = self.saveSelectPath.contains(indexPath.row)
                settingSwitchcell.setSettingItems(itemName: title, isOn: isOn)

                settingSwitchcell.selectionStyle = .none
                return settingSwitchcell
            }
        })

        settingItems!.bind(to: settingView.rx.items(dataSource: settingViewDataSoure!)).disposed(by: self.disposeBag)

        settingView.rx.itemSelected.subscribe { [self] indexPath in

            switch indexPath.item {
            case 2 :
                let vc = FavoritesViewController()
                vc.modalPresentationStyle = .fullScreen
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true)
            case 5:
                print("Log Out")
            default:
                print("Do Nothing ?")
            }

        }
    }

    internal func toggleStatusDidChange(_ cell: SetItemWithSwitchCell, isOn: Bool) {
        guard let indexPath = settingView.indexPath(for: cell) else {
            return
        }

        switch indexPath.row {
          case 1 :
            
            if (isOn) {
                viewModel.enableAppLock()
            } else {
                viewModel.disableAppLock()
            }


          case 3 :
            if (isOn) {
                themeService.switch(.dark)
                selectedTheme = .dark
            }  else {
                themeService.switch(.light)
                selectedTheme = .light
            }



          default:
            print("No Action")
        }
        
        
        if (isOn) {
            appendNeedSavePath(index: indexPath.row)
        } else {
            removeSelectedPath(index: indexPath.row)
        }
        saveSelectedIndices()
        removeDuplicateIndices()
    }



    private func appendNeedSavePath (index:Int) {
        if !saveSelectPath.contains(index) {
            saveSelectPath.append(index)
        } else {
            print("Number \(index) has saved in the array")
        }
    }

    private func removeSelectedPath(index: Int) {
        if let index = saveSelectPath.firstIndex(of: index) {
            saveSelectPath.remove(at: index)
            print("Removed \(index)")
        } else {
            print("Number \(index) not found in the array")
        }
    }

    private func saveSelectedIndices() {
        UserDefaults.standard.set(saveSelectPath, forKey: saveSelectpathKey)
    }

    private func removeDuplicateIndices() {
        if let savedIndices = UserDefaults.standard.array(forKey: saveSelectpathKey) as? [Int] {
            let uniqueIndices = Set(savedIndices)
            let uniqueArray = Array(uniqueIndices)
            UserDefaults.standard.set(uniqueArray, forKey: saveSelectpathKey)
        }
    }

}


 extension SettingsViewController :UITableViewDelegate{

     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 50
     }

 }

