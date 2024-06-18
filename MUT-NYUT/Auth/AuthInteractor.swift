import FirebaseAuth
import LocalAuthentication

protocol AuthInteractorProtocol: AnyObject {
    func signUp(withEmail email: String, password: String)
    func signIn(withEmail email: String, password: String)
    func signInWithFaceID()
    func signInWithBiometrics()
}

class AuthInteractor: AuthInteractorProtocol {
    var presenter: AuthPresenterProtocol?
    
    func signUp(withEmail email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.presenter?.signUpFailed(error.localizedDescription)
            } else {
                self.presenter?.signUpSucceeded()
            }
        }
    }
    
    func signIn(withEmail email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.presenter?.signInFailed(error.localizedDescription)
            } else {
                self.presenter?.signInSucceeded()
            }
        }
    }
    
    
    func signInWithBiometrics() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason: String
            switch context.biometryType {
            case .faceID:
                reason = "Идентифицируйте себя с помощью Face ID"
            case .touchID:
                reason = "Идентифицируйте себя с помощью Touch ID"
            case .none:
                reason = "Идентифицируйте себя"
            @unknown default:
                reason = "Идентифицируйте себя"
            }

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.presenter?.signInSucceeded()
                    } else {
                        print("Biometric authentication failed with error: \(error?.localizedDescription ?? "Unknown error")")
                        self.presenter?.signInFailed(error?.localizedDescription ?? "Ошибка входа")
                    }
                }
            }
        } else {
            print("Biometric authentication not available. Error: \(error?.localizedDescription ?? "Unknown error")")
            presenter?.signInFailed("Биометрическая аутентификация не найдена. Ошибка: \(error?.localizedDescription ?? "Неизвестная ошибка")")
        }
    }


    
    func signInWithFaceID() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Идентифицируйте себя"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                if success {
                    DispatchQueue.main.async {
                        self.presenter?.signInSucceeded()
                    }
                } else {
                    self.presenter?.signInFailed(error?.localizedDescription ?? "Ошибка входа")
                }
            }
        } else {
            presenter?.signInFailed("Face/Touch ID не найден")
        }
    }
}

