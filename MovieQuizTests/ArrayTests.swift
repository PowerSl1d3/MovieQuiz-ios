//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Олег Аксененко on 03.01.2023.
//

import XCTest
@testable import MovieQuiz

class ArrayTest: XCTestCase {
    func testGetValueInRange() throws {
        // Given
        let array = [1, 1, 2, 3, 5]

        // When
        let value = array[safe: 2]

        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }

    func testValueOutOfRange() throws {
        // Given
        let array = [1, 1, 2, 3, 5]

        // When
        let value = array[safe: 20]

        // Then
        XCTAssertNil(value)
    }
}
