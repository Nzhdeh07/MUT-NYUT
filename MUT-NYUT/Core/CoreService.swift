import Foundation
import UserNotifications


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
