//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Олег Аксененко on 02.01.2023.
//

import Foundation

protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}

struct NetworkClient: NetworkRouting {
    private enum NetworkError: Error {
        case codeError
        case dataError
    }

    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                handler(.failure(error))

                return
            }

            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))

                return
            }

            guard let data else {
                handler(.failure(NetworkError.dataError))
                return
            }
            handler(.success(data))
        }

        task.resume()
    }
}
