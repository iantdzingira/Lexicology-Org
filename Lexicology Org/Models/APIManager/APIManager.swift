//
//  APIManager.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 18/12/2025.
//

import Foundation

class APIManager {
    static let shared = APIManager()
    private let baseURL = "http://localhost:3001/api"
    
    func fetchWords(completion: @escaping ([WordEntry]?) -> Void) {
        guard let url = URL(string: "\(baseURL)/words") else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                struct WordResponse: Codable {
                    let id: String
                    let word: String
                    let meaning: String
                    let sentence: String
                    let source: String
                    let creation_date: String
                }
                
                let responses = try JSONDecoder().decode([WordResponse].self, from: data)
                
                let words = responses.map { resp -> WordEntry in
                    let entry = WordEntry(word: resp.word, meaning: resp.meaning, sentence: resp.sentence, source: resp.source)
                    entry.id = resp.id
                    return entry
                }
                
                DispatchQueue.main.async {
                    completion(words)
                }
            } catch {
                print("Decoding error: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    
    func saveUser(firstName: String, lastName: String, birthDate: Date, email: String, categories: [String], completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/users") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "birthDate": ISO8601DateFormatter().string(from: birthDate),
            "email": email,
            "categories": categories
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }.resume()
    }
    
    func uploadWord(word: String, meaning: String, sentence: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/words") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "id": UUID().uuidString,
            "user_id": "default-user-id",
            "word": word,
            "meaning": meaning,
            "sentence": sentence,
            "source": "User",
            "creation_date": ISO8601DateFormatter().string(from: Date())
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }.resume()
    }
}
