// OAuth2TokenStorage.swift

import Foundation

final class OAuth2TokenStorage {
    private let storage: UserDefaults = .standard
    private enum Keys: String {
        case token
    }
    
    var token: String? {
        get { storage.string(forKey: Keys.token.rawValue) }
        set (newToken){
            if let newToken = newToken{
                storage.set(newToken, forKey: Keys.token.rawValue)
            }
        }
    }
}
