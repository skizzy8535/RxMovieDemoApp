//
//  LoginViewController.swift
//  RxMovieDemoApp
//
//  Created by NeferUser on 2024/4/19.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

class LoginViewController: UIViewController {

    private var passwordShowStatus:Bool = false
    private var initSaveStatus:Bool = false
    private let disposeBag = DisposeBag()
    private var userModel :User?

    private let logoImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "AppIcon")
        imageView.contentMode = .scaleAspectFill
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
        button.tintColor = AppConstant.COMMON_SUB_COLOR
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

    private lazy var emailBgView = makeTextFieldBg(name:"Email")
    private var emailTextField:UITextField!
    private lazy var passwordBgView = makeTextFieldBg(name:"Password")
    private var passwordTextField:UITextField!
    private lazy var loginButton = makeButton(withText:"Login")
    private lazy var registerButton = makeButton(withText:"Register")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppConstant.COMMON_MAIN_COLOR
        setBinding()
        setLayout()
        doIfSaveAccount()
    }


    private func setBinding() {


        loginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                guard let email = self.emailTextField.text else {
                    return print("email is invalid")
                }

                guard let password = self.passwordTextField.text else {
                    return print("password is invalid")
                }


                let info  = UserDetail(login: email, password: password)
                self.userModel = User(user: info)

                 UserRepository().sendRequest(user: self.userModel!, status:.login ) { result in
                    switch result {
                    case .success(let item):
                        FetchUserUseCase.saveNewUserStatus(userResponse: item)
                        self.doHaveAccountAction()
                    case .failure(let error):
                        self.showAlert(message: error.localizedDescription)
                    }
                }

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
                UserDefaults.standard.setValue(self.initSaveStatus, forKey: "IfSaveInfo")

                let status =  UserDefaults.standard.bool(forKey: "IfSaveInfo")
                self.remeberBtn.setImage(
                    status ? UIImage(systemName: "checkmark.square.fill") :UIImage(systemName: "square") , for: .normal)
                if (status) {
                    if let emailTxt = self.emailTextField.text ,
                       let passwordTxt = self.passwordTextField.text,
                       emailTxt.count > 0,
                       passwordTxt.count > 0 {
                        UserDefaults.standard.setValue(emailTxt, forKey: "LoginAccount")
                        UserDefaults.standard.setValue(passwordTxt, forKey: "LoginPassword")
                    }
                } else {
                    UserDefaults.standard.removeObject(forKey: "LoginAccount")
                    UserDefaults.standard.removeObject(forKey: "LoginPassword")
                }
            })
            .disposed(by: disposeBag)

        registerButton.rx.tap.subscribe(onNext: {[weak self] in
            let vc  = RegisterViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            self?.present(vc, animated: true)

        }).disposed(by: self.disposeBag)
    }


    private func setLayout() {
        emailTextField = makeTextField(withText: "Email")
        passwordTextField = makeTextField(withText: "Password")

        view.addSubview(logoImageView)
        view.addSubview(loginTitle)
        view.addSubview(emailBgView)
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

        emailBgView.snp.makeConstraints { make in
            make.top.equalTo(loginTitle.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(44)
        }

        emailBgView.addSubview(emailTextField)

        emailTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(33)
            make.top.bottom.equalToSuperview().inset(1)
            make.right.equalToSuperview().inset(10)
        }

        passwordBgView.snp.makeConstraints { make in
            make.top.equalTo(emailBgView.snp.bottom).offset(10)
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
        button.backgroundColor = AppConstant.COMMON_SUB_COLOR
        button.layer.cornerRadius = 8
        return button
    }


    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func doHaveAccountAction() {
        DispatchQueue.main.async {
            let mainVC = MainTabBarController()
            mainVC.modalPresentationStyle = .fullScreen
            mainVC.modalTransitionStyle = .crossDissolve
            self.present(mainVC, animated: true)
        }
    }

    func doIfSaveAccount(){
        if UserDefaults.standard.bool(forKey: "IfSaveInfo"),
           let savedEmail = UserDefaults.standard.string(forKey: "LoginAccount"),
           let savedPassword = UserDefaults.standard.string(forKey: "LoginPassword") {
            emailTextField.text = savedEmail
            passwordTextField.text = savedPassword
            self.remeberBtn.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        }
    }
}
