//  ProfileImageService.swift

import Foundation

final class ProfileImageService {
    
    private(set) var avatarURL: String?
    private var storage = KeychainStorage()
    private var taskState: URLSessionTask?
    private let otherQueue = DispatchQueue(label: "serial")
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    static let shared = ProfileImageService()
    private init() {}
    
    // Get для получения фото
    private func getPhoto(token: String, userName:String) -> URLRequest?{
        
        guard let baseURL = URL(string: "https://api.unsplash.com") else {
            print("[getPhoto] Ошибка - \(NetworkError.createUrlError("неверный стартовый URL"))")
            return nil }
        guard let url = URL(string: "/users/" + userName,
                            relativeTo: baseURL)
        else { print("[getPhoto]: Ошибка - \(NetworkError.createUrlError("Не удалось собрать Get запрос"))")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(Constants.accessKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    func fetchProfileImageURL(userName: String, _ completion: @escaping (Result<String,Error>) -> Void){
        
        guard let token = storage.token else { return  print("[fetchProfileImageURL]: Ошибка - \(NetworkError.invalidToken), при добавление токена в getPhoto") }
        guard let getRequest = getPhoto(token: token, userName: userName) else { return print("[fetchProfileImageURL]: Ошибка - \(NetworkError.invalidUserName), в вызове getPhoto") }
        
        // Вывод результатов функции через замыкание на главный поток
        let pushCompletionForMainQueue: (Result<String,Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
                NotificationCenter.default.post(name: ProfileImageService.didChangeNotification,
                                                object: self,
                                                userInfo: ["URL": result ])
            }
        }
       
        // Создаем новую задачу
        let session = URLSession.shared
        let task = session.objectTask(for: getRequest) { [weak self] (result: Result<UserResult, Error>) in
            defer { self?.otherQueue.async { // обниляем состояние при любом варианте завершения
                self?.taskState = nil }
            }
            switch result {
            case .success(let profile):
                self?.avatarURL = profile.image.large
                pushCompletionForMainQueue(.success(profile.image.large))
            case .failure(let error):
                if let urlError = error as? URLError, urlError.code == .cancelled{
                    print("[fetchProfileImageURL]: Ошибка - \(NetworkError.raceConditionError), сделан повторный запрос")
                } else {
                    print("[fetchProfileImageURL]: Ошибка - \(NetworkError.createImageError) ,при сетевом запросе на этапе загрузки картинки")
                    pushCompletionForMainQueue(.failure(NetworkError.urlSessionError))
                }
            }
        }
        // Отмена старой задачи и запуск новой на одной очереди
        otherQueue.async {[weak self] in
            guard let self = self else { return }
            if let oldState = self.taskState {
                oldState.cancel() // отменяем старую задачу
                print("[fetchProfileImageURL]: Повторный вызов - отменяем предыдущую задачу")
            }
            self.taskState = task
            task.resume()
        }
    }
}
