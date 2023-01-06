//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Олег Аксененко on 05.01.2023.
//

import UIKit

final class MovieQuizPresenter {
    weak var viewController: MovieQuizViewController?

    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?

    private var currentQuestionIndex: Int = 0

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                                 question: model.text,
                                 questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }

    func isLastQuestion() -> Bool { currentQuestionIndex == questionsAmount - 1 }

    func resetQuestionIndex() { currentQuestionIndex = 0 }

    func switchToNextIndex() { currentQuestionIndex += 1 }

    func yesButtonClicked() {
        guard let currentQuestion else { return }
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
    }

    func noButtonClicked() {
        guard let currentQuestion else { return }
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }
}
