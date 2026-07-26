import SwiftUI

struct TabManager: View {
    @State private var Tab: Int = 0
    @State var InfoPopup: Bool = false
    @State var MapPopup: Bool = false
    @State var SettingsPopup: Bool = false
   
    @State var Guesses: [String] = Array(repeating: "", count: GameConfig.MaxAttempts)
    @State var InfoTab: Int = 0
    
    var body: some View {
        TabView {
            ContentView(Guesses: $Guesses, InfoPopup: $InfoPopup, MapPopup: $MapPopup, SettingsPopup: $SettingsPopup, InfoTab:$InfoTab)
                .tabItem{
                    Text("Spirole")
                        .font(.title3)
                }
            LandmarkTab(InfoTab: $InfoTab, InfoPopup: $InfoPopup, SettingsPopup: $SettingsPopup)
                .tabItem{
                    Text("Landmarks")
                        .font(.title)
                }
            LearningTab(InfoTab:$InfoTab, InfoPopup: $InfoPopup, SettingsPopup: $SettingsPopup)
                .tabItem{
                    Text("Learn")
                        .font(.title)
                }
        }
        .sheet(isPresented: $InfoPopup) {
            InfoMenu(InfoTab: $InfoTab)
        }
        .sheet(isPresented: $MapPopup) {
            MapMenu(GuessedLandmarks: Guesses.filter{!$0.isEmpty})
        }
        .sheet(isPresented: $SettingsPopup) {
            SettingsMenu()
        }
    }
}

#Preview {
    TabManager()
}

extension Color {
    struct MainPalette {
        static let DeepOcean = Color(red: 0/255, green: 48/255, blue: 73/255)
        static let MidOcean = Color(red: 51/255, green: 101/255, blue: 132/255)
        static let SteelBlue = Color(red: 102/255, green: 155/255, blue: 188/255)
        static let CoastalMist = Color(red: 178/255, green: 197/255, blue: 200/255)
        static let ParchmentCream = Color(red: 253/255, green: 240/255, blue: 213/255)
        static let SoftCoral = Color(red: 223/255, green: 129/255, blue: 122/255)
        static let FieryRed = Color(red: 193/255, green: 18/255, blue: 31/255)
        static let CrimsonSpark = Color(red: 156/255, green: 9/255, blue: 16/255)
        static let DeepMaroon = Color(red: 120/255, green: 0/255, blue: 0/255)
        static let MidnightNavy = Color(red: 60/255, green: 24/255, blue: 36/255)
    }
    
    struct SecondaryPalette {
        static let LightMist = Color(red: 239/255, green: 241/255, blue: 237/255)
        static let PaleSage = Color(red: 213/255, green: 216/255, blue: 188/255)
        static let LightSage = Color(red: 188/255, green: 189/255, blue: 139/255)
        static let MossGreen = Color(red: 151/255, green: 154/255, blue: 104/255)
        static let OliveGreen = Color(red: 113/255, green: 119/255, blue: 68/255)
        static let LeafyGreen = Color(red: 84/255, green: 90/255, blue: 50/255)
        static let DeepForest = Color(red: 55/255, green: 61/255, blue: 32/255)
        static let WoodlandMud = Color(red: 87/255, green: 80/255, blue: 57/255)
        static let EarthBrown = Color(red: 118/255, green: 97/255, blue: 83/255)
        static let WarmClay = Color(red: 179/255, green: 169/255, blue: 160/255)
        
        struct SpiroleGame {
            static let Correct = Color(red: 142/255, green: 148/255, blue:  91/255)
            static let Misplaced = Color(red: 120/255, green: 172/255, blue: 204/255)
            static let Wrong = Color(red: 214/255, green: 45/255, blue: 58/255)
            static let Unused = Color(red: 194/255, green: 184/255, blue: 176/255)
            
        }
    }
}
