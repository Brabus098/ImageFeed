//  Untitled.swift
import Foundation
import SwiftKeychainWrapper

final class KeychainStorage{
    
    private enum KeyForKeychain: String {
        case authToken
    }
    var token: String? {
        get { let token: String? = KeychainWrapper.standard.string(forKey: KeyForKeychain.authToken.rawValue)
            return token}
        set (newToken){
            guard let newToken else{
                print("[KeychainStorage]: новый токен не подходит")
                return }
            let isSuccess = KeychainWrapper.standard.set(newToken, forKey: KeyForKeychain.authToken.rawValue)
            guard isSuccess else {
                print("[KeychainStorage]: ошибка при добавления \(newToken) в KeychainStorage")
                return
            }
        }
    }
    var tokenDelete: Bool?{
        get {KeychainWrapper.standard.removeObject(forKey: KeyForKeychain.authToken.rawValue)}
    }
}
