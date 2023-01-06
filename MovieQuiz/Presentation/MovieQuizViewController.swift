import UIKit

final class MovieQuizViewController: UIViewController {
    private var correctAnswers: Int = 0

    private let presenter = MovieQuizPresenter()
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private let statisticService: StatisticService = StatisticServiceImplementation()

    private var currentQuestion: QuizQuestion?

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!

    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!

    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        questionFactory = QuestionFactory(
            delegate: self,
            moviesLoader: MoviesLoader(networkClient: NetworkClient())
        )
        alertPresenter = AlertPresenter(delegate: self)

        questionFactory?.loadData()
        showLoadingIndicator()
    }
}

// MARK: - QuestionFactoryDelegate

extension MovieQuizViewController: QuestionFactoryDelegate {
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }

        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }

    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
        hideLoadingIndicator()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
}

// MARK: - Business logic

extension MovieQuizViewController {
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    private func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(title: result.title,
                                    message: result.text,
                                    buttonText: result.buttonText) { [weak self] in
            guard let self else { return }

            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }

        alertPresenter?.show(alertModel: alertModel)
    }

    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

        if isCorrect {
            correctAnswers += 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }

            self.setButtonsEnableState(true)
            self.reloadResultState()
            self.showNextQuestionOrResults()
        }
    }

    private func reloadResultState() {
        imageView.layer.borderWidth = 0
    }

    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)

            let gamesCount = statisticService.gamesCount
            let bestGame = statisticService.bestGame
            let totalAccuracy = statisticService.totalAccuracy
            let text = """
            Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
            Количество сыгранных квизов: \(gamesCount)
            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", totalAccuracy * 100))%
            """
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )

            show(quiz: viewModel)
        } else {
            presenter.switchToNextIndex()
            questionFactory?.requestNextQuestion()
        }
    }

    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }

    private func showNetworkError(message: String) {
        hideLoadingIndicator()

        let alertModel = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self else { return }

            self.showLoadingIndicator()
        }

        alertPresenter?.show(alertModel: alertModel)
    }
}


// MARK: - Private

private extension MovieQuizViewController {
    func setButtonsEnableState(_ state: Bool) {
        yesButton.isEnabled = state
        noButton.isEnabled = state
    }
}


// MARK: - Actions
private extension MovieQuizViewController {
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        setButtonsEnableState(false)

        guard let currentQuestion else { return }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
    }

    @IBAction func noButtonClicked(_ sender: UIButton) {
        setButtonsEnableState(false)

        guard let currentQuestion else { return }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }
}
