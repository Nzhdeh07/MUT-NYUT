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
        print(String(describing: UsersTable.self))
        
        api.getAllUsers { newUsers in
            DispatchQueue.main.async {
                self.users = newUsers
                self.usersTable.reloadData()
            }
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


