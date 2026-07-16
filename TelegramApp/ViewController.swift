import UIKit
import TDLibKit

class ViewController: UIViewController, UITextFieldDelegate {

    private let phoneTextField = UITextField()
    private let codeTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let statusLabel = UILabel()

    private var isCodeRequested = false
    private var phoneNumber: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        // Инициализация TDLib (ключи для теста)
        TDLibClient.shared.setApiId(apiId: 2040, apiHash: "b18441a1ff607e10a989891a5462e627")
    }

    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [phoneTextField, codeTextField, loginButton, statusLabel])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])

        phoneTextField.placeholder = "Номер телефона (например, 79123456789)"
        phoneTextField.borderStyle = .roundedRect
        phoneTextField.keyboardType = .numberPad
        phoneTextField.delegate = self

        codeTextField.placeholder = "Код из Telegram"
        codeTextField.borderStyle = .roundedRect
        codeTextField.isHidden = true
        codeTextField.keyboardType = .numberPad
        codeTextField.delegate = self

        loginButton.setTitle("Войти", for: .normal)
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 8
        loginButton.addTarget(self, action: #selector(loginAction), for: .touchUpInside)

        statusLabel.text = "Введите номер"
        statusLabel.textAlignment = .center
        statusLabel.textColor = .gray
    }

    @objc private func loginAction() {
        guard let phone = phoneTextField.text, !phone.isEmpty else {
            statusLabel.text = "Введите номер"
            return
        }

        if !isCodeRequested {
            phoneNumber = phone
            TDLibClient.shared.requestAuthCode(phoneNumber: phoneNumber) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.isCodeRequested = true
                        self?.codeTextField.isHidden = false
                        self?.loginButton.setTitle("Подтвердить", for: .normal)
                        self?.statusLabel.text = "Код отправлен на номер"
                    case .failure(let error):
                        self?.statusLabel.text = "Ошибка: \(error.localizedDescription)"
                    }
                }
            }
        } else {
            guard let code = codeTextField.text, !code.isEmpty else {
                statusLabel.text = "Введите код"
                return
            }
            TDLibClient.shared.checkAuthCode(code: code) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.statusLabel.text = "✅ Авторизация успешна!"
                        self?.showChats()
                    case .failure(let error):
                        self?.statusLabel.text = "Неверный код: \(error.localizedDescription)"
                    }
                }
            }
        }
    }

    private func showChats() {
        let alert = UIAlertController(title: "Ура!", message: "Ты вошёл в Telegram! Теперь тут будут чаты.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
