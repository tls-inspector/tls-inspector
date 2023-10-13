import UIKit
import CertificateKit
import EventKit

public class CertificateReminder {
    /// Try to add a new reminder for a certificate expiry
    /// - Parameters:
    ///   - certificate: The certificate to notify
    ///   - domain: The domain for the certificate
    ///   - daysBeforeExpire: The number of days before expiry
    ///   - completed: Called when added or on error
    public static func addReminder(certificate: CKCertificate, domain: String, daysBeforeExpire: Int, completed: @escaping (Error?) -> Void) {
        let completedBlock = completed
        let store = EKEventStore()

        guard let notAfter = certificate.notAfter else {
            completed(NewError(description: "Certificate does not contain expiry date"))
            return
        }

        let accessCallback: ((Bool, Error?) -> Void) = { granted, error in
            if !granted || error != nil {
                completedBlock(error ?? NewError(description: "Permission Denied"))
                return
            }

            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none

            let reminder = EKReminder(eventStore: store)
            reminder.title = lang(key: "Renew Certificate for {domain}", args: [domain])
            let expiry = formatter.string(from: notAfter)

            reminder.notes = lang(key: "The certificate for {domain} expires on {date}", args: [domain, expiry])
            let days = daysBeforeExpire - (daysBeforeExpire * 2)
            if let alarmDate = Calendar.current.date(byAdding: .day, value: days, to: notAfter) {
                reminder.addAlarm(EKAlarm(absoluteDate: alarmDate))
            }
            reminder.calendar = store.defaultCalendarForNewReminders()
            var saveError: Error?
            do {
                try store.save(reminder, commit: true)
            } catch {
                saveError = error
            }
            completedBlock(saveError)
        }

        if #available(iOS 17, *) {
            store.requestFullAccessToReminders { granted, error in
                accessCallback(granted, error)
            }
        } else {
            store.requestAccess(to: .reminder) { (granted, error) in
                accessCallback(granted, error)
            }
        }
    }
}
