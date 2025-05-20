//  ImagesListService.swift

/* Внутренние состояние: управление загрузкой, управление массивом photos
 1)  Управление загрузкой включает:
 -  Какую страницу загружать?
 - Идет ли сейчас загрузка или нужно создать новый сетевой запрос?
 2)  Управление массивом photos:
 - Из какого потока обновлять массив?(можно ли из фонового или это должен быть main?)
 - Каким образом его обновлять, когда получен ответ от очередного сетевого запроса?
 */

import Foundation

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String // нужно добавить ключ created_at
    let description: String?
    let urls: UrlsVariation
    let liked: Bool // нужно добавить ключ liked_by_user
    
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

struct Photo: Decodable {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

class ImagesListService {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = [] // Массив с новыми фото объектами
    var lastLoadedPage: Int? // Крайний номер загруженной страницы
    var state: URLSessionTask? // Актулальное состояние
    let queueForRace = DispatchQueue(label: "serial")
    
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
            if let currentTask = self.state {
                currentTask.cancel()
                self.state = nil
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
                    
                case .failure(let error):
                    print("[fetchPhotosNextPage]: ошибка при получении модели")
                    return
                }
            }
            self.state = task // задаем состояние текущее, ссылка ведет на текущий экземпляр так как это референс тайп
            task.resume() // запускаем запрос
        }
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
    
    private func dateFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: dateString)
    }
}
