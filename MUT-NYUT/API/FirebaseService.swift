import Foundation
import MessageKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore


class FirebaseService{
    
    static let shared =  FirebaseService()
    let db = Firestore.firestore()
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
            self.db.collection("users").document(userId!).setData(data)
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
        db.collection("users").whereField("email", isNotEqualTo: email).getDocuments {snap, err in
            if err ==  nil{
                if let docs = snap?.documents{
                    for doc in docs{
                        let data = doc.data()
                        let userId = doc.documentID
                        guard let email = data["email"] as? String else {continue}
                        let displayName = data["name"] as? String ?? email
                        let messageColor = data["messageColor"] as? String
                        let photoURL = data["photoURL"] as? String
                        users.append(User(senderId: userId, email: displayName, displayName: displayName, profileImageURL: photoURL, messageColor: messageColor))
                    }
                }
                completion(users)
            }
        }
    }
    
    func getUser(uid: String, completion: @escaping (User)->()){
        if let uid = Auth.auth().currentUser?.uid {
            db.collection("users").document(uid).getDocument { (document, error) in
                if let data = document?.data(){
                    guard let email = data["email"] as? String else {return}
                    guard let name = data["name"] as? String else {return}
                    guard let photoURL = data["photoURL"] as? String else {return}
                    guard let messageColor = data["messageColor"] as? String else {return}
                    
                    completion(User(senderId: uid, email: email, displayName: name, profileImageURL: photoURL, messageColor: messageColor))
                }
            }
        }
    }
    
    
    func getAllMessage(chatId: String,  completion: @escaping ([Message])->()){
        if (Auth.auth().currentUser?.uid) != nil {
            db.collection("conversations/" + chatId + "/messages").order(by: "date", descending: false).addSnapshotListener { (snapshot, error) in
                guard let messagesDocuments = snapshot?.documents else {return}
                
                var msgs = [Message]()
                for doc in messagesDocuments{
                    let data = doc.data()
                    guard let text = data["text"] as? String else {continue}
                    guard let senderId = data["sender"] as? String else {continue}
                    let date = data["date"] as! Timestamp
                    let sentDate = date.dateValue()
                    let messageId = doc.documentID
                    
                    let sender = User(senderId: senderId, email: "")
                    msgs.append(Message(sender: sender, messageId: messageId, sentDate: sentDate, message: text))
                }
                completion(msgs)
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
                db.collection("users").document(uid).collection("conversations").document(convoId).setData(selfData)
                db.collection("users").document(otherId!).collection("conversations").document(convoId).setData(otherData)
                
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
                
                db.collection("conversations").document(convoId).setData(convoInfo) { err in
                    if let err = err{
                        print(err.localizedDescription)
                    }
                    self.db.collection("conversations").document(convoId).collection("messages").addDocument(data: msg){ err in
                        if err == nil{
                            completion(convoId)
                        }
                    }
                }
            } else {
                let msg: [String: Any] = [
                    "date": Date(),
                    "sender": uid,
                    "text": text
                ]
                
                db.collection("conversations").document(convoId!).collection("messages").addDocument(data: msg) { err in
                    if err == nil{
                        completion(convoId!)
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
                self.db.collection("conversations").document(convoId).collection("messages").addDocument(data: msg) { err in
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
    
    
    func getConvoId(otherId: String, completion: @escaping (String)->()){
        if let uid = Auth.auth().currentUser?.uid{
            let ref = db
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
    
    func getChatPhoto(chatId: String, completion: @escaping (UIImage)->()){
        db.collection("conversations").document(chatId).collection("messages").getDocuments { (snapshot, error) in
            guard let messagesDocuments = snapshot?.documents else { return }
            for document in messagesDocuments{
                let data = document.data()
                if let photoURL = data["photoURL"] as? String, let imageURL = URL(string: photoURL) {
                    URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                        if let data = data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                completion(image)
                            }
                        } else {
                            print("Error downloading image: \(error.debugDescription)")
                        }
                    }.resume()
                }
            }
        }
    }
    
    func listenForUserMessagesInBackground() {
        let db = Firestore.firestore()
        db.collection("conversations").getDocuments { (snapshot, error) in
            if let error = error {
                print("Ошибка при получении снимка данных: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot else {
                print("Снимок данных отсутствует")
                return
            }
            
            for document in snapshot.documents {
                let conversationId = document.documentID
                let messagesRef = db.collection("conversations/\(conversationId)/messages")
                
                messagesRef.order(by: "date", descending: false).addSnapshotListener { (messagesSnapshot, messagesError) in
                    guard let messagesSnapshot = messagesSnapshot else {
                        print("Ошибка при получении снимка данных о сообщениях: \(messagesError?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    for change in messagesSnapshot.documentChanges {
                        let doc = change.document
                        let data = doc.data()
                        if let text = data["text"] as? String {
                            scheduleNotification(text: text)
                        } else if data["photoURL"] is String {
                            scheduleNotification(text: "Вы получили фотографию")
                        }
                    }
                }
            }
        }
    }
    
}


