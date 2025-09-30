import SwiftUI

struct DetailSheetView: View {
    let details: [DetailItem]
    @EnvironmentObject var language: AppLanguage
    
    var body: some View {
        NavigationView {
            List {
                ForEach(details.sorted(by: { $0.key.th < $1.key.th }), id: \.key.th) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(language.localized(item.key.th, item.key.en))
                            .font(.headline)
                            .foregroundColor(.purple)
                        Text(language.localized(item.value.th, item.value.en))
                            .font(.body)
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle(language.localized("รายละเอียด", "Details"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

