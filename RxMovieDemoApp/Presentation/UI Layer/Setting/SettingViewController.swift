
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
import JGProgressHUD
import RxTheme

enum SectionItem {
    case titleCellInit(title: String)
    case titleCellWithSwitch(title: String)
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

class SettingsViewController: UIViewController {

    let disposeBag = DisposeBag()

    private let hud : JGProgressHUD = {
        let hud = JGProgressHUD()
        return hud
    }()

    private var iconView:UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "AppIcon")
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
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
        let tableView = UITableView(frame: .zero,style: .insetGrouped)
        tableView.register(SetItemWithImgCell.self, forCellReuseIdentifier: "SetItemWithImgCell")
        tableView.register(SetItemWithSwitchCell.self, forCellReuseIdentifier: "SetItemWithSwitchCell")
        tableView.separatorStyle = .none
        return tableView
    }()


      lazy var aboutView : MovieDescriptionView = {
        let overallView = MovieDescriptionView()
        overallView.titleLabel.text = "Tech Stack"
        overallView.titleLabel.theme.textColor  = themeService.attribute {$0.textColor}
        overallView.contentLabel.text = """
                                  - RxSwift / RxTheme / RxDataSource
                                  - MVVM
                                  - Snapkit / Alamofire / Kingfisher
                                  - Compositional Layout
                                  - Repository pattern
                                  - Quick/ Nimble
                                  """
        return overallView
    }()

    lazy var copyrightLabel:UILabel = {
        let label = UILabel()
        label.text = "MIT License | Copyright (c) 2024 YuChen Lin"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        label.theme.textColor  = themeService.attribute {$0.textColor}
        return label
    }()


    private let viewModel = SettingViewModel()

    private var settingViewDataSoure:RxTableViewSectionedReloadDataSource<SettingSection>? = nil

    private var settingItems: Observable<[SettingSection]>? = nil

    private var saveSelectPath :[Int] = []

    private let saveSelectpathKey = "SelectPathKey"

    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        viewModel.delegate = self
        readUserInfo()
        setItemSoure()
        setupTheme()
    }

    private func setLayout(){

        settingView.rx.setDelegate(self).disposed(by: self.disposeBag)

        self.view.addSubview(iconView)
        self.view.addSubview(nameLabel)
        self.view.addSubview(settingView)
        self.view.addSubview(aboutView)
        self.view.addSubview(copyrightLabel)

        iconView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(30)
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
            make.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.33)
        }

        copyrightLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(15)
            make.left.right.equalToSuperview()
        }

        aboutView.snp.makeConstraints { make in
            make.top.equalTo(settingView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(30)
            make.bottom.equalTo(copyrightLabel.snp.top).inset(30)
        }


    }

    private func readUserInfo () {
//        if let userInfo = UserResponseUseCase.readFile() {
//            self.nameLabel.text = userInfo.login!
//        }
        
        if let userAccount = UserResponseUseCase.readUserAccount() {
            self.nameLabel.text = userAccount
        }
        
    }


    private func setItemSoure(){
        settingItems = viewModel.settingItems

        settingViewDataSoure = RxTableViewSectionedReloadDataSource(configureCell: { dataSource, tableView, indexPath, items in

            switch dataSource [indexPath]{
            case .titleCellInit(title: let title):
                let settingImgcell = tableView.dequeueReusableCell(withIdentifier: "SetItemWithImgCell", for: indexPath) as! SetItemWithImgCell
                settingImgcell.theme.backgroundColor = themeService.attribute {$0.tableViewThemeColor}
                settingImgcell.selectionStyle = .none
                settingImgcell.itemTitle.theme.textColor = themeService.attribute { $0.textColor }
                settingImgcell.setSettingItems(itemName: title)
                return settingImgcell

            case .titleCellWithSwitch(title: let title):
                let settingSwitchcell = tableView.dequeueReusableCell(withIdentifier: "SetItemWithSwitchCell", for: indexPath) as! SetItemWithSwitchCell
                settingSwitchcell.theme.backgroundColor = themeService.attribute {$0.tableViewThemeColor}
                settingSwitchcell.delegate = self

                if let savedIndices = UserDefaults.standard.array(forKey: self.saveSelectpathKey) as? [Int] {
                    self.saveSelectPath = savedIndices
                }

                let isOn = self.saveSelectPath.contains(indexPath.row)
                settingSwitchcell.setSettingItems(itemName: title, isOn: isOn)
                settingSwitchcell.itemTitle.theme.textColor = themeService.attribute { $0.textColor }
                settingSwitchcell.selectionStyle = .none
                return settingSwitchcell
            }
        },titleForHeaderInSection: { ds, index in
            return ds.sectionModels[index].header
        })

        settingItems!.bind(to: settingView.rx.items(dataSource: settingViewDataSoure!)).disposed(by: self.disposeBag)

        settingView.rx.itemSelected.subscribe { [self] indexPath in

            switch indexPath.item {
            case 1 :
                let vc = FavoritesViewController()
                vc.modalPresentationStyle = .fullScreen
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true)
            case 3:
                viewModel.doUserLogOut()
            default:
                print("Do Nothing ?!")
            }

        }.disposed(by: self.disposeBag)
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

extension SettingsViewController:SetItemWithSwitchCellDelegate {
    func toggleStatusDidChange(_ cell: SetItemWithSwitchCell, isOn: Bool) {
        guard let indexPath = settingView.indexPath(for: cell) else {
            return
        }

        switch indexPath.row {
        case 0 :

            if (isOn) {
                viewModel.enableAppLock()
            } else {
                viewModel.disableAppLock()
            }

        case 2 :
            if (isOn) {
                themeService.switch(.light)
                selectedTheme = .light
            }  else {
                themeService.switch(.dark)
                selectedTheme = .dark
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
}

extension SettingsViewController:SettingViewDelegate {
    func doLogOutAlert() {
        let alertController = UIAlertController(title: "Logout Confirmation" , message: "This action will log you out of your account. Continue?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Confirm", style: .default, handler: { [self] _ in
            let vc = LoginViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.present(vc, animated: true) {
                    self.dismiss(animated: true, completion: nil)
                    self.removeFromParent()
                }
            }
        })
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }

    }

    func didChange(isLoading: Bool) {
        if isLoading {
            hud.show(in: self.view)
        } else {
            hud.dismiss()
        }
    }

    func showErrorMessage() {
        hud.textLabel.text = "Login Out Error"
        hud.detailTextLabel.text = "Server Error... Please Wait !"
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 3.0)
    }



}

extension SettingsViewController :UITableViewDelegate{

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int)
    -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        let titleLabel = UILabel()

        settingItems?.subscribe(onNext: { sections in
            for section in sections {
                let header = section.header
                titleLabel.text = header

            }
        }).disposed(by: disposeBag)

        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        titleLabel.theme.textColor  = themeService.attribute {$0.textColor}
        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-15)
        }
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

}


extension SettingsViewController:ThemeChangeDelegate {
    func setupTheme() {
        self.view.theme.backgroundColor = themeService.attribute {$0.backgroundColor}
        self.settingView.theme.backgroundColor = themeService.attribute {$0.backgroundColor}
        self.nameLabel.theme.textColor  = themeService.attribute {$0.textColor}
    }
}
