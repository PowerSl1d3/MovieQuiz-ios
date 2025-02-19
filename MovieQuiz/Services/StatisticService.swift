//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Олег Аксененко on 29.11.2022.
//

import Foundation

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }

    func store(correct count: Int, total amount: Int)
}

final class StatisticServiceImplementation: StatisticService {
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    private let userDefaults = UserDefaults.standard

    var totalAccuracy: Double {
        get {
            Double(userDefaults.integer(forKey: Keys.correct.rawValue)) / Double(userDefaults.integer(forKey: Keys.total.rawValue))
        }
    }

    private(set) var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }

    private(set) var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {

                return .init(correct: 0, total: 0, date: Date())
            }

            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")

                return
            }

            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }

    func store(correct count: Int, total amount: Int) {
        let potentialGameRecord = GameRecord(correct: count, total: amount, date: Date())

        if bestGame < potentialGameRecord {
            bestGame = potentialGameRecord
        }

        gamesCount += 1

        let previousCorrectCount = userDefaults.integer(forKey: Keys.correct.rawValue)
        let previousTotalAmount = userDefaults.integer(forKey: Keys.total.rawValue)

        userDefaults.set(previousCorrectCount + count, forKey: Keys.correct.rawValue)
        userDefaults.set(previousTotalAmount + amount, forKey: Keys.total.rawValue)
    }
}
