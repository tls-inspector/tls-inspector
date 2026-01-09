// TLS Inspector
// Copyright (C) Ian Spence and other TLS Inspector Contributors
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import SwiftUI
import TLSKit
import EventKit
import Localization

internal enum ReminderError: Error, Sendable {
    case permissionDenied
}

@MainActor
internal final class CertificateReminder {
    public static func add(_ certificate: Certificate, daysBeforeExpire: Int, _ completed: @escaping (Error?) -> Void) {
        let complete = completed
        let store = EKEventStore()

        let accessCallback: ((Bool, Error?) -> Void) = { granted, error in
            if !granted {
                LogWriter.shared.write(.Error, message: "[\(#fileID):\(#line)] Permission was denied to add a reminder")
                complete(ReminderError.permissionDenied)
                return
            }
            if let error = error {
                LogWriter.shared.write(.Error, message: "[\(#fileID):\(#line)] Access error while requesting reminders permission: \(error)")
                complete(error)
                return
            }

            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none

            let reminder = EKReminder(eventStore: store)
            reminder.title = Localize.renewcertificatedomain(domain: certificate.subject.description)
            let expiry = formatter.string(from: certificate.validity.notAfter)

            reminder.notes = Localize.thecertificatedomainexpiresondate(domain: certificate.subject.description, date: expiry)
            let days = daysBeforeExpire - (daysBeforeExpire * 2)
            guard let alarmDate = Calendar.current.date(byAdding: .day, value: days, to: certificate.validity.notAfter) else {
                return
            }
            reminder.addAlarm(EKAlarm(absoluteDate: alarmDate))
            reminder.calendar = store.defaultCalendarForNewReminders()
            var saveError: Error?
            do {
                try store.save(reminder, commit: true)
                LogWriter.shared.write(.Debug, message: "[\(#fileID):\(#line)] Reminder created for certificate \(certificate.subject.description) on \(alarmDate)")
            } catch {
                LogWriter.shared.write(.Error, message: "[\(#fileID):\(#line)] Error adding certificate expiry reminder for \(certificate.subject.description) on \(alarmDate): \(error)")
                saveError = error
            }
            complete(saveError)
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

internal struct AddReminderButton: View {
    public let certificate: Certificate
    public let showAddAlert: Binding<Bool>
    public let showPermissionError: Binding<Bool>
    public let errorMessage: Binding<String?>

    public var body: some View {
        Menu {
            Button(Localize.numbernot1weeks(number_not_1: "2")) {
                self.addReminder(7)
            }
            Button(Localize.n1month()) {
                self.addReminder(30)
            }
            Button(Localize.numbernot1months(number_not_1: "3")) {
                self.addReminder(90)
            }
            Button(Localize.numbernot1months(number_not_1: "6")) {
                self.addReminder(180)
            }
        } label: {
            Label(Localize.addreminderforcertificateexpiry(), systemImage: "calendar")
        }
    }

    internal func addReminder(_ days: Int) {
        CertificateReminder.add(self.certificate, daysBeforeExpire: days) { error in
            guard let error else {
                self.showAddAlert.wrappedValue = true
                return
            }
            if error is ReminderError {
                self.showPermissionError.wrappedValue = true
                return
            }
            self.errorMessage.wrappedValue = error.localizedDescription
        }
    }
}
