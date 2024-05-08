import UIKit
import FirebaseAuth

class SettingsController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var messageColor: UIColorWell!
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var passKey: UILabel!
    
    let service = FirebaseService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        name.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        self.passKey.isUserInteractionEnabled = true
        self.passKey.addGestureRecognizer(tapGesture)
        if let uid = Auth.auth().currentUser?.uid{
            service.getUser(uid: uid) { [self] user in
                self.title = user.email
                self.name.text = user.displayName
                service.downloadImage(fromURL: user.profileImageURL ?? "") { image in
                    self.personImage.image = image
                }
            }
        }
        
        let settingsButton = UIBarButtonItem(title: "log out", style: .plain, target: self, action: #selector(logOut))
        settingsButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)], for: .normal)
        navigationItem.rightBarButtonItem = settingsButton
    }
    
    @IBAction func generatePassKey(_ sender: UIButton) {
        let randomKey = generateRandomKey(length: 8)
        self.passKey.text = randomKey
        let email = UserDefaults.standard.object(forKey: "email") as? String
        let password = UserDefaults.standard.object(forKey: "password") as? String
        let userData: [String: Any] = [
            "userEmail": email ?? "",
            "userPassword": password ?? ""
        ]
        UserDefaults.standard.set(userData, forKey: randomKey)
    }
    
    
    @objc func logOut(){
        UserDefaults.standard.set(false, forKey: "isLogin")
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        if let view = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController {
            navigationController?.pushViewController(view, animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           return true
    }
    
    
    func generateRandomKey(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
    
    @objc func labelTapped() {
        guard let passKeyText = self.passKey.text else { return }
        
        UIPasteboard.general.string = passKeyText
        
        let alert = UIAlertController(title: "Passkey Copied", message: "Passkey has been copied to clipboard", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
}
