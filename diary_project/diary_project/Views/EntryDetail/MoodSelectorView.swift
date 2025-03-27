import SwiftUI

struct MoodSelectorView: View {
    @Binding var selectedMood: Diary.Mood
    let moodItems: [Diary.Mood]
    
    var body: some View {
        HStack {
            
            ForEach(moodItems, id: \.self) { mood in
                Text(mood.rawValue.first?.description ?? "")
                    .padding(5)
                    .background(Color.white.opacity(mood == selectedMood ? 0.5 : 0.0))
                    .cornerRadius(10)
                    .onTapGesture {
                        selectedMood = mood
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(3)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(10)
        .padding(.horizontal, 24.0)
    }
}

#Preview {
    MoodSelectorView(selectedMood: .constant(Diary.Mood.okey),
                     moodItems: Diary.Mood.allCases)
}
