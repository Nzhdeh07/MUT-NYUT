import UIKit

class PhotoController: UIViewController {
    
    let service = FirebaseService.shared
    var images: [UIImage] = []

    @IBOutlet weak var PhotoCollection: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Photo"
        PhotoCollection.register(UINib(nibName: String(describing: PhotoCell.self),bundle: nil), forCellWithReuseIdentifier: String(describing: PhotoCell.self) )
        PhotoCollection.dataSource = self
        PhotoCollection.delegate = self
    }
    
    func config(chatId: String) {
        service.getChatPhoto(chatId: chatId) { [weak self] image in
            self?.images.append(image)
            DispatchQueue.main.async {
                self?.PhotoCollection.reloadData()
            }
        }
    }
    
}


extension PhotoController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.bounds.height / 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = PhotoCollection.dequeueReusableCell(withReuseIdentifier: String(describing: PhotoCell.self), for: indexPath) as! PhotoCell
        cell.photo.image = self.images[indexPath.row]
        return cell
    }
    
     
}
