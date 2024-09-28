//OAuth2Service.swift

import UIKit
import ProgressHUD

final class OAuth2Service {
    
    // MARK: OAuth2Service
    static let shared = OAuth2Service()
    private init() {}
    
    // MARK: Properties
    private var saveToken = KeychainStorage()
    private var task: URLSessionTask?
    private var lastCode: String?
    
    // MARK: Methods
    //Метод генерирует POST для получения Bearer Token
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print(NetworkError.createUrlError("[makeOAuthTokenRequest]: Failed to create URL"))
            return nil }
        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL
        ) else {
            print("[makeOAuthTokenRequest]: Ошибка - \(NetworkError.makeRequestError), не удалось собрать Post запрос, не верный code - \(code)")
            return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    // Метод создает задачу на отправление запроса в сеть
    func fetchOAuthToken(code: String,  completion: @escaping (Result<String, Error>) -> Void ){
        assert(Thread.isMainThread)
        guard lastCode != code else { // проверяем выполняется ли запрос
            print("[fetchOAuthToken]: Ошибка - \(NetworkError.raceConditionError), отправлен повторный запрос")
            completion(.failure(NetworkError.raceConditionError)) // если выполняется сообщаем об ошибке
            return
        }
        task?.cancel()  // так как новый токен уже сгенироровался отменяем старый запрос, если он не nil
        lastCode = code
        
        guard
            let request = makeOAuthTokenRequest(code: code) // делаем POST запрос
        else {
            print("[fetchOAuthToken]: Ошибка - \(NetworkError.makeRequestError), при формирование POST запрсоа")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            switch result{
            case .success(let response):
                guard !response.token.isEmpty else {
                    print("[fetchOAuthToken]:, Ошибка - \(String(describing: DecodingError.keyNotFound)), токен пустой ")
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.invalidToken))
                    }
                    return
                }
                if let errors = response.error, !errors.isEmpty {
                    print("[fetchOAuthToken]: Ошибка - \(NetworkError.apiError(errors)), ошибка пришла ошибка внутри Json")
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.apiError(errors)))
                    }
                    return
                }
                self?.saveToken.token = response.token // сохранем access_token в случае успешно пройденных проверок
                DispatchQueue.main.async {
                    completion(.success(response.token))
                }
            case .failure(let error):
                print("[fetchOAuthToken], Ошибка - \(NetworkError.urlRequestError(error)), при попытке создать задачу для отправления в сеть ")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.urlRequestError(error)))
                }
            }
            DispatchQueue.main.async {
                self?.task = nil
                self?.lastCode = nil
            }
        }
        self.task = task
        task.resume()
    }
}
