//  URLSession+data.swift

import UIKit

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlResponseError(Error)
    case urlSessionError
    case decodingError
    case makeRequestError
    case raceConditionError
    case invalidRequest
    case sessionError
    case invalidToken
    case error
    case createImageError
    case getRequestProfile
    case invalidUserName
    case createUrlError(String)
    case apiError([String])
}
extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in  // Выводим информацию о запросе на главный поток
            DispatchQueue.main.async { completion(result) }
        }
        // Первый этап обработки ответа от сервера
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    print("[data]: Ошибка -  \(NetworkError.httpStatusCode(statusCode)), на первом этапе сетового запроса")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                print("[data]: Ошибка - \(NetworkError.urlResponseError(error)) при попытке обработки ответа от сервера")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlResponseError(error)))
            } else {
                print("[data]: Ошибка - \(NetworkError.urlSessionError), при обработке dataTask")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        return task
    }
}
extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        // Второй этап обработки от сервера
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data) :
                do {
                    let response = try decoder.decode(T.self, from: data)
                    completion(.success(response))
                } catch {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("[objectTask]: Ошибка декодирования: \(error.localizedDescription), данные: \(jsonString))")
                    }
                }
            case .failure(let error) :
                print("[objectTask]: Ошибка - \(error), декодирование не начато")
                completion(.failure(error))
            }
        }
        return task
    }
}
