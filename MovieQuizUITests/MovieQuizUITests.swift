//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Олег Аксененко on 03.01.2023.
//

import XCTest

final class MovieQuizUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()

        app = XCUIApplication()
        app.launch()

        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        app.terminate()
        app = nil
    }

    func testYesButton() {
        let firstPoster = app.images["Poster"]

        sleep(3)

        app.buttons["Yes"].tap()

        let secondPoster = app.images["Poster"]
        let indexLabel = app.staticTexts["Index"]

        sleep(3)

        XCTAssertTrue(indexLabel.label == "2/10")
        XCTAssertFalse(firstPoster == secondPoster)
    }

    func testNoButton() {
        let firstPoster = app.images["Poster"]

        sleep(3)

        app.buttons["No"].tap()

        let secondPoster = app.images["Poster"]
        let indexLabel = app.staticTexts["Index"]

        sleep(3)

        XCTAssertTrue(indexLabel.label == "2/10")
        XCTAssertFalse(firstPoster == secondPoster)
    }

    func testGameFinish() {
        for _ in 0..<10 {
            sleep(3)
            app.buttons["Yes"].tap()
        }

        sleep(3)

        let alert = app.alerts["Этот раунд окончен!"]

        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
    }

    func testAlertDismiss() {
        for _ in 0..<10 {
            sleep(3)
            app.buttons["Yes"].tap()
        }

        sleep(3)

        let alert = app.alerts["Этот раунд окончен!"]
        alert.buttons.firstMatch.tap()

        sleep(3)

        let indexLabel = app.staticTexts["Index"]

        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
}
