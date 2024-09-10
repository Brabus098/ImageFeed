//  OAuthTokenResponseBody.swift

// Структура декодинга
struct OAuthTokenResponseBody: Codable {
    let token: String
    let error: [String]?
    
    private enum CodingKeys: String, CodingKey {
        case token = "access_token"
        case error = "errors"
    }
}
