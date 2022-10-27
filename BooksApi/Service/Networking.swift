import Foundation
import UIKit

enum Errors: Error {
    case noData
    case decodeFailed
}

class Network {
    
    let baseUrl = "https://sandbox.mercadoeditorial.org/api/v1.2/book?codigo_status=1"
    let baseUrlFilter = "https://sandbox.mercadoeditorial.org/api/v1.2/book"
    
    func getBooks(completion: @escaping (Result<Product, Errors>) -> Void) {
        guard let url = URL(string: baseUrl) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            do {
                let jsonResult = try JSONDecoder().decode(Product.self, from: data)
                completion(Result.success(jsonResult))
            } catch {
                completion(Result.failure(.decodeFailed))
            }
        }
        task.resume()
    }
    
    func filterBooksForTitle(with title: String, completion: @escaping (Result<Product, Errors>) -> Void) {
        
        guard let url = URL(string: "(baseUrlFilter)?titulo=(title)") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            do {
                let jsonResult = try JSONDecoder().decode(Product.self, from: data)
                completion(Result.success(jsonResult))
            } catch {
                completion(Result.failure(.decodeFailed))
            }
        }
        task.resume()
    }
}
