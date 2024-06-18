import Foundation
import LocalAuthentication
import UIKit
import UserNotifications



class AlertHelper {
    static func showAlert(on viewController: UIViewController, title: String, message: String, style: UIAlertController.Style = .alert) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        viewController.present(alertController, animated: true, completion: nil)
    }
}


func scheduleNotification(text: String) {
         let content = UNMutableNotificationContent()
         content.title = "Напоминание"
         content.body = text
         let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
         let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
         UNUserNotificationCenter.current().add(request) { (error) in
             if let error = error {
                 print("Ошибка при добавлении запроса на уведомление: \(error.localizedDescription)")
             }
         }
     }





