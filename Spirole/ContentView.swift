// Spirole will be a game about landmarks

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var InfoPopUp: Bool = false
    @State private var MapPopUp: Bool = false
    @State private var SettingsPopUp: Bool = false
    var body: some View {
        ZStack {
            NavigationStack{
                VStack{
                    Text("placeholder")
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
    }
}
#Preview {
    ContentView()
}
