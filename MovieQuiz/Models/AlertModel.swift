//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Олег Аксененко on 28.11.2022.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (() -> Void)?
}
