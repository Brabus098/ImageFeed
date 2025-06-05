//  ImagesListService.swift

import Foundation

final class ImagesListService {
    
    private(set) var photos: [Photo] = [] // Массив с новыми фото объектами
    var lastLoadedPage: Int? // Крайний номер загруженной страницы
    var state: URLSessionTask? // Актулальное состояние
    var storage = KeychainStorage()
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    let queueForRace = DispatchQueue(label: "serial")
    
    private func dateFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: dateString)
    }
    
    private func getPhotoRequest(page number: Int) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://api.unsplash.com/photos") else {
            print("[getPhotoRequest]: Ошибка в стартовом адресе")
            return nil}
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(number)),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let url = urlComponents.url else {
            print("[getPhotoRequest]: Ошибка в при формирование GET адреса")
            return nil
        }
        var request: URLRequest = URLRequest(url: url)
        request.setValue("Client-ID \(Constants.accessKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return request
    }
    
    // Метод получения новой страницы
    func fetchPhotosNextPage() {
        let nextPage = (self.lastLoadedPage ?? 0) + 1 // было так (lastLoadedPage?.number ?? 0) + 1
        let session = URLSession.shared
        
        let pushCompletionOnTheMainThread: ([Photo]) -> Void = {newPhotos in
            DispatchQueue.main.async {
                self.photos.append(contentsOf: newPhotos)
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification,
                                                object: self,
                                                userInfo: ["newImages": newPhotos])
                self.lastLoadedPage = nextPage // обновляем крайний номер страницы
            }}
        
        queueForRace.async { [weak self] in
            guard let self = self else { return }
            
            // отмена существующешего запроса
            guard self.state == nil else {
                    print("[fetchPhotosNextPage]: Запрос уже выполняется — повторный вызов проигнорирован")
                    return
                }
            // Начало нового запроса
            guard let newRequest = self.getPhotoRequest(page: nextPage) else { return }
            let task = session.objectTask(for: newRequest){(result: Result<[PhotoResult], Error>) in
                defer{
                    self.queueForRace.async {
                        self.state = nil // обнуляем состояние запроса
                    }
                }
                
                switch result {
                case .success(let data):
                    var photoArray = [Photo]()
                    data.forEach { photoResult in
                        photoArray.append(Photo(id: photoResult.id,
                                                size: CGSize(width: photoResult.width, height: photoResult.height),
                                                createdAt: self.dateFromString(photoResult.createdAt),
                                                welcomeDescription: photoResult.description,
                                                thumbImageURL: photoResult.urls.thumb,
                                                largeImageURL: photoResult.urls.full,
                                                isLiked: photoResult.liked))
                    }
                    pushCompletionOnTheMainThread(photoArray)
                case .failure(_):
                    print("[fetchPhotosNextPage]: ошибка при получении модели")
                    return
                }
            }
            self.state = task // задаем состояние текущее, ссылка ведет на текущий экземпляр так как это референс тайп
            task.resume() // запускаем запрос
        }
    }
}

extension ImagesListService {
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        
        let baseUrl = URL(string: "https://api.unsplash.com/photos/\(photoId)/like")
        guard let baseUrl else {
            print("[changeLike]: Ошибка базового запроса")
            return }
        var request = URLRequest(url: baseUrl)
        
        request.setValue("Bearer \(storage.token ?? "InavalidToken")", forHTTPHeaderField: "Authorization")
        request.httpMethod = isLike ? "DELETE" : "POST"
     
        var _ = URLSession.shared.objectTask(for: request) { (result: Result<PhotoLike, Error>) in
            switch result {
            case .success(let result):
                completion(.success(print("[changeLike] - запрос \(request.httpMethod) успешно принят")))
            case .failure(let error):
                print("[changeLike] : ошибка при получении ответа от сервера")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func cleanPhotosArray(){
        self.photos.removeAll()
    }
}
