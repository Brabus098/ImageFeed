//  ImageListServiceProtocol.swift

import Foundation

protocol ImageListServiceProtocol {
    func fetchPhotosNextPage() // Загружает следующую страницу с фото
    var photos: [Photo] { get } // Текущий массив фотографий
    
    func changeLike( // обновляет данные о лайке на сервере
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    )
    func photo(at index: Int) -> Photo // получение фото по индексу
}
