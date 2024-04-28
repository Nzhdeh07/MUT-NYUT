import Foundation
import MessageKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore


class FirebaseService{
    
    static let shared =  FirebaseService()
    
    init(){}
    
    
    func SingUpWithEmail(email: String, password: String, completion: @escaping(Bool, String)->Void){
        Auth.auth().createUser(withEmail: email, password: password){(res, err) in
            if err != nil{
                completion(false,(err?.localizedDescription)!)
                return
            }
            let userId = res?.user.uid
            let email_ = res?.user.email
            let data: [String: Any] = ["email": email_!]
            Firestore.firestore().collection("users").document(userId!).setData(data)
            UserDefaults.standard.set(true, forKey: "isLogin")
            completion(true,(res?.user.email)!)
        }
    }
    
    func signInWithEmail(email: String, password: String, completion: @escaping (Bool, String) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                completion(true, "Вход успешно выполнен")
            }
        }
    }
    
    func confrimEmail(){
        Auth.auth().currentUser?.sendEmailVerification(completion: {err in
            if err != nil{
                print(err!.localizedDescription)
            }
        })
    }
    
    func getAllUsers(completion: @escaping ([User])->()){
        guard let email = Auth.auth().currentUser?.email else {return}
        var users = [User]()
        Firestore.firestore().collection("users").whereField("email", isNotEqualTo: email).getDocuments {snap, err in
            if err ==  nil{
                if let docs = snap?.documents{
                    for doc in docs{
                        let data = doc.data()
                        let userId = doc.documentID
                        let email = data["email"] as! String
                        if let photoURL = data["photoURL"] as? String {
                            users.append(User(senderId: userId, email: email, profileImageURL: photoURL))
                            break
                        }
                        users.append(User(senderId: userId, email: email))
                    }
                }
                completion(users)
            }
        }
    }
    
    func sendMessage(otherId: String?, convoId: String?, text: String, completion: @escaping (String)->()){
        if let uid = Auth.auth().currentUser?.uid{
            if convoId == nil {
                let convoId = UUID().uuidString
                let selfData: [String: Any] = [
                    "date": Date(),
                    "otherId": otherId!
                ]
                let otherData: [String: Any] = [
                    "date": Date(),
                    "otherId": uid
                ]
                Firestore.firestore().collection("users").document(uid).collection("conversations").document(convoId).setData(selfData)
                Firestore.firestore().collection("users").document(otherId!).collection("conversations").document(convoId).setData(otherData)
                
                let msg: [String: Any] = [
                    "date": Date(),
                    "sender": uid,
                    "text": text
                ]
                
                let convoInfo:[String: Any] = [
                    "date": Date(),
                    "selfSender": uid,
                    "otherSender": otherId!
                ]
                
                Firestore.firestore().collection("conversations").document(convoId).setData(convoInfo) { err in
                    if let err = err{
                        print(err.localizedDescription)
                    }
                    Firestore.firestore().collection("conversations").document(convoId).collection("messages").addDocument(data: msg){ err in
                        if err == nil{
                            completion(convoId)
                        }
                    }
                }
                //
            } else {
                let msg: [String: Any] = [
                    "date": Date(),
                    "sender": uid,
                    "text": text
                ]
                
                Firestore.firestore().collection("conversations").document(convoId!).collection("messages").addDocument(data: msg) { err in
                    if err == nil{
                        completion(convoId!)
                    }
                }
            }
        }
    }
    
    func getConvoId(otherId: String, completion: @escaping (String)->()){
        if let uid = Auth.auth().currentUser?.uid{
            let ref = Firestore.firestore()
            ref.collection("users").document(uid).collection("conversations").whereField("otherId", isEqualTo: otherId).getDocuments { snap, err in
                if err != nil {
                    return
                }
                
                if let snap = snap, !snap.documents.isEmpty{
                    let doc = snap.documents.first
                    if let convoId = doc?.documentID{
                        completion(convoId)
                    }
                }
            }
        }
    }
    func uploadImageToFirebase(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "imageData", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        let storageRef = Storage.storage().reference()
        let imageName = "\(UUID().uuidString).jpg"
        let imageRef = storageRef.child("images/\(imageName)")
        
        imageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                imageRef.downloadURL { (url, error) in
                    if let error = error {
                        completion(.failure(error))
                    } else if let url = url {
                        completion(.success(url))
                    } else {
                        completion(.failure(NSError(domain: "imageData", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                    }
                }
            }
        }
    }
    
    
    func sendMessageWithPhoto(convoId: String, senderUid: String, image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        uploadImageToFirebase(image: image) { result in
            switch result {
            case .success(let url):
                let msg: [String: Any] = [
                    "date": Date(),
                    "sender": senderUid,
                    "photoURL": url.absoluteString
                ]
                Firestore.firestore().collection("conversations").document(convoId).collection("messages").addDocument(data: msg) { err in
                    if let err = err {
                        print("error")
                        completion(.failure(err))
                    } else {
                        print("ok")
                        completion(.success(()))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func downloadImage(fromURL url: String, completion: @escaping (UIImage?) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: url)
        
        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                print("Ошибка загрузки изображения из Firebase Storage: \(error.localizedDescription)")
                completion(nil)
            } else {
                if let data = data, let image = UIImage(data: data) {
                    completion(image)
                } else {
                    print("Не удалось преобразовать данные из Firebase Storage в изображение")
                    completion(nil)
                }
            }
        }
    }

}


