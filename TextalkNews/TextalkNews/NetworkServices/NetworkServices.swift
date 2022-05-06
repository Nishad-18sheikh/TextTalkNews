//
//  NetworkServices.swift
//  TextalkNews
//
//  Created by gwl on 05/05/22.
//

import Foundation
import UIKit

enum Endpoint: String {
    case teslaNews = "everything?q=tesla"
    case appleNews = "everything?q=apple"
    case business = "top-headlines?country=us"
    case techCrunch = "top-headlines?sources="
    case wallStreet = "everything?domains="
}
final class NetworkStatus {
    static let shared: NetworkStatus = NetworkStatus()
    var isConnected: Bool = true
    private init() {
    }
}
protocol APIEndpoint {
    associatedtype Response: Codable
    associatedtype Parameters: Codable
    var endPoint: Endpoint { get }
    var httpMethod: HTTPMethod { get }
}

enum HTTPMethod: String {
    case POST, GET, PUT, PATCH, DELETE
}
class NetworkService {
    static let shared = NetworkService()
    private init() {}
    private let baseURL: URL = URL(string: AppEnvironment.current.baseURL())!
    private let timeoutInterval = 60.0
    private let logDebugInfo = true
    // MARK: - Common methods
    private func urlRequest(endpoint: String,
                            method: HTTPMethod,
                            parameters: [String: Any]? = nil,
                            parameterData: Data? = nil) -> URLRequest {
        let urlString: String = baseURL.absoluteString + endpoint
        var urlComponents = URLComponents(string: urlString)!
        var request = URLRequest(url: urlComponents.url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let parameters = parameters {
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        }
        if let parameterData = parameterData {
            request.httpBody = parameterData
        }
        request.httpMethod = method.rawValue
        return request
    }
    func performRequest<Request: Encodable, Response: Decodable>(endpoint: Endpoint,
                                                                 method: HTTPMethod,
                                                                 request: Request,
                                                                 completionHandler: @escaping (_ result: Result<Response, CourtError>) -> Void) {
        do {
            if isConnectedToInternet() {
                let parameters = try JSONEncoder().encode(request)
                let request = self.urlRequest(endpoint: endpoint.rawValue,
                                              method: method, parameterData: parameters)
                performURLRequest(request, completionHandler: completionHandler)
            }
        } catch {
            completionHandler(.failure(.parameterError))
        }
    }
    func performMutipartRequest<Request: Encodable, Response: Decodable>(endpoint: Endpoint,
                                                                         method: HTTPMethod,
                                                                         imageData: [[String: UIImage]] = [[:]],
                                                                         parameter: String? = nil,
                                                                         request: Request,
                                                                         isXAuthRequired: Bool = false,
                                                                         completionHandler: @escaping (_ result: Result<Response, CourtError>) -> Void) {
        do {
            if isConnectedToInternet() {
                let boundary = generateBoundaryString()
                var pathUrl: String = endpoint.rawValue
                if let parameter = parameter {
                    pathUrl = endpoint.rawValue + parameter
                }
                var urlRequest = URLRequest(url: baseURL.appendingPathComponent(pathUrl),
                                            cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData,
                                            timeoutInterval: timeoutInterval)
                urlRequest.httpMethod = method.rawValue
                urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = try createBody(request: request, imageData: imageData, filePathKey: "file", boundary: boundary)
                performURLRequest(urlRequest, completionHandler: completionHandler)
                print(urlRequest)
            }
        } catch {
            completionHandler(.failure(.parameterError))
        }
    }
    func createBody<Request: Encodable>(request: Request,
                                        imageData: [[String: UIImage]],
                                        filePathKey: String,
                                        boundary: String) throws -> Data {
        var body = Data()
        if let dictionary = request.dictionaryAnyValue {
            for (key, value) in dictionary {
                if let dicValue: [String: Any] = value as? [String: Any] {
                    for (key1, value1) in dicValue {
                        body.append("--\(boundary)\r\n")
                        body.append("Content-Disposition: form-data; name=\"\(key).\(key1)\"\r\n\r\n")
                        body.append("\(value1)\r\n")
                    }
                } else {
                    body.append("--\(boundary)\r\n")
                    body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                    body.append("\(value)\r\n")
                }
            }
        }
        for imageObject in imageData {
            print(imageObject)
            let mimetype = "image/jpg"
            body.append("--\(boundary)\r\n")
            if let key = imageObject.keys.first {
                print(key)
                body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key)\"\r\n")
            }
            if let value = imageObject.values.first {
                print(value)
                let data = value.jpegData(compressionQuality: 0.25) ?? Data()
                body.append("Content-Type: \(mimetype)\r\n\r\n")
                body.append(data)
                body.append("\r\n")
            }
        }
        body.append("--\(boundary)--\r\n")
        return body
    }
    func performRequest<Response: Decodable>(endpoint: Endpoint,
                                             method: HTTPMethod,
                                             completionHandler: @escaping (_ result: Result<Response, CourtError>) -> Void) {
        do {
            if isConnectedToInternet() {
                let request = self.urlRequest(endpoint: endpoint.rawValue,
                                              method: method)
                performURLRequest(request, completionHandler: completionHandler)
            }
        } catch {
            completionHandler(.failure(.parameterError))
        }
    }
    func getperformRequest<Response: Decodable>(endpoint: Endpoint,
                                                parameter: String? = nil,
                                                method: HTTPMethod,
                                                completionHandler: @escaping (_ result: Result<Response, CourtError>) -> Void) {
        var pathUrl: String =  endpoint.rawValue
        if let parameter = parameter {
            pathUrl = endpoint.rawValue + parameter
        }
        let request = self.urlRequest(endpoint: pathUrl, method: method)
        if isConnectedToInternet() {
            performURLRequest(request, completionHandler: completionHandler)
        }
    }
    func getperformRequestWithQuery<Response: Decodable>(endpoint: Endpoint,
                                                         queryItem: [String: String] = [:],
                                                         method: HTTPMethod,
                                                         completionHandler: @escaping (_ result: Result<Response, CourtError>) -> Void) {
        var pathUrl: String =  endpoint.rawValue
        var queryItems: [URLQueryItem] = []
        if queryItem.isEmpty == false, var url = URL(string: pathUrl) {
            for items in queryItem.enumerated() {
                let queryItem = URLQueryItem(name: items.element.key, value: items.element.value)
                queryItems.append(queryItem)
            }
            if let updatedUrl = url.appendingItems(queryItems) {
                pathUrl = updatedUrl.absoluteString
            }
        }
        let request = self.urlRequest(endpoint: pathUrl, method: method)
        if isConnectedToInternet() {
            performURLRequest(request, completionHandler: completionHandler)
        }
    }
    private func performURLRequest<T: Decodable>(_ request: URLRequest,
                                                 completionHandler: @escaping (_ result: Result<T, CourtError>) -> Void) {
        let log = logDebugInfo
        if log {
            NSLog("request \(request)")
        }
        URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if log {
                NSLog("response \(response?.description ?? "n/a")")
            }
            if let error = error {
                completionHandler(.failure(error.courtError))
            } else {
                self.handleResponse(data: data,
                                    response: response,
                                    completionHandler: completionHandler)
            }
        }.resume()
    }
    private func handleResponse<T: Decodable>(data: Data?,
                                              response: URLResponse?,
                                              completionHandler: @escaping (_ result: Result<T, CourtError>) -> Void) {
        DispatchQueue.main.async {
            if let httpResponse = response as? HTTPURLResponse {
                if let data = data {
                    do {
                        print(data)
                        switch httpResponse.statusCode {
                        case 200...299:
                            let object: T = try JSONDecoder().decode(T.self, from: data)
                            completionHandler(.success(object))
                        case 400...599:
                            print(CourtError.self)
                            let object = try JSONDecoder().decode(CourtError.self, from: data)
                            completionHandler(.failure(object))
                        default:
                            completionHandler(.failure(CourtError.unknownError))
                        }
                    } catch let error {
                        completionHandler(.failure(error.courtError))
                    }
                } else { // END: if-let data
                    completionHandler(.failure(CourtError.empty))
                }
            } else {// END: if HTTPURLResponse
                completionHandler(.failure(CourtError.unknownError))
            }
        }
    }
    func isConnectedToInternet() -> Bool {
        return NetworkStatus.shared.isConnected
    }
    private func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
}
struct APIResponse<T: Decodable>: Decodable {
    let articles: T
    let status: String
    let totalResults: Int
    public init(articles: T, status: String, totalResults: Int) {
        self.articles = articles
        self.status = status
        self.totalResults = totalResults
    }
}
extension Data {
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}
extension Encodable {
    var dictionaryAnyValue: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data,
                                                  options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }

}
extension URL {
    /// Returns a new URL by adding the query items, or nil if the URL doesn't support it.
    /// URL must conform to RFC 3986.
    func appendingItems(_ queryItems: [URLQueryItem]) -> URL? {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            // URL is not conforming to RFC 3986 (maybe it is only conforming to RFC 1808, RFC 1738, and RFC 2732)
            return nil
        }
        // append the query items to the existing ones
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + queryItems

        // return the url from new url components
        return urlComponents.url
    }
}
