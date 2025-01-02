import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidRequest
    case decodingError
    case httpError(Int)
    case unknown
    case unauthorized
    case quizError(String)
    case rateLimitExceeded
} 