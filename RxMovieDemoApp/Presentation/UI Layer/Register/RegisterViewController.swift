//
//  RegisterViewController.swift
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


class RegisterViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private var registerViewModel = RegisterViewModel()

   private lazy var backButton :UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.tintColor = AppConstant.DARK_SUB_COLOR
        return button
    }()

    private let hud : JGProgressHUD = {
        let hud = JGProgressHUD()
        return hud
    }()

    private let registerTitle :UILabel = {
        let label = UILabel()
        label.text = "Register Your Account"
        label.font = .systemFont(ofSize: 25,weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private lazy var regiEmailBgView = makeTextFieldBg(imageName: "Email")
    private var regiNameTextField:UITextField!


    private lazy var registerNameBgView = makeTextFieldBg(imageName: "Person")
    private var regiEmailTextField:UITextField!

    private lazy var regiPasswordBgView = makeTextFieldBg(imageName: "Password")
    private var regiPassTextField:UITextField!

    private lazy var registerButton = makeButton(withText:"Register")


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppConstant.DARK_MAIN_COLOR
        setBinding()
        registerViewModel.delegate = self
        setLayout()
    }

    private func setBinding() {
        registerButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                guard let userName = self.regiNameTextField.text else {
                    return print("email is invalid")
                }


                guard let email = self.regiEmailTextField.text else {
                    return print("email is invalid")
                }

                guard let password = self.regiPassTextField.text else {
                    return print("password is invalid")
                }

                registerViewModel.doUserRegister(user: userName, password: password, status: .register)

            })
            .disposed(by: disposeBag)

        backButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.dismiss(animated: true,completion: nil)
        }).disposed(by: self.disposeBag)
    }


    private func setLayout() {
        regiNameTextField = makeTextField(withText: "Register Name")
        regiEmailTextField = makeTextField(withText: "Register Email")
        regiPassTextField = makeTextField(withText: "Register Password")

        view.addSubview(backButton)
        view.addSubview(registerTitle)
        view.addSubview(registerNameBgView)
        view.addSubview(regiEmailBgView)
        view.addSubview(regiPasswordBgView)
        view.addSubview(registerButton)


        backButton.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(10)
            make.left.equalToSuperview().offset(10)
            make.width.height.equalTo(30)
        }

        registerTitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(50)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }

        registerNameBgView.snp.makeConstraints { make in
            make.top.equalTo(registerTitle.snp.bottom).offset(50)
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(44)
        }

        registerNameBgView.addSubview(regiNameTextField)

        regiNameTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(33)
            make.top.bottom.equalToSuperview().inset(1)
            make.right.equalToSuperview().inset(10)
        }

        regiEmailBgView.snp.makeConstraints { make in
            make.top.equalTo(registerNameBgView.snp.bottom).offset(25)
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(44)
        }

        regiEmailBgView.addSubview(regiEmailTextField)

        regiEmailTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(33)
            make.top.bottom.equalToSuperview().inset(1)
            make.right.equalToSuperview().inset(10)
        }

        regiPasswordBgView.snp.makeConstraints { make in
            make.top.equalTo(regiEmailBgView.snp.bottom).offset(25)
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(44)
        }

        regiPasswordBgView.addSubview(regiPassTextField)

        regiPassTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(33)
            make.top.bottom.equalToSuperview().inset(1)
            make.right.equalToSuperview().offset(-30)
        }

        registerButton.snp.makeConstraints { make in
            make.top.equalTo(regiPassTextField.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(25)
            make.height.equalTo(44)
        }

    }

    private func makeTextFieldBg(imageName:String) -> UIView {
        let textFieldBg = UIView()
        textFieldBg.isUserInteractionEnabled = true
        textFieldBg.backgroundColor = .systemGray4
        textFieldBg.layer.cornerRadius = 8

        let imageView = UIImageView()
        imageView.image = UIImage(named: imageName)
        imageView.tintColor = .darkGray

        textFieldBg.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(5)
            make.top.bottom.equalToSuperview().inset(12)
            make.width.equalTo(20)
        }
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

extension RegisterViewController:RegisterLoadDelegate{

    func doRegisterAccountAction() {
        DispatchQueue.main.async {
            let mainVC = MainTabBarController()
            mainVC.modalPresentationStyle = .fullScreen
            mainVC.modalTransitionStyle = .crossDissolve
            self.present(mainVC, animated: true)
        }
    }
    

    func didChange(isLoading: Bool) {
        if isLoading {
            hud.show(in: self.view)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.hud.dismiss()
            }
        }
    }
    

    func showErrorMessage() {
        DispatchQueue.main.async { [self] in
            hud.textLabel.text = "Register Error"
            hud.detailTextLabel.text = "Either Username or password format are incorrect"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.dismiss(afterDelay: 2.0,animated: true)
        }
    }

}

