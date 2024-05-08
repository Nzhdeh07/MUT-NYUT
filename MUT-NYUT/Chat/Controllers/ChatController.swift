import UIKit
import Foundation
import MessageKit
import FirebaseAuth
import InputBarAccessoryView


class ChatViewController: MessagesViewController {
    
    var chatId: String?
    var otherId: String?
    var selfSender: User
    var othersender: User
    var messages = [Message]()
    
    let service = FirebaseService.shared
    
    init(othersender: User) {
        selfSender = User(senderId: Auth.auth().currentUser?.uid ?? "", email:Auth.auth().currentUser?.email ?? "",  displayName: "Me")
        self.othersender = othersender
        self.otherId = othersender.senderId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = othersender.displayName
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        showMessageTimestampOnSwipeLeft = true
        
        let sendPhotoButton = InputBarButtonItem()
        sendPhotoButton.image = UIImage(systemName: "camera")
        sendPhotoButton.tintColor = .label
        sendPhotoButton.setSize(CGSize(width: 36, height: 36), animated: false)
        sendPhotoButton.onTouchUpInside { [weak self] _ in
            self?.sendPhotoButtonTapped(sendPhotoButton)
        }
        let galleryImage = UIImage(systemName: "photo")
        let galleryButton = UIBarButtonItem(title: "photo", image: galleryImage, target: self, action: #selector(openGallery))
        // Устанавливаем кнопку в правом верхнем углу навигационного бара
        navigationItem.rightBarButtonItem = galleryButton
        
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 40, animated: true)
        messageInputBar.leftStackView.insertArrangedSubview(sendPhotoButton, at: 0)
        
        
        if chatId == nil{
            service.getConvoId(otherId: otherId!) { [weak self] chatId in
                self?.chatId = chatId
                self?.getMessages(convoId: chatId)
            }
        }
    }
    
    @IBAction func sendPhotoButtonTapped(_ sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {return}
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func openGallery(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Photo", bundle: nil)
        if let view = storyboard.instantiateViewController(withIdentifier: "PhotoController") as? PhotoController {
            navigationController?.pushViewController(view, animated: true)
            view.config(chatId: chatId ?? "")
        }
        
    }
    
    func getMessages(convoId: String){
        service.getAllMessage(chatId: convoId) { [weak self] messages in
            self?.messages = messages
            DispatchQueue.main.async {
                self?.messagesCollectionView.reloadData()
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }
    
    
}


extension ChatViewController: MessagesDisplayDelegate, MessagesLayoutDelegate, MessagesDataSource{
    var currentSender: any MessageKit.SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> any MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return message.sender.senderId == selfSender.senderId ? .white : .darkText
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return message.sender.senderId == selfSender.senderId ? .blue : .lightGray
    }
}


extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let msg = Message(sender: selfSender, messageId: "", sentDate: Date(), message: text)
        messages.append(msg)
        service.sendMessage(otherId: self.otherId, convoId: self.chatId, text: text) {[weak self] convoId in
            DispatchQueue.main.async {
                inputBar.inputTextView.text = nil
                self?.messagesCollectionView.reloadDataAndKeepOffset()
            }
            self?.chatId = convoId
        }
    }
}


extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            let msg = Message(sender: selfSender, messageId: "", sentDate: Date(), image: image)
            messages.append(msg)
            self.messagesCollectionView.reloadDataAndKeepOffset()
            
            picker.dismiss(animated: true){
                self.service.sendMessageWithPhoto(convoId: self.chatId!, senderUid: self.selfSender.senderId, image: image) { result in
                    switch result {
                    case .success:
                        print("Image sent successfully")
                    case .failure(let error):
                        print("Failed to send image: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}



