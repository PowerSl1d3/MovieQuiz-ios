//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//
//  Created by Олег Аксененко on 07.01.2023.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerProtocolMock: MovieQuizViewInput {
    func show(quiz step: MovieQuiz.QuizStepViewModel) {}
    func show(quiz result: MovieQuiz.QuizResultsViewModel) {}
    func highlightImageBorder(isCorrectAnswer: Bool) {}
    func resetHighlightImageBorder() {}
    func shouldShowLoadingIndicator(shouldShow: Bool) {}
    func setButtonsEnableState(_ state: Bool) {}
    func showNetworkError(message: String) {}
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerProtocolMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)

        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convertTest(model: question)

        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
