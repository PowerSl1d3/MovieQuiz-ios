//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Олег Аксененко on 28.11.2022.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didRecieveNextQuestion(question: QuizQuestion?)
}
