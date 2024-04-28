import UIKit

class UsersTable: UITableViewCell {
        
   
    @IBOutlet weak var PersonName: UILabel!
    @IBOutlet weak var personImage: UIImageView!
    
    let api = FirebaseService.shared
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func config(user: User){
        self.PersonName.text = user.email
        if let letImageURL = user.profileImageURL {
            api.downloadImage(fromURL: letImageURL, completion: { image in
                DispatchQueue.main.async {
                    self.personImage.image = image
                }
            })
        }
        }
    
}

