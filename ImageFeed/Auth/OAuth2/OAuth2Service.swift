//OAuth2Service.swift

import UIKit

final class OAuth2Service {
    
    // MARK: OAuth2Service
    static let shared = OAuth2Service() // здесь глобальная точка входа, через которую теперь мы будем обращаться.
    private init() {}                   // гарантируем единственность экземляра
    
    // MARK: Properties
    private var saveToken = OAuth2TokenStorage()
    
    // MARK: Methods
    //Метод генерирует POST для получения Bearer Token
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else { return nil }
        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL
        ) else {
            print("Не удалось собрать Post запрос, не верный code - \(code)")
            return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    // Метод создает задачу на отправление запроса в сеть
    func fetchOAuthToken(code: URLRequest,  completion: @escaping (Result<String, Error>) -> Void ){
        let URLSessionTask = URLSession.shared.data(for: code) { result in //Создаем задачу и запускаем расширение
            switch result { //   Второй этап обработки ответа от сервера
            case .success(let data):
                do{
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data) // пробуем привест полученные данные в access_token с помощью модели
                    guard !response.token.isEmpty else {
                        
                        print("Токен пустой, \(String(describing: DecodingError.keyNotFound))")
                        completion(.failure(NetworkError.invalidToken))
                        return
                    }
                    if let errors = response.error, !errors.isEmpty {
                        print("Пришла ошибка внутри Json, \(NetworkError.apiError(errors))")
                        completion(.failure(NetworkError.apiError(errors)))
                        return
                    }
                    self.saveToken.token = response.token // сохранем access_token в случае успешно пройденных проверок
                    completion(.success(response.token))
                } catch {
                    print("Ошибка при кодировке объекта Data, для url - \(code)")
                    completion(.failure(NetworkError.decodingError))
                }
            case .failure(let error):
                print("Ошибка - \(NetworkError.urlRequestError(error)), при попытке отправить создать задачу для отправления в сеть ")
                completion(.failure(NetworkError.urlRequestError(error)))
            }
        }
        URLSessionTask.resume()
    }
}

