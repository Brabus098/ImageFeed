//  ProfileService.swift

import UIKit

final class ProfileService {
    
    private var taskState: URLSessionTask?
    private let syncQueue = DispatchQueue(label: "serial")
    private(set) var profile: Profile?
    
    // Синглтон
    static let shared = ProfileService()
    private init() {}
    
    // Метод который создает GET запрос
    private func makeGetRequest(authToken: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://api.unsplash.com") else {
            print("[makeGetRequest]: Ошибка - \(String(describing: NetworkError.createUrlError)), ошибка стартового запроса")
            return nil }
        guard let url = URL(
            string: "/me",
            relativeTo: baseURL
        ) else {
            print("[makeGetRequest]: Ошибка - \(String(describing: NetworkError.createUrlError)), не удалось собрать Get запрос, не верный code - \(authToken)")
            return nil }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    // Метод обрабатывает полученные данные в модель и передает в ProfileViewController
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let getRequest = makeGetRequest(authToken: token) else {
            print("[fetchProfile]: Ошибка - \(String(describing: NetworkError.makeRequestError))при передаче токена \(token)в makeGetRequest")
            return
        }
        let pushCompletionOnTheMainThread: (Result<Profile, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        syncQueue.async { [weak self] in
            guard let self = self else { return }
            // Отменяем старую задачу
            if let oldTask = self.taskState {
                oldTask.cancel()
                print("[fetchProfile]: Ошибка - \(String(describing: NetworkError.raceConditionError)), отмена предыдущей задачи")
            }
            // Создаём новую
            let session = URLSession.shared
            let task = session.objectTask(for: getRequest) { [weak self] (result: Result<ProfileResult, Error>) in
                defer {
                    self?.syncQueue.async {
                        self?.taskState = nil
                    }
                }
                switch result {
                case .success(let profileResult):
                    if profileResult.userName.isEmpty {
                        print("[fetchProfile]: Ошибка - \(NetworkError.sessionError), UserName - пустой")
                        pushCompletionOnTheMainThread(.failure(NetworkError.invalidUserName))
                        return
                    }
                    let profileModel = Profile(
                        userName: profileResult.userName,
                        name: (profileResult.firstName ?? "Иван") + " " + (profileResult.lastName ?? "Иванов"),
                        loginName: "@" + profileResult.userName,
                        bio: profileResult.bio ?? "Hello world!"
                    )
                    self?.profile = profileModel
                    pushCompletionOnTheMainThread(.success(profileModel))
                case .failure(let error):
                    if let urlError = error as? URLError, urlError.code == .cancelled {
                        print("[fetchProfile]: Ошибка - \(NetworkError.raceConditionError), введен повторный запрос")
                    } else {
                        print("[fetchProfile]: Ошибка - \(NetworkError.urlRequestError(error)), при попытке отправить задачу")
                        pushCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                    }
                }
            }
            self.taskState = task
            task.resume()
        }
    }
}
