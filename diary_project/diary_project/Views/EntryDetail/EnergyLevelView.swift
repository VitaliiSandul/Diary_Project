import SwiftUI

struct EnergyLevelView: View {
    @Binding var diaryEntry: Diary
    
    var body: some View {
        VStack {
            HStack {
                Text("Energy: ")
                    .bold()
                Image(systemName: "\(diaryEntry.energyIcon())")
                Text("\(Int(diaryEntry.energy.rounded())) %")
                Spacer()
            }
            .padding(.leading, 24.0)
            .padding(.top, 10)
            
            Slider(value: $diaryEntry.energy, in: 0...100)
                .padding(.horizontal, 24)
        }
        
    }
}

#Preview {
    @Previewable
    @State var diaryEntry: Diary = Diary(
        date: Date(),
        textContent: "Some text for diary entry.",
        mood: .normal,
        energy: 78.5
    )
    
    EnergyLevelView(diaryEntry: $diaryEntry)
}
