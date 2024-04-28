import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let navigationController = UINavigationController()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard (scene is UIWindowScene) else { return }
        
        window?.rootViewController = navigationController
        
        let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
        if isLogin {
            mainPage()
        } else {
            loginPage()
        }
        
        
    }
    
    func loginPage(){
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        if let view = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController {
            self.navigationController.pushViewController(view, animated: true)
        }
    }
    
    func mainPage(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let view = storyboard.instantiateViewController(withIdentifier: "UsersController") as? UsersController {
            self.navigationController.pushViewController(view, animated: true)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {

    }


}


