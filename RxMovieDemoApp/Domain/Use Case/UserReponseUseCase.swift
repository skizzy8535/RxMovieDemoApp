//
//  UserResponseUseCase.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/4/7.
//

import Foundation

protocol UserResponseUseCaseProtocol {
    static func startSaveInfo()
    static func cancelSaveInfo()
    static func retrieveSaveInfo()  -> Bool
    
    static func saveUserAccount(account:String)
    static func removeUserAccount()
    static func readUserAccount() -> String?
    
    static func saveUserToken (token:String)
    static func getUserToken() -> String?
    static func deleteUserToken()
    
    
    static func saveUserPassword (password:String)
    static func getUserPassword() -> String?
    static func deleteUserPassword()
}

class UserResponseUseCase: UserResponseUseCaseProtocol {
    
    
    static func startSaveInfo() {
        UserDefaults.standard.set(true, forKey: "IfSaveInfo")
    }
    
    static func cancelSaveInfo() {
        UserDefaults.standard.set(false, forKey: "IfSaveInfo")
    }
    
    static func retrieveSaveInfo()  -> Bool {
        return UserDefaults.standard.bool(forKey: "IfSaveInfo")
    }
    
    
// MARK:  User Account
    static func saveUserAccount(account: String) {
        UserDefaults.standard.set(account, forKey: "userAccount")
    }
    static func removeUserAccount() {
        UserDefaults.standard.removeObject(forKey: "userAccount")
    }
    static func readUserAccount() -> String? {
       return UserDefaults.standard.string(forKey:"userAccount")
    }
    
    
// MARK:  User Token
    static func saveUserToken (token:String) {
        
        guard let data = token.data(using: .utf8) else {
                 print("Failed to convert token to data")
                 return
             }
        
        
        let query: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrAccount as String: "MovieUserToken",
                    kSecValueData as String: data
                ]
        
        let status = SecItemAdd(query as CFDictionary, nil)

        
        guard status == errSecSuccess else {
            print("Failed to save token to Keychain")
            return
        }
        
        print("Token saved to Keychain")
        
    }
    static func getUserToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "MovieUserToken",
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess, let tokenData = item as? Data else {
            print("Failed to retrieve token from Keychain: \(status)")
            return nil
        }

        return String(data: tokenData, encoding: .utf8)
    }
    static func deleteUserToken() {
        
        let query: [String: Any] = [
              kSecClass as String: kSecClassGenericPassword,
              kSecAttrAccount as String: "MovieUserToken"
          ]
        
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            print("Failed to delete token from Keychain")
            return
        }
        print("Token deleted from Keychain")
        
        
    }
    
    
// MARK:  User Password
    static func saveUserPassword(password: String) {
        
        
        guard let data = password.data(using: .utf8) else {
            print("Failed to convert password to data")
            return
        }
        
        let passwordQuery :[String:Any] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrAccount as String: "MovieUserpassword",
            kSecValueData as String : data
        ]
        
        let status = SecItemAdd(passwordQuery as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            print("Failed to save password to Keychain")
            return
        }
        
        print("Password saved to Keychain")
    }
    
    static func getUserPassword() -> String? {
        let passwordQuery :[String:Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "MovieUserpassword",
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(passwordQuery as CFDictionary, &item)

        guard status == errSecSuccess, let passwordData = item as? Data else {
            print("Failed to retrieve password from Keychain: \(status)")
            return nil
        }

        return String(data: passwordData, encoding: .utf8)
        
    }
    
    static func deleteUserPassword() {
        let passwordQuery :[String:Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "MovieUserpassword"
        ]
        
        let status = SecItemDelete(passwordQuery as CFDictionary)
        
        guard status == errSecSuccess else {
            print("Failed to delete password from Keychain")
            return
        }
        print("Password deleted from Keychain")
    }
}
