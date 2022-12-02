//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Олег Аксененко on 28.11.2022.
//

import Foundation
import UIKit

protocol AlertPresenterProtocol {
    func show(alertModel: AlertModel)
}

struct AlertPresenter: AlertPresenterProtocol {
    weak var delegate: UIViewController?

    func show(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert
        )

        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion?()
        }

        alert.addAction(action)

        DispatchQueue.main.async {
            delegate?.present(alert, animated: true, completion: nil)
        }
    }
}
