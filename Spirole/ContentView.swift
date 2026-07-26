// Spirole will be a game about landmarks

import SwiftUI
import MapKit
import CoreLocation

enum GameConfig {
    static let WordLength: Int = 5
    static let MaxAttempts: Int = 6
    static let AvaliableLandmarks = ["Petra","Alamo", "Luxor", "Kyoto", "Tulum"].map{$0.uppercased()}
}
//Tab 1
struct ContentView: View {
    @Binding var Guesses: [String]
    @State private var CurrentAttempts = 0
    @State private var GameOver: Bool = false
    @State private var GameWon: Bool = false
    @State private var SecretLandmark = ""
    
    @AppStorage("GamesPlayed") var GamesPlayed = 0
    @AppStorage("GamesWon") var GamesWon = 0
    @State private var InvalidLandmark: Bool = false
    
    @Binding var InfoPopup: Bool
    @Binding var MapPopup: Bool
    @Binding var SettingsPopup: Bool
    
    @AppStorage("Last played") private var LastPlayed: String = ""
    @AppStorage("Saved guesses") private var SavedGuesses: String = ""
    
    @State private var MapDetent: PresentationDetent = .medium
    
    @Binding var InfoTab: Int

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
                                        HandleKeyPress(_: Key)
                                    } label: {
                                        Text(Key)
                                            .font(.headline)
                                            .foregroundStyle(.black)
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
                            InfoTab = 0
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
            LastPlayed = ""
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
                Guesses = SavedGuesses.components(separatedBy: ",")
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
            
            guard index < SecretLandmark.count else { return .clear }
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
    func HandleKeyPress(_ key: String ){
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
    ContentView(Guesses: .constant(Array(repeating: "", count: GameConfig.MaxAttempts)), InfoPopup: .constant(false), MapPopup: .constant(false), SettingsPopup: .constant(false), InfoTab: .constant(0))
}

struct InfoMenu: View {
    @Environment(\.dismiss) private var Close
    @Binding var InfoTab: Int
    var body: some View {
        NavigationStack {
            VStack{
                if InfoTab == 0 {
                    Text("What is Spirole?")
                        .font(.title3)
                        .bold()
                    Text("Spirole is a game about discovering landmarks through guessing and map discoveries")
                        .multilineTextAlignment(.center)
                        .font(.body)
                }
                else if InfoTab == 1 {
                    Text("Review your landmarks")
                        .font(.title3)
                        .bold()
                }
                else if InfoTab == 2 {
                    Text("Learning info")
                        .font(.title3)
                        .bold()
                }
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
        .presentationDetents([.medium])
        .presentationCornerRadius(25)
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    InfoMenu(InfoTab: .constant(0))
}

struct MapMenu: View {
    @Environment( \.dismiss) private var Close
    @State var Detent: PresentationDetent = .medium
    
    let GuessedLandmarks: [String]
    var DiscoveredPins: [Pin] {
        GuessedLandmarks.compactMap {
            name in
            let upper = name.uppercased()
            if let coordinate = Locations.coordinates[upper] {
                return Pin(name: upper, coordinates: coordinate)
            }
            return nil
        }
    }
    var body: some View {
        NavigationStack {
            Map() {
                ForEach(DiscoveredPins) { pin in
                    Marker(pin.name, coordinate: pin.coordinates)
                }
            }
                .navigationTitle("Discovered Landmarks")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if Detent == .large {
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
        .presentationDetents([.medium, .large], selection: $Detent)
        .presentationCornerRadius(25)
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    MapMenu(GuessedLandmarks: ["Petra", "Luxor"])
}

struct SettingsMenu: View {
    @Environment(\.dismiss) private var Close
    @AppStorage("Increased Contrast") private var IncreasedContrast = false
    @State var Detent: PresentationDetent = .medium
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
                if Detent == .large {
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
        .presentationDetents([.medium, .large], selection: $Detent)
        .presentationCornerRadius(25)
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    SettingsMenu()
}

struct Pin: Identifiable {
    let id = UUID()
    let name: String
    let coordinates: CLLocationCoordinate2D
}

struct Locations {
    static let coordinates: [String: CLLocationCoordinate2D] = [
                "PETRA": CLLocationCoordinate2D(latitude: 30.3285, longitude: 35.4444),
                "ALAMO": CLLocationCoordinate2D(latitude: 29.4260, longitude: -98.4861),
                "LUXOR": CLLocationCoordinate2D(latitude: 25.6989, longitude: 32.6421),
                "KYOTO": CLLocationCoordinate2D(latitude: 35.0116, longitude: 135.7681),
                "TULUM": CLLocationCoordinate2D(latitude: 20.2114, longitude: -87.4654)
    ]
}
// Tab 2
struct LandmarkTab: View {
    @Binding var InfoTab: Int
    @Binding var InfoPopup: Bool
    @Binding var SettingsPopup: Bool
    var body: some View {
        NavigationStack {
            VStack {
                ForEach(GameConfig.AvaliableLandmarks, id: \.self){ Landmark in
                    VStack(spacing: 5) {
                        HStack {
                            Spacer()
                            Text(Landmark)
                                .font(.title3)
                                .padding(.horizontal)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 120)
                        .overlay{
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 2)
                        }
                        .padding(.horizontal)
                    }
                }
            }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            InfoPopup.toggle()
                            InfoTab = 1
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
                                SettingsPopup.toggle()
                            } label: {
                                Image(systemName:"gearshape.fill")
                            }
                        }
                    }
            }
        }
    }
}
#Preview {
    LandmarkTab(InfoTab: .constant(0), InfoPopup: .constant(false), SettingsPopup: .constant(false))
}
// Tab 3
struct LearningTab: View {
    @Binding var InfoTab: Int
    @Binding var InfoPopup: Bool
    @Binding var SettingsPopup: Bool
    var body: some View {
        NavigationStack {
            Text("landmark test")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            InfoPopup.toggle()
                            InfoTab = 2
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
                                SettingsPopup.toggle()
                            } label: {
                                Image(systemName:"gearshape.fill")
                            }
                        }
                    }
                }
            }
    }
}
#Preview {
    LearningTab(InfoTab: .constant(0), InfoPopup: .constant(false), SettingsPopup: .constant(false))
}
