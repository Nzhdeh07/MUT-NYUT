import UIKit

protocol AuthRouterProtocol: AnyObject {
    func navigateToHomeScreen()
}

class AuthRouter: AuthRouterProtocol {
    weak var viewController: UIViewController?
    
    func navigateToHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newVC = storyboard.instantiateViewController(withIdentifier: "UsersController") as! UsersController
        viewController?.navigationController?.setViewControllers([newVC], animated: true)
    }
}

