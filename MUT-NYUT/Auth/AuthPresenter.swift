protocol AuthPresenterProtocol: AnyObject {
    func signUp(withEmail email: String, password: String)
    func signIn(withEmail email: String, password: String)
    func signInWithFaceID()
    func signUpSucceeded()
    func signUpFailed(_ message: String)
    func signInSucceeded()
    func signInFailed(_ message: String)
}

class AuthPresenter: AuthPresenterProtocol {
    weak var view: AuthViewProtocol?
    var interactor: AuthInteractorProtocol?
    var router: AuthRouterProtocol?
    
    func signUp(withEmail email: String, password: String) {
        interactor?.signUp(withEmail: email, password: password)
    }
    
    func signIn(withEmail email: String, password: String) {
        interactor?.signIn(withEmail: email, password: password)
    }
    
    func signInWithFaceID() {
        interactor?.signInWithBiometrics()
    }
    
    func signUpSucceeded() {
        router?.navigateToHomeScreen()
    }
    
    func signUpFailed(_ message: String) {
        view?.showError(message)
    }
    
    func signInSucceeded() {
        router?.navigateToHomeScreen()
    }
    
    func signInFailed(_ message: String) {
        view?.showError(message)
    }
}

