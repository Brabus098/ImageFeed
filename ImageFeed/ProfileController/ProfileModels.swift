//  ProfileModels.swift

import UIKit

// Модель для декодирования данных пользователя
struct ProfileResult: Codable {
    let userName: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case userName = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio = "bio"
    }
}
// Итоговая модель для вывода на экран
struct Profile {
    let userName: String
    let name: String
    let loginName: String
    let bio: String
}
// Модель получает ссылку на фото
struct UserResult: Codable {
    let image: ProfileImage
    
    private enum CodingKeys: String, CodingKey {
        case image = "profile_image"
    }
}
// Модель получает фото
struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
}
