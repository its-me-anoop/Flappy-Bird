//
//  ContentView.swift
//  Flappy Bird
//
//  Created by Anoop Jose on 04/06/2024.
//

import SwiftUI
import RiveRuntime

struct ContentView: View {
    @ObservedObject var gameModel = GameModel()
    @State private var showingSettings = false // State for settings view
    private var hapticsEnabled: Bool {
        UserDefaults.standard.bool(forKey: "hapticsEnabled")
    }

    var body: some View {
        if hapticsEnabled
        {
            ZStack {
                backgroundView()
                gameContentView()
                if gameModel.isGameOver {
                    gameOverOverlay()
                        .zIndex(4)
                }
                if !gameModel.isGameStarted {
                    gameStartOverlay()
                }
                GroundView(groundOffset: $gameModel.groundOffset, gameModel: gameModel)
            }
            .onTapGesture {
                handleTap()
            }
            
            .sensoryFeedback(.impact, trigger: gameModel.flapToggle)
            .sensoryFeedback(.error, trigger: gameModel.isGameOver)
            .sensoryFeedback(.impact, trigger: gameModel.score)
            .sheet(isPresented: $showingSettings, onDismiss: {
                showingSettings = false
            }) {
                SettingsView()
            }
        }
        
        else
        {
            ZStack {
                backgroundView()
                gameContentView()
                if gameModel.isGameOver {
                    VStack {
                        gameOverOverlay()
                    }
                    .zIndex(2.0)
                        
                }
                else if !gameModel.isGameStarted && !gameModel.isGameOver{
                    VStack {
                        gameStartOverlay()
                    }
                    .zIndex(1.0)
                }
                GroundView(groundOffset: $gameModel.groundOffset, gameModel: gameModel)
            }
            .onTapGesture {
                handleTap()
            }
            
            
            .sheet(isPresented: $showingSettings, onDismiss: {
                showingSettings = false
            }) {
                SettingsView()
            }
        }
    }

    private func backgroundView() -> some View {
        if gameModel.theme == "Earth"{
            return Color.blue.edgesIgnoringSafeArea(.all)
        }
        if gameModel.theme == "Outer Space"{
            return Color.black.edgesIgnoringSafeArea(.all)
        }
        return Color.blue.edgesIgnoringSafeArea(.all)
        
    }

    private func gameContentView() -> some View {
        VStack {
            scoreView()
            Spacer()
            birdAndObstaclesView()
            Spacer()
        }
    }

    private func scoreView() -> some View {
        HStack(alignment: .center) {
            Text("Highest Score \n \(gameModel.highestScore)")
                .font(.custom("December Show", size: 20.0)).fontWeight(.bold).foregroundColor(.white)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(.linearGradient(colors: [
                    .indigo, .black], startPoint: .topLeading, endPoint: .bottomTrailing)))
            Spacer()
            Text("Current Score \n \(gameModel.score)")
                .font(.custom("December Show", size: 20.0)).fontWeight(.bold).foregroundColor(.white)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(.linearGradient(colors: [
                    .orange, .black], startPoint: .topLeading, endPoint: .bottomTrailing)))
        }
        .padding().frame(maxWidth: .infinity, alignment: .top)
        
    }

    private func birdAndObstaclesView() -> some View {
        ZStack {
            BirdView(position: gameModel.birdPosition, gameModel: gameModel)
            ForEach(gameModel.obstacles, id: \.self) { obstacle in
                if obstacle.type == .cloud {
                    CloudView(position: CGPoint(x: obstacle.x, y: obstacle.y), gameModel: gameModel)
                } else if obstacle.type == .tree {
                    TreeView(position: CGPoint(x: obstacle.x, y: obstacle.y), gameModel: gameModel)
                }
            }
        }
    }
    
    private func gameOverOverlay() -> some View {
            VStack(spacing: 30.0) {
                RiveViewModel(fileName: "flying_bird").view()
                    .frame(width: 80, height: 80)
                    blinkyBeak
                gameOver
                HStack {
                    startGameButton
                    commonSettingsButton
                }
                
            }
            .padding(30)
            .background(RadialGradient(colors: [
                .indigo, .purple], center: .top, startRadius: 200.0, endRadius: 10.0))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .zIndex(2.0)
        }

    private func gameStartOverlay() -> some View {
        
            VStack(spacing: 30.0) {
                RiveViewModel(fileName: "flying_bird").view()
                    .frame(width: 80, height: 80)
                    blinkyBeak
                HStack {
                    startGameButton
                    commonSettingsButton
                }
                    
                }
                .padding(30)
                .background(RadialGradient(colors: [
                    .indigo, .purple], center: .top, startRadius: 200.0, endRadius: 10.0))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .zIndex(1.0)
        
    }
    
    private var blinkyBeak: some View {
        LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
            .mask(
                Text("Blinky Beak")
                .font(.custom("Super Boys", size: 50.0)))
            .multilineTextAlignment(.center)
            .shadow(radius: 10)
            
            .frame(width: 300, height: 50)
    }

        private var gameOver: some View {
            LinearGradient(colors: [.red, .yellow], startPoint: .top, endPoint: .bottom)
                .mask(
                    Text("GAME OVER")
                    .font(.custom("Super Boys", size: 30.0)))
                .multilineTextAlignment(.center)
                .shadow(radius: 10)
                
                .frame(width: 300, height: 50)
        }

        private var startGameButton: some View {
            Button(action: {
                gameModel.startGame()
            }) {
                Text("Start Game")
                    .modifier(ButtonStyle(foregroundColor: .black, backgroundColor1: .green, backgroundColor2: .yellow))
            }
        }

    private var commonSettingsButton: some View {
        
        Text("Settings")
            .modifier(ButtonStyle(foregroundColor: .black, backgroundColor1: .brown, backgroundColor2: .gray))
            .onTapGesture {
                showingSettings.toggle()
            }
    }
    private func handleTap() {
        if !gameModel.isGameOver {
            gameModel.flap()
            gameModel.flapToggle.toggle()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// Custom modifier for button styles
struct ButtonStyle: ViewModifier {
    var foregroundColor: Color
    var backgroundColor1: Color
    var backgroundColor2: Color
    
    func body(content: Content) -> some View {
        content
            .font(.custom("Ambery Garden", size: 25.0))
            .fontWeight(.bold)
            .foregroundColor(foregroundColor)
            .padding()
            .background(LinearGradient(colors: [backgroundColor1, backgroundColor2], startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
