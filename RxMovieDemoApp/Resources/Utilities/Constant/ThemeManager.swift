//
//  ThemeManager.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/19.
//
import RxSwift
import RxTheme

typealias Atttibutes = [NSAttributedString.Key:Any]

protocol ThemeManager {
    var backgroundColor:UIColor {get}
    var textColor:UIColor {get}
    var tabBarSelectColor:UIColor {get}
    var tabBarNormalColor:UIColor {get}
    var segmentSelectColor:UIColor {get}
    var segmentNormalColor:UIColor {get}
    var 
    var backButtonColor:UIColor {get}
}



//struct LightTheme :ThemeManager {
//    var backgroundColor: UIColor = .white
//    var textColor: UIColor = .black
//    var tabBarColor: UIColor = .red
//    var segmentSColor: UIColor = .red
//    var backButtonColor: UIColor = .black
//}
//
//
//
//struct DarkTheme :ThemeManager {
//    var backgroundColor: UIColor = AppConstant.COMMON_MAIN_COLOR
//    var textColor: UIColor = .white
//    var tabBarColor: UIColor = AppConstant.COMMON_SUB_COLOR
//    var segmentColor: UIColor = .
//    var backButtonColor: UIColor
//}
