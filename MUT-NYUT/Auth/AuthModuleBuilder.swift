import UIKit

class AuthModuleBuilder {
    static func build() -> UIViewController {
        let view = AuthViewController()
        let presenter = AuthPresenter()
        let interactor = AuthInteractor()
        let router = AuthRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        router.viewController = view
        
        return view
    }
}

