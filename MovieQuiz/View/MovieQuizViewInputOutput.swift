//
//  MovieQuizViewInputOutput.swift
//  MovieQuiz
//
//  Created by Олег Аксененко on 06.01.2023.
//

protocol MovieQuizViewInput: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)

    func highlightImageBorder(isCorrectAnswer: Bool)
    func resetHighlightImageBorder()

    func shouldShowLoadingIndicator(shouldShow: Bool)
    func setButtonsEnableState(_ state: Bool)
    func showNetworkError(message: String)
}

protocol MovieQuizViewOutput {
    func requestNextQuestion()
    func proceedToNextQuestionOrResults()
    func didAnswer(isCorrectAnswer: Bool)

    func restartGame()

    func didTapAnswerButton(isYes: Bool)
}
