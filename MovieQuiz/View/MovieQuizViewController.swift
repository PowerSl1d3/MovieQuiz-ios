import UIKit

final class MovieQuizViewController: UIViewController {
    private var presenter: MovieQuizViewOutput?
    private var alertPresenter: AlertPresenterProtocol?

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!

    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!

    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(delegate: self)
        
        shouldShowLoadingIndicator(shouldShow: true)
    }
}


// MARK: - MovieQuizViewInput

extension MovieQuizViewController: MovieQuizViewInput {
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(title: result.title,
                                    message: result.text,
                                    buttonText: result.buttonText) { [weak self] in
            guard let self else { return }

            self.presenter?.restartGame()
            self.presenter?.requestNextQuestion()
        }

        alertPresenter?.show(alertModel: alertModel)
    }

    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
    }

    func resetHighlightImageBorder() {
        imageView.layer.borderWidth = 0
    }

    func shouldShowLoadingIndicator(shouldShow: Bool) {
        if shouldShow {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
    }

    func setButtonsEnableState(_ state: Bool) {
        yesButton.isEnabled = state
        noButton.isEnabled = state
    }

    func showNetworkError(message: String) {
        shouldShowLoadingIndicator(shouldShow: false)

        let alertModel = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self else { return }

            self.shouldShowLoadingIndicator(shouldShow: true)
        }

        alertPresenter?.show(alertModel: alertModel)
    }
}

// MARK: - Actions
private extension MovieQuizViewController {
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        setButtonsEnableState(false)
        presenter?.didTapAnswerButton(isYes: true)
    }

    @IBAction func noButtonClicked(_ sender: UIButton) {
        setButtonsEnableState(false)
        presenter?.didTapAnswerButton(isYes: false)
    }
}
