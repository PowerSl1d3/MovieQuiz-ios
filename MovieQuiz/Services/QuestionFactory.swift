//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Олег Аксененко on 27.11.2022.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private weak var delegate: QuestionFactoryDelegate?

    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []

    enum QuestionPredicate: CaseIterable {
        case more
        case less
    }

    init(delegate: QuestionFactoryDelegate?, moviesLoader: MoviesLoading) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }

    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }

    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            let index = (0...self.movies.count).randomElement() ?? 0

            guard let movie = self.movies[safe: index] else { return }

            var imageData = Data()

            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failure to load image")
            }

            let rating = Float(movie.rating) ?? 0
            let questionRating = Float((5...8).randomElement() ?? 7)
            let predicate = QuestionPredicate.allCases.randomElement() ?? .more

            let text = "Рейтинг этого фильма \(predicate == .more ? "больше" : "меньше") чем \(Int(questionRating))?"
            let correctAnswer = predicate == .more ? rating > questionRating : rating < questionRating

            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.didRecieveNextQuestion(question: question)
            }
        }
    }
}

//private let questions: [QuizQuestion] = [
//    QuizQuestion(image: "The Godfather",
//                 text: "Рейтинг этого фильма больше чем 6?",
//                 correctAnswer: true),
//    QuizQuestion(image: "The Dark Knight",
//                 text: "Рейтинг этого фильма больше чем 6?",
//                 correctAnswer: true),
//    QuizQuestion(image: "Kill Bill",
//                 text: "Рейтинг этого фильма больше чем 6?",
//                 correctAnswer: true),
//    QuizQuestion(image: "The Avengers",
//                 text: "Рейтинг этого фильма больше чем 6?",
//                 correctAnswer: true),
//    QuizQuestion(image: "Deadpool",
//                 text: "Рейтинг этого фильма больше чем 6?",
//                 correctAnswer: true),
//    QuizQuestion(image: "The Green Knight",
//                 text: "Рейтинг этого фильма больше чем 6?",
//                 correctAnswer: true),
//    QuizQuestion(image: "Old",
//                 text: "Рейтинг этого фильма больше чем 6?",
//                 correctAnswer: false),
//    QuizQuestion(image: "The Ice Age Adventures of Buck Wild",
//                 text: "Рейтинг этого фильма больше чем 6?",
//                 correctAnswer: false),
//    QuizQuestion(image: "Tesla",
//                 text: "Рейтинг этого фильма больше чем 6?",
//                 correctAnswer: false),
//    QuizQuestion(image: "Vivarium",
//                 text: "Рейтинг этого фильма больше чем 6?",
//                 correctAnswer: false)
//]
