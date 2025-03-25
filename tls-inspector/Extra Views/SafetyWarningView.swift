import SwiftUI

struct SafetyWarningView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                Text(title).font(.headline)
                    .foregroundStyle(.red)
            }
            Text(message)
                .padding(.top, 2)
                .padding(.bottom, 2)
            Divider()
            Button {
                fatalError("Quickly exiting")
            } label: {
                Label(Localize.quickexit(), systemImage: "arrow.uturn.left")
            }
            .padding(.top, 2)
        }
    }
}
