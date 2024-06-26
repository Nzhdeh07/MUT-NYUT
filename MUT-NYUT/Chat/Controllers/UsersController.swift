import UIKit

class UsersController: UIViewController {
    
    let api = FirebaseService.shared
    var usersTable = UITableView()
    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Chats"
        self.usersTable = UITableView(frame: view.bounds, style: .plain)
        self.usersTable.delegate = self
        usersTable.dataSource = self
        usersTable.register(UINib(nibName: String(describing: UsersTable.self),bundle: nil), forCellReuseIdentifier: String(describing: UsersTable.self) )
        view.addSubview(usersTable)
        
        let settingsImage = UIImage(systemName: "gear")
        let settingsButton = UIBarButtonItem(title: "gear", image: settingsImage, target: self, action: #selector(openSettings))
        settingsButton.tintColor = .label
        navigationItem.rightBarButtonItem = settingsButton
        
        api.getAllUsers { newUsers in
            DispatchQueue.main.async {
                self.users = newUsers
                self.usersTable.reloadData()
            }
        }
        
    }
    
    @objc func openSettings(){
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        if let view = storyboard.instantiateViewController(withIdentifier: "SettingsController") as? SettingsController {
            navigationController?.pushViewController(view, animated: true)
        }
    }
    
}

extension UsersController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = usersTable.dequeueReusableCell(withIdentifier: String(describing: UsersTable.self), for: indexPath) as! UsersTable
        cell.config(user: users[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.bounds.height / 10
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destinationViewController = ChatViewController(othersender: users[indexPath.row])
        navigationController?.pushViewController(destinationViewController, animated: true)
    }
    
    
}


