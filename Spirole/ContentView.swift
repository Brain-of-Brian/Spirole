// Spirole will be a game about landmarks

import SwiftUI
import MapKit

enum GameConfig {
    static let WordLength = 5
    static let MaxAttempts = 6
    static let AvaliableLandmarks = ["Petra"].map{$0.uppercased()}
}

enum LandmarkStatus {
    case empty, unused, wrong, misplaced, correct
    
    var BackgroundColor: Color {
        switch self {
            
        case .empty:
            return Color(.gray)
        case .unused:
            return Color(.systemGray5)
        case .wrong:
            return Color(.darkGray)
        case .misplaced:
            return Color(.yellow)
        case.correct:
            return Color(.green)
        }
    }
    var TextColor: Color {
        switch self {
        case .empty:
            return .primary
        case .unused, .correct, .wrong, .misplaced:
            return .white
        }
    }
}
struct ContentView: View {
    @State private var Guesses: [String] = Array(repeating: "", count: GameConfig.MaxAttempts)
    @AppStorage("Current Attempts") private var CurrentAttempts = 0
    @AppStorage("Game over") private var GameOver = false
    @AppStorage("Games Won") private var GameWon = false
    @State private var SecretLandmark = GameConfig.AvaliableLandmarks.randomElement() ?? "SWIFT"
    
    @AppStorage("GammesPlayed") var GamesPlayed = 0
    @AppStorage("GammesWon") var GamesWon = 0
    
    
    @State private var InfoPopUp: Bool = false
    @State private var MapPopUp: Bool = false
    @State private var SettingsPopUp: Bool = false
    
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
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                .navigationViewStyle(.stack)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            InfoPopUp.toggle()
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        
                    }
                    ToolbarItem(placement: .principal) {
                        Text("Spirole")
                            .font(.title2)
                            .bold()
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack{
                            Button {
                                MapPopUp.toggle()
                            } label: {
                                Image(systemName: "map.fill")
                            }
                            Button {
                                SettingsPopUp.toggle()
                            } label: {
                                Image(systemName: "gearshape.fill")
                            }
                        }
                    }
                }
                
            }
            if InfoPopUp {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture {
                        InfoPopUp = false
                    }
                ZStack{
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 100)
                        .ignoresSafeArea()
                    VStack(spacing: 5) {
                        Text("What is Spirole?")
                            .font(.title3)
                            .bold()
                        Text("Spirole is a game about discovering landmarks through guessing and map discoveries")
                            .multilineTextAlignment(.center)
                            .font(.default)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 55)
                    .padding(.vertical, 100)
                }
            }
            if MapPopUp {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture {
                        MapPopUp = false
                    }
                Map()
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .cornerRadius(25)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 80)
            }
            
            if SettingsPopUp {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture {
                        SettingsPopUp = false
                    }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 100)
                        .ignoresSafeArea()
                    VStack {
                        Button {
                            
                        } label: {
                            
                        }
                        Button {
                            
                        } label: {
                            
                        }
                        Button {
                            
                        } label: {
                            
                        }
                    }
                }
            }
            
        }
        
        func GetLetter(at index: Int, InRow row: Int) -> String
        {
            let Guess = Guesses[row]
            guard index < Guess.count else {return ""}
            let CharacterIndex = Guess.index(Guess.startIndex, offsetBy: index)
            return String(Guess[CharacterIndex])
        }
        func GetTileColor(at index: Int, InRow row: Int, letter: String) -> Color{
            if row == CurrentAttempts && !GameOver {
                return Color.clear }
            
            if Guesses[row] == SecretLandmark {
                return .green
            }
                if !letter.isEmpty{
                    let CorrectLetter = String(SecretLandmark[SecretLandmark.index(SecretLandmark.startIndex, offsetBy: index)])
                    
                    if letter == CorrectLetter {
                        return .green
                        
                    }
                    else if CorrectLetter.contains(letter) {
                        return .yellow
                    }
                    else {
                        return .gray
                    }
                }
        return Color.clear
    }
        func HandleKeyPress(__ key: String ){
            guard !GameOver else {return}
            let CurrentGuess = Guesses[CurrentAttempts]
            
            if key == "⌫" {
                if !CurrentGuess.isEmpty {
                    Guesses[CurrentAttempts].removeLast()
                }
            }
            else if key == "ENTER"{
                if CurrentGuess.count == GameConfig.WordLength {
                    SubmitGuess()
                }
            }
            else { if CurrentGuess.count < GameConfig.WordLength {                     Guesses[CurrentAttempts] += key
                
            }
            }
        }
        func SubmitGuess() {
            let FinalGuess = Guesses[CurrentAttempts]
            
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
}
#Preview {
    ContentView()
}
