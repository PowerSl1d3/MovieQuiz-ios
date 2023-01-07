//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Олег Аксененко on 05.01.2023.
//

import UIKit

final class MovieQuizPresenter {
    private weak var viewInput: MovieQuizViewInput?

    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticService = StatisticServiceImplementation()

    private var currentQuestion: QuizQuestion?

    private var currentQuestionIndex: Int = 0
    private let questionsAmount: Int = 10
    private var correctAnswers: Int = 0

    init(viewController: MovieQuizViewInput) {
        self.viewInput = viewController
        self.questionFactory = QuestionFactory(
            delegate: self,
            moviesLoader: MoviesLoader(networkClient: NetworkClient())
        )

        self.viewInput?.shouldShowLoadingIndicator(shouldShow: true)
        self.questionFactory?.loadData()
    }
}

// MARK: - MovieQuizViewOutput

extension MovieQuizPresenter: MovieQuizViewOutput {
    func requestNextQuestion() {
        questionFactory?.requestNextQuestion()
    }

    func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: questionsAmount)

            let resultMessage = makeResultMessage()

            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: resultMessage,
                buttonText: "Сыграть ещё раз"
            )

            viewInput?.show(quiz: viewModel)
        } else {
            switchToNextIndex()
            questionFactory?.requestNextQuestion()
        }
    }

    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }

    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
    }

    func didTapAnswerButton(isYes: Bool) {
        guard let currentQuestion else { return }
        proceedWithAnswer(isCorrect: currentQuestion.correctAnswer == isYes)
    }
}

// MARK: - QuestionFactoryDelegate

extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }

        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewInput?.show(quiz: viewModel)
        }
    }

    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
        viewInput?.shouldShowLoadingIndicator(shouldShow: false)
    }

    func didFailToLoadData(with error: Error) {
        viewInput?.showNetworkError(message: error.localizedDescription)
    }
}

// MARK: - Private

private extension MovieQuizPresenter {
    func isLastQuestion() -> Bool { currentQuestionIndex == questionsAmount - 1 }

    func switchToNextIndex() { currentQuestionIndex += 1 }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                                 question: model.text,
                                 questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }

    func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewInput?.highlightImageBorder(isCorrectAnswer: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }

            self.viewInput?.setButtonsEnableState(true)
            self.viewInput?.resetHighlightImageBorder()
            self.proceedToNextQuestionOrResults()
        }
    }

    func makeResultMessage() -> String {
        let gamesCount = statisticService.gamesCount
        let bestGame = statisticService.bestGame
        let totalAccuracy = statisticService.totalAccuracy

        let resultMessage = """
        Ваш результат: \(correctAnswers)/\(questionsAmount)
        Количество сыгранных квизов: \(gamesCount)
        Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
        Средняя точность: \(String(format: "%.2f", totalAccuracy * 100))%
        """

        return resultMessage
    }
}

#if DEBUG
// MARK: - Private Proxy Test Extenstion
/// Данное расширение используется только для тестирования приватных методов класса.
/// Недоступно в релизной сборке.

extension MovieQuizPresenter {
    func convertTest(model: QuizQuestion) -> QuizStepViewModel { convert(model: model) }
}
#endif
