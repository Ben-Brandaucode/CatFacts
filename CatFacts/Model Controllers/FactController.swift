//
//  FactController.swift
//  CatFacts
//
//  Created by Jared Warren on 1/7/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import Foundation

class FactController {
    
    private static let baseURL = URL(string: "http://www.catfact.info")
    
    static func fetchFacts(pageNumber: Int = 1, completion: @escaping (Result<[Fact], FactError>) -> Void) {
        
        guard let baseURL = baseURL else { return completion(.failure(.invalidURL)) }
        let factsURL = baseURL.appendingPathComponent("/api/v1/facts")
        let fullBaseURL = factsURL.appendingPathExtension("json")
        
        var components = URLComponents(url: fullBaseURL, resolvingAgainstBaseURL: true)
        let pageItem = URLQueryItem(name: "page", value: "\(pageNumber)")
        components?.queryItems = [pageItem]
        
        guard let finalURL = components?.url else { return completion(.failure(.invalidURL)) }
        
        URLSession.shared.dataTask(with: finalURL) { data, _, error in
            
            if let error = error {
                print(error, error.localizedDescription)
                return completion(.failure(.thrownError(error)))
            }
            
            guard let data = data else { return completion(.failure(.noData)) }
            
            do {
                
                let topLevel = try JSONDecoder().decode(TopLevelGETObject.self, from: data)
                let facts = topLevel.facts
                return completion(.success(facts))
                
            } catch {
                print(error, error.localizedDescription)
                return completion(.failure(.thrownError(error)))
            }
        }.resume()
    }
    
    static func postFact(details: String, completion: @escaping (Result<Fact, FactError>) -> Void) {
        
        guard let baseURL = baseURL else { return completion(.failure(.invalidURL)) }
        let factsURL = baseURL.appendingPathComponent("/api/v1/facts")
        let fullBaseURL = factsURL.appendingPathExtension("json")
        
        var request = URLRequest(url: fullBaseURL)
        request.httpMethod = "POST"
        
        let post = TopLevelPOSTObject(fact: .init(id: nil, details: details))
        let data = try? JSONEncoder().encode(post)
        request.httpBody = data
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print(error, error.localizedDescription)
                return completion(.failure(.thrownError(error)))
            }
            
            guard let data = data else { return completion(.failure(.noData)) }
            
            do {
                let fact = try JSONDecoder().decode(Fact.self, from: data)
                completion(.success(fact))
                
            } catch {
                print(error, error.localizedDescription)
                return completion(.failure(.thrownError(error)))
            }
        }.resume()
    }
}

enum FactError: LocalizedError {
    case invalidURL
    case thrownError(Error)
    case noData
}
