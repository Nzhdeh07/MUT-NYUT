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
        PhotoCollection.isPagingEnabled = true
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


extension PhotoController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = PhotoCollection.dequeueReusableCell(withReuseIdentifier: String(describing: PhotoCell.self), for: indexPath) as! PhotoCell
        cell.photo.image = self.images[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.PhotoCollection.bounds.size.width / 2, height: self.PhotoCollection.bounds.size.height / 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
          return .zero
      }
      
      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
          return 0
      }
      
      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
          return 0
      }

    
     
}
