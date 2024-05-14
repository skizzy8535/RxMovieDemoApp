//
//  LoginViewController.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/19.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay
import JGProgressHUD


class LoginViewController: UIViewController {

    private var passwordShowStatus:Bool = false
    private var initSaveStatus:Bool = false
    private let disposeBag = DisposeBag()
    private var loginViewModel = LoginViewModel()


    private let hud : JGProgressHUD = {
        let hud = JGProgressHUD()
        return hud
    }()


    private let logoImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "AppIcon")
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        return imageView
    }()


    private let loginTitle :UILabel = {
        let label = UILabel()
        label.text = "Login to Your Account"
        label.font = .systemFont(ofSize: 25,weight: .bold)
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()

    private var showBtn : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        return button
    }()

    private lazy var remeberBtn: UIButton = {
        let button = UIButton()
        button.tintColor = AppConstant.DARK_SUB_COLOR
        button.setImage(UIImage(systemName: "square")?.withRenderingMode(.alwaysTemplate), for: .normal)
        return button
    }()


    private let remeberLabel :UILabel = {
        let label = UILabel()
        label.text = " Remeber Me"
        label.textColor = UIColor.white
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    private lazy var userNameBgView = makeTextFieldBg(name:"Person")
    private var userNameTextField:UITextField!
    private lazy var passwordBgView = makeTextFieldBg(name:"Password")
    private var passwordTextField:UITextField!
    private lazy var loginButton = makeButton(withText:"Login")
    private lazy var registerButton = makeButton(withText:"Register")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppConstant.DARK_MAIN_COLOR
        loginViewModel.delegate = self
        setLayout()
        setBinding()
    }


    private func setBinding() {
        loginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                guard let userName = self.userNameTextField.text else {
                    return print("userName is invalid")
                }

                guard let password = self.passwordTextField.text else {
                    return print("password is invalid")
                }

                loginViewModel.doUserLogin(userName: userName, password: password, status: .login)

            })
            .disposed(by: disposeBag)

        showBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.passwordShowStatus = !self.passwordShowStatus
                self.showBtn.setImage(self.passwordShowStatus ? UIImage(systemName: "eye.fill") :UIImage(systemName: "eye.slash.fill") , for: .normal)
                self.passwordTextField.isSecureTextEntry = self.passwordShowStatus
            })
            .disposed(by: disposeBag)

        remeberBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.initSaveStatus = !self.initSaveStatus

                
                guard let userName = self.userNameTextField.text else {
                    return print("userName is invalid")
                }

                guard let password = self.passwordTextField.text else {
                    return print("password is invalid")
                }
                
                if (self.initSaveStatus) {
                    UserResponseUseCase.startSaveInfo()
                    UserResponseUseCase.saveUserAccount(account: userName)
                    UserResponseUseCase.saveUserPassword(password: password)
                    self.remeberBtn.setImage(UIImage(systemName: "checkmark.square.fill") , for: .normal)
                    
                } else {
                    UserResponseUseCase.cancelSaveInfo()
                    UserResponseUseCase.removeUserAccount()
                    UserResponseUseCase.deleteUserPassword()
                    self.remeberBtn.setImage(UIImage(systemName: "square") , for: .normal)
                }
            })
            .disposed(by: disposeBag)

        registerButton.rx.tap.subscribe(onNext: {[weak self] in
            let vc  = RegisterViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            self?.present(vc, animated: true)

        }).disposed(by: self.disposeBag)

        loginViewModel.doRetrieveInfo()
    }


    private func setLayout() {
        userNameTextField = makeTextField(withText: "User Name")
        passwordTextField = makeTextField(withText: "Password")

        view.addSubview(logoImageView)
        view.addSubview(loginTitle)
        view.addSubview(userNameBgView)
        view.addSubview(passwordBgView)
        view.addSubview(remeberLabel)
        view.addSubview(remeberBtn)
        view.addSubview(loginButton)
        view.addSubview(registerButton)

        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(30)
            make.width.height.equalTo(140)
        }

        loginTitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoImageView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }

        userNameBgView.snp.makeConstraints { make in
            make.top.equalTo(loginTitle.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(44)
        }

        userNameBgView.addSubview(userNameTextField)

        userNameTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(33)
            make.top.bottom.equalToSuperview().inset(1)
            make.right.equalToSuperview().inset(10)
        }

        passwordBgView.snp.makeConstraints { make in
            make.top.equalTo(userNameBgView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(44)
        }

        passwordBgView.addSubview(passwordTextField)

        passwordTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(33)
            make.top.bottom.equalToSuperview().inset(1)
            make.right.equalToSuperview().offset(-30)
        }

        remeberLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordBgView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(90)
            make.height.equalTo(25)
        }

        remeberBtn.snp.makeConstraints { make in
            make.top.equalTo(passwordBgView.snp.bottom).offset(10)
            make.right.equalTo(remeberLabel.snp.left)
            make.width.height.equalTo(25)
        }

        loginButton.snp.makeConstraints { make in
            make.top.equalTo(remeberLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(25)
            make.height.equalTo(44)
        }


        registerButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.snp.bottom).offset(-70)
            make.left.right.equalToSuperview().inset(25)
            make.height.equalTo(44)
        }

    }

    private func makeTextFieldBg(name:String) -> UIView {
        let textFieldBg = UIView()
        textFieldBg.isUserInteractionEnabled = true
        textFieldBg.backgroundColor = .systemGray4
        textFieldBg.layer.cornerRadius = 8

        let imageView = UIImageView()
        imageView.image = UIImage(named: name)
        imageView.tintColor = .darkGray

        showBtn.tintColor = .darkGray

        textFieldBg.addSubview(imageView)
        textFieldBg.addSubview(showBtn)

        imageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(5)
            make.top.bottom.equalToSuperview().inset(12)
            make.width.equalTo(20)
        }

        showBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-5)
            make.top.bottom.equalToSuperview().inset(12)
            make.width.equalTo(25)
        }

        showBtn.isHidden = name == "Password" ? false : true
        return textFieldBg
    }

    private func makeTextField(withText name: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = name
        textField.backgroundColor = .clear
        if (name == "Password") {
            textField.isSecureTextEntry = true
        }
        return textField
    }

    private func makeButton(withText:String) -> UIButton {
        let button = UIButton()
        button.setTitle(withText, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.backgroundColor = AppConstant.DARK_SUB_COLOR
        button.layer.cornerRadius = 8
        return button
    }

}


extension LoginViewController:LoginLoadDelegate{

    func doRetrieveSaveAccountInfo() {
        
        if UserResponseUseCase.retrieveSaveInfo() {
            userNameTextField.text = UserResponseUseCase.readUserAccount()            
            passwordTextField.text = UserResponseUseCase.getUserPassword()
            self.remeberBtn.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        }
    }

    func didChange(isLoading: Bool) {
        if isLoading {
            showSuccessMessage()
        } else {
            showErrorMessage()
        }
    }


    func showSuccessMessage() {
        DispatchQueue.main.async {
            let hud = JGProgressHUD()
            hud.indicatorView = JGProgressHUDIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0, animated: true)
        }
    }

    func showErrorMessage(){
        DispatchQueue.main.async {
            let hud = JGProgressHUD()
            hud.textLabel.text = "Login Error"
            hud.detailTextLabel.text = "Either Username or password are incorrect"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0, animated: true)
        }
    }


    func doVerifyAccountAction() {
        DispatchQueue.main.async {
            let mainVC = MainTabBarController()
            mainVC.modalPresentationStyle = .fullScreen
            mainVC.modalTransitionStyle = .crossDissolve
            self.present(mainVC, animated: true)
        }
    }


}
