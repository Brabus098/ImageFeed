//  AuthHelper.swift

import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {
    let configuration: AuthConfiguration
    
    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    
    func authURL() -> URL? {
        guard var urlComponents =  URLComponents(string: AuthConfiguration.standard.authURLString) else {
            print("Ошибка базовой ссылки")
            return nil }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]
        return urlComponents.url
    }
}

extension AuthHelper {
    // Метод формирует запрос для загрузки страницы co входом в систему
    func authRequest() -> URLRequest? {
        guard let url = authURL() else { return nil}
        return URLRequest(url: url)
    }
    
    func code(from url: URL) -> String? {
        if
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItems = items.first(where: {$0.name == "code"})
        {
            return codeItems.value
        } else {
            return nil
        }
    }
}
