import UIKit
import Foundation
import FirebaseCore
import FirebaseAuth
import UserNotifications
import LocalAuthentication
import Security
import CryptoKit

protocol AuthViewProtocol: AnyObject {
    func showError(_ message: String)
}


class AuthViewController: UIViewController, AuthViewProtocol, UITextFieldDelegate {
    
    var presenter: AuthPresenterProtocol?
    var Sing: UIView!
    var label: UILabel!
    var email: String!
    var password: String! = ""
    var isSignupOnTop = true
    var signupView: SkewedRectangleViewRight!
    var loginView: SkewedRectangleViewLeft!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        requestNotificationAuthorization()
    }
    
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if !granted {
                print("Не удалось получить разрешения на уведомления: \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    
    @IBAction func Sign(_ sender: Any) {
        presenter?.signUp(withEmail: email, password: password)
    }
    
    @IBAction func signIn(_ sender: Any) {
        presenter?.signIn(withEmail: email, password: password)
    }
    
    @objc func signInWithFaceID(){
        presenter?.signInWithFaceID()
    }
    
    func showError(_ message: String) {
        AlertHelper.showAlert(on: self, title: "Ошибка", message: message)
    }
    
    
    func config(){
        let safeArea = view.safeAreaLayoutGuide.layoutFrame
        Sing = UIView(frame: CGRect(x: safeArea.width * 0.1, y: safeArea.height / 3, width: safeArea.width * 0.8, height: safeArea.height / 2))
        view.addSubview(Sing)
        label = UILabel(frame: CGRect(x: safeArea.width * 0.1 , y: safeArea.height / 8, width: safeArea.width * 0.8, height: safeArea.height / 10))
        label.text = "Hello"
        label.textColor = UIColor.label
        label.font = UIFont.boldSystemFont(ofSize: 35.0)
        label.textAlignment  = .center
        view.addSubview(label)
        setupLoginView()
        setupSignupView()
        setupStackView()
        setupLoginStackView()
    }
    
    private func setupLoginView() {
        loginView = SkewedRectangleViewLeft()
        loginView.backgroundColor = .clear
        loginView.clipsToBounds = true
        Sing.addSubview(loginView)
        loginView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loginView.leadingAnchor.constraint(equalTo: Sing.leadingAnchor),
            loginView.trailingAnchor.constraint(equalTo: Sing.trailingAnchor),
            loginView.topAnchor.constraint(equalTo: Sing.topAnchor),
            loginView.bottomAnchor.constraint(equalTo: Sing.bottomAnchor)
        ])
        
        let button = createButton(title: "Login", action: #selector(LoginOnTop))
        loginView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: loginView.topAnchor, constant: 30),
            button.leadingAnchor.constraint(equalTo: loginView.leadingAnchor, constant: 20),
            button.widthAnchor.constraint(equalToConstant: 100),
            button.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        let button2 = createButton(title: "Sign Up", action: #selector(SignupOnTop))
        loginView.addSubview(button2)
        
        NSLayoutConstraint.activate([
            button2.topAnchor.constraint(equalTo: loginView.topAnchor, constant: 30),
            button2.trailingAnchor.constraint(equalTo: loginView.trailingAnchor, constant: -20),
            button2.widthAnchor.constraint(equalToConstant: 100),
            button2.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    private func setupSignupView() {
        signupView = SkewedRectangleViewRight()
        signupView.backgroundColor = .clear
        signupView.clipsToBounds = true
        Sing.addSubview(signupView)
        signupView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signupView.leadingAnchor.constraint(equalTo: Sing.leadingAnchor),
            signupView.trailingAnchor.constraint(equalTo: Sing.trailingAnchor),
            signupView.topAnchor.constraint(equalTo: Sing.topAnchor),
            signupView.bottomAnchor.constraint(equalTo: Sing.bottomAnchor)
        ])
        
        let button = createButton(title: "Login", action: #selector(LoginOnTop))
        signupView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: loginView.topAnchor, constant: 30),
            button.leadingAnchor.constraint(equalTo: loginView.leadingAnchor, constant: 20),
            button.widthAnchor.constraint(equalToConstant: 100),
            button.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        let button2 = createButton(title: "Sign Up", action: #selector(SignupOnTop))
        signupView.addSubview(button2)
        
        NSLayoutConstraint.activate([
            button2.topAnchor.constraint(equalTo: loginView.topAnchor, constant: 30),
            button2.trailingAnchor.constraint(equalTo: loginView.trailingAnchor, constant: -20),
            button2.widthAnchor.constraint(equalToConstant: 100),
            button2.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    private func setupStackView() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        signupView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: signupView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: signupView.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: signupView.centerYAnchor)
        ])
        
        let emailStack = createLoginFieldStackView(placeholder: "Enter email")
        stackView.addArrangedSubview(emailStack)
        
        let passwordStack = createPasswordFieldStackView(placeholder: "Enter password")
        stackView.addArrangedSubview(passwordStack)
        
        let button = createButton(title: "Sing Up", action: #selector(Sign))
        button.setTitleColor(.black, for: .normal)
        signupView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: loginView.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: loginView.bottomAnchor, constant: -30),
            button.widthAnchor.constraint(equalToConstant: 100),
            button.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    private func setupLoginStackView() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        loginView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: loginView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: loginView.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: loginView.centerYAnchor)
        ])
        
        let emailStack = createLoginFieldStackView(placeholder: "Enter email")
        stackView.addArrangedSubview(emailStack)
        
        let passwordStack = createPasswordFieldStackView(placeholder: "Enter password")
        stackView.addArrangedSubview(passwordStack)
        
        
        let faceIDButton = UIButton(type: .system)
        if let image = UIImage(systemName: "faceid")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)) {
            faceIDButton.setImage(image, for: .normal)
        }
        faceIDButton.tintColor = .black
        faceIDButton.addTarget(self, action: #selector(signInWithFaceID), for: .touchUpInside)
        loginView.addSubview(faceIDButton)
        
        faceIDButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            faceIDButton.centerXAnchor.constraint(equalTo: loginView.centerXAnchor),
            faceIDButton.bottomAnchor.constraint(equalTo: loginView.bottomAnchor, constant: -80),
            faceIDButton.widthAnchor.constraint(equalToConstant: 100),
            faceIDButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        let button = createButton(title: "Login", action: #selector(signIn))
        button.setTitleColor(.black, for: .normal)
        loginView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: loginView.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: loginView.bottomAnchor, constant: -30),
            button.widthAnchor.constraint(equalToConstant: 100),
            button.heightAnchor.constraint(equalToConstant: 30)
        ])
        
    }
    
    func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    func createLoginFieldStackView(placeholder: String) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        let emailTextField = UITextField()
        emailTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
        let attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        emailTextField.attributedPlaceholder = attributedPlaceholder
        emailTextField.addTarget(self, action: #selector(emailTextFieldDidChange(_:)), for: .editingChanged)
        emailTextField.delegate = self
        stackView.addArrangedSubview(emailTextField)
        
        let line = UIView()
        line.backgroundColor = .black
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        stackView.addArrangedSubview(line)
        
        return stackView
    }
    func createPasswordFieldStackView(placeholder: String) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let passwordTextField = UITextField()
        passwordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
        let attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        passwordTextField.attributedPlaceholder = attributedPlaceholder
        passwordTextField.addTarget(self, action: #selector(passwordTextFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.delegate = self
        stackView.addArrangedSubview(passwordTextField)
        
        let line = UIView()
        line.backgroundColor = .black
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        stackView.addArrangedSubview(line)
        
        return stackView
    }
    
    @objc func emailTextFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            self.email = text
        }
    }
    @objc func passwordTextFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            self.password = text
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func SignupOnTop() {
        Sing.bringSubviewToFront(signupView)
    }
    @objc func LoginOnTop() {
        Sing.bringSubviewToFront(loginView)
    }
}





