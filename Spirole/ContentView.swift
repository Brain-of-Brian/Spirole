// Spirole will be a game about landmarks

import SwiftUI
import MapKit

enum GameConfig {
    static let WordLength: Int = 5
    static let MaxAttempts: Int = 6
    static let AvaliableLandmarks = ["Petra","Alamo", "Luxor", "Kyoto", "Tulum"].map{$0.uppercased()}
}
struct ContentView: View {
    @State private var Guesses: [String] = Array(repeating: "", count: GameConfig.MaxAttempts)
    @State private var CurrentAttempts = 0
    @State private var GameOver: Bool = false
    @State private var GameWon: Bool = false
    @State private var SecretLandmark = ""
    
    @AppStorage("GamesPlayed") var GamesPlayed = 0
    @AppStorage("GamesWon") var GamesWon = 0
    @State private var InvalidLandmark: Bool = false
    
    @State private var InfoPopup: Bool = false
    @State private var MapPopup: Bool = false
    @State private var SettingsPopup: Bool = false
    
    @AppStorage("Last played") private var LastPlayed: String = ""
    @AppStorage("Saved guesses") private var SavedGuesses: String = ""
    
    let KeyboardRows = [
        ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
        ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
        ["ENTER", "Z", "X", "C", "V", "B", "N", "M", "⌫"]
    ]
    var body: some View {
        return ZStack {
            NavigationStack{
                VStack {
                    VStack{
                        ForEach(0..<GameConfig.MaxAttempts, id: \.self) {Rowindex in
                            HStack(spacing: 8){
                                ForEach(0..<GameConfig.WordLength, id: \.self) {letterindex in
                                    let letter = GetLetter(at: letterindex, InRow: Rowindex)
                                    Text(letter)
                                        .font(.title)
                                        .bold()
                                        .foregroundStyle(.black)
                                        .frame(width: 50, height: 60)
                                        .background(GetTileColor(at: letterindex, InRow: Rowindex, letter: letter))
                                        .cornerRadius(4)
                                        .border(Color.black, width: 1)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                    
                    Spacer()
                    
                    if GameOver {
                        Text(GameWon ? "You discovered \(SecretLandmark)" : "You were so close, the landmark was \(SecretLandmark)")
                            .font(.headline)
                            .foregroundStyle(GameWon ? .green : .red) //temp colors, will decide how to color it later
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack(spacing: 6){
                        ForEach(KeyboardRows, id: \.self){ Row in
                            HStack {
                                ForEach(Row, id: \.self){ Key in
                                    Button {
                                        HandleKeyPress(__: Key)
                                    } label: {
                                        Text(Key)
                                            .font(.headline)
                                            .bold()
                                            .frame(minWidth: Key.count > 1 ? 55: 32, minHeight: 45)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 4)
                                                    .stroke(Color.black, lineWidth: 1))
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 50)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            InfoPopup.toggle()
                        } label: {
                            Image(systemName:"info.circle")
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Text("Spirole")
                            .bold()
                            .font(.title2)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button {
                            MapPopup.toggle()
                        } label: {
                            Image(systemName:"map.fill")
                        }
                            Button {
                                SettingsPopup.toggle()
                            } label: {
                                Image(systemName:"gearshape.fill")
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $InfoPopup) {
                InfoMenu()
                    .presentationDetents([.medium])
                    .presentationCornerRadius(25)
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $MapPopup) {
                MapMenu()
                    .presentationDetents([.medium])
                    .presentationCornerRadius(25)
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $SettingsPopup) {
                SettingsMenu()
                    .presentationDetents([.medium, .large])
                    .presentationCornerRadius(25)
                    .presentationDragIndicator(.visible)
            }
            .alert("This landmark is not avaliable", isPresented: $InvalidLandmark){
                Button{
                    
                } label: {
                    Text( "Okay")
                }
            } message: {
                Text("Please enter an avaliable landmark.\nYou can view avaliable landmarks in the 'landmarks' tab")
            }
            .multilineTextAlignment(.center)
        }
        .onAppear {
            CheckDailyReset()
        }
    }
    func TodayCDT() -> String {
        let Format = DateFormatter()
        Format.dateFormat = "yyyy-MM-dd"
        if let CstZone = TimeZone(identifier: "America/Chicago") {
            Format.timeZone = CstZone
        }
        return Format.string(from: Date())
    }
    func DailySecretLandmark() -> String {
        let landmarks = GameConfig.AvaliableLandmarks
        guard !landmarks.isEmpty else { return "SWIFT"}
        var calendar = Calendar.current
        if let CstZone = TimeZone(identifier: "America/Chicago" ) {
            calendar.timeZone = CstZone
        }
        var components = DateComponents()
        components.year = 2026
        components.month = 1
        components.day = 1
        //these are temp, will change on release
        components.timeZone = calendar.timeZone
        
        guard let StartDate = calendar.date(from: components) else {
            return landmarks[0]
        }
        let today = Date()
        let DayCount = calendar.dateComponents([.day], from: StartDate, to: today).day ?? 0
        let SafeDayCount = max(0, DayCount)
        
        let index = SafeDayCount % landmarks.count
        return landmarks[index]
    }
    func CheckDailyReset(){
        let today = TodayCDT()
        SecretLandmark = DailySecretLandmark()
        
        if LastPlayed == today {
            
            if !SavedGuesses.isEmpty {
                Guesses = SavedGuesses.components(separatedBy: ", ")
            }
            CurrentAttempts = Guesses.filter { !$0.isEmpty }.count
            if Guesses.contains(SecretLandmark) {
                GameWon = true
                GameOver = true
            } else if CurrentAttempts >= GameConfig.MaxAttempts {
                GameOver = true
            }
        }
        else {
            DailyReset()
        }
    }
    func DailyReset() {
        Guesses = Array(repeating: "", count: GameConfig.MaxAttempts)
        CurrentAttempts = 0
        GameOver = false
        GameWon = false
        SavedGuesses = ""
    }
    
    func GetLetter(at index: Int, InRow row: Int) -> String
    {
        let Guess = Guesses[row]
        guard index < Guess.count else { return "" }
        let CharacterIndex = Guess.index(Guess.startIndex, offsetBy: index)
        return String(Guess[CharacterIndex])
    }
    func GetTileColor(at index: Int, InRow row: Int, letter: String) -> Color{
        if row == CurrentAttempts && !GameOver {
            return .clear }
        
        if Guesses[row] == SecretLandmark {
            return .green
        }
        if !letter.isEmpty{
            let CorrectLetter = String(SecretLandmark[SecretLandmark.index(SecretLandmark.startIndex, offsetBy: index)])
            
            if letter == CorrectLetter {
                return .green
                
            }
            else if SecretLandmark.contains(letter) {
            return .yellow
            }
            else {
                return .gray
            }
        }
        return .clear
    }
    func HandleKeyPress(__ key: String ){
        guard !GameOver else { return }
        let CurrentGuess = Guesses[CurrentAttempts]
        
        if key == "⌫" {
            if !CurrentGuess.isEmpty {
                Guesses[CurrentAttempts].removeLast()
            }
        }
        else if key == "ENTER"{
            if CurrentGuess.count == GameConfig.WordLength {
                if GameConfig.AvaliableLandmarks.contains(CurrentGuess.uppercased()) {
                    SubmitGuess()
                }
                else {
                    InvalidLandmark = true
                }
            }
        }
        else { if CurrentGuess.count < GameConfig.WordLength {                     Guesses[CurrentAttempts] += key
            
        }
        }
    }
    func SubmitGuess() {
        let FinalGuess = Guesses[CurrentAttempts]
        
        SavedGuesses = Guesses.joined(separator: ",")
        LastPlayed = TodayCDT()
        
        if FinalGuess == SecretLandmark {
            GameWon = true
            GameOver = true
            GamesPlayed += 1
            GamesWon += 1
            
        }
        else if CurrentAttempts + 1 >= GameConfig.MaxAttempts {
            GameOver = true
            GamesPlayed += 1
        }
        else {
            CurrentAttempts += 1
        }
    }
    func ResetGame(){
        Guesses = Array(repeating: "", count: GameConfig.MaxAttempts)
        CurrentAttempts = 0
        GameOver = false
        GameWon = false
        SecretLandmark = GameConfig.AvaliableLandmarks.randomElement() ?? "SWIFT"
    }
}
#Preview {
    ContentView()
}

struct InfoMenu: View {
    @Environment(\.dismiss) private var Close
    var body: some View {
        NavigationStack {
            VStack{
                Text("What is Spirole?")
                    .font(.title3)
                    .bold()
                Text("Spirole is a game about discovering landmarks through guessing and map discoveries")
                    .multilineTextAlignment(.center)
                    .font(.body)
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button{
                        Close()
                    } label: {
                        Text("Close")
                            .bold()
                            .font(.body)
                    }
                }
            }
        }
    }
}

#Preview {
    InfoMenu()
}

struct MapMenu: View {
    @Environment( \.dismiss) private var Close
    var body: some View {
        NavigationStack {
            Map()
                .navigationTitle("Discovered Landmarks")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Close()
                        } label: {
                            Text("Close")
                                .bold()
                                .font(.body)
                        }
                    }
                }
        }
    }
}

#Preview {
    MapMenu()
}

struct SettingsMenu: View {
    @Environment(\.dismiss) private var Close
    @AppStorage("Increased Contrast") private var IncreasedContrast = false
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Accessibility")) {
                    Toggle("Increase Contrast", isOn: $IncreasedContrast)
                }
                Section(header: Text("About")) {
                    HStack{
                        
                    }
                }
                Section(header: Text("")) {
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    Button{
                        Close()
                    } label:{
                        Text("Close")
                            .bold()
                            .font(.default)
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsMenu()
}
