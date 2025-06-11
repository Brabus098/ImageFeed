//  ImagesListModel.swift

import Foundation

// Модель для декодирования общей информации
struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let urls: UrlsVariation
    let liked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case description
        case urls
        case createdAt = "created_at"
        case liked = "liked_by_user"
    }
    struct UrlsVariation: Decodable {
        let thumb: String
        let full: String
    }
}
// Модель для декодирования данных о лайке
struct PhotoLike: Decodable {
    let photo: LikedPhoto
    
    struct LikedPhoto: Decodable{
        let isLiked: Bool
        
        enum CodingKeys: String, CodingKey {
            case isLiked = "liked_by_user"
        }
    }
}
// Модель для заполнение данных массива
struct Photo: Decodable {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
    
}
