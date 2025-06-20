//  ProfileLogoutService.swift

import Foundation
import WebKit

final class ProfileLogoutService: LogoutServiceProtocol {
    
    static let shared = ProfileLogoutService()
    private init() {}
    
    private let imagesListService = ImagesListService()
    private let storage = KeychainStorage()
    
    func logout() {
        cleanCookies()
        storage.deleteToken()
        ProfileService.shared.cleanData()
        imagesListService.cleanPhotosArray()
        ProfileImageService.shared.cleanAvatarURL()
    }
    
    private func cleanCookies() {
        // Очищаем куки из хранилища
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            // Массив полученных записей удаляем из хранилища
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
