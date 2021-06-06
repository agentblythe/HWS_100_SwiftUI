//
//  ContentView.swift
//  HWS_100_SwiftUI_Project02_GuessTheFlag
//
//  Created by Steve Blythe on 09/01/2021.
//

import SwiftUI

struct ContentView: View {
    
    @State private var showAlert = false
    
    @State private var showingScore = false
    
    @State private var gameOver = false
    
    @State private var scoreTitle = ""
    
    @State private var score = 0
    
    @State private var round = 1
    
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"].shuffled()
    
    @State private var correctAnswer = Int.random(in: 0...2)
    
    let MAX_ROUNDS = 5
    
    @State private var highScore = UserDefaults.standard.integer(forKey: "HighScore")
    
    @State private var rightSpin = Double.zero
    
    @State private var wrongSpin = Double.zero
    
    @State private var opac = 1.0
    
    @State private var endOfRound = false
    
    var body: some View {
        
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.yellow, .white]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                
                VStack {
                    Text("Round: \(round)")
                        .foregroundColor(Color.black)
                        .font(.largeTitle)
                        .fontWeight(.black)
                    
                    Spacer()
                    
                    Text("Tap the flag of")
                        .foregroundColor(Color.black)
                    
                    Text(countries[correctAnswer])
                        .foregroundColor(Color.black)
                        .font(.largeTitle)
                        .fontWeight(.black)
                }
                
                ForEach(0 ..< 3) { number in
                    FlagButton(image: FlagImage(image: countries[number])) {
                        flagTapped(number)
                    }
                    .rotation3DEffect(
                        .degrees(number == correctAnswer ? rightSpin : 0),
                            axis: (x: 0.0, y: 1.0, z: 0.0))
                    .opacity(endOfRound ? (number == correctAnswer ? 1.0 : 0.25) : 1.0)
                    .rotation3DEffect(
                        .degrees(endOfRound && number != correctAnswer ? wrongSpin : 0),
                            axis: (x: 0.0, y: 0.0, z: 1.0))
                }
                
                Text("Score = \(score)")
                    .foregroundColor(Color.black)
                    .font(.headline)
                    .fontWeight(.black)
                
                Text("High Score = \(highScore)")
                    .foregroundColor(Color.gray)
                    .font(.headline)
                    .fontWeight(.black)
                
                Spacer()
            }
        }
        .alert(isPresented: $showAlert) {
            if gameOver {
                return Alert(title: Text("\(scoreTitle)"), message: Text("Game Over: you scored \(score)"), dismissButton: .default(Text("Restart")) {
                    self.restartGame()
                })
            } else {
                return Alert(title: Text(scoreTitle), message: Text(""), dismissButton: .default(Text("Continue")) {
                    self.askQuestion()
                })
            }
        }
    }
    
    func restartGame() {
        if score > highScore {
            UserDefaults.standard.set(score, forKey: "HighScore")
            highScore = score
        }
        round = 0
        score = 0
        askQuestion()
    }
    
    func askQuestion() {
        round += 1
        endOfRound = false
        rightSpin = 0.0
        wrongSpin = 0.0
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
    }
    
    func flagTapped(_ number: Int) {
        endOfRound = true
        
        if number == correctAnswer {
            scoreTitle = "Correct"
            score += 1
            withAnimation(.spring()) {
                rightSpin = 360
                wrongSpin = 0
            }
        } else {
            scoreTitle = "Wrong, you tapped the flag of \(countries[number])"
            score -= 1
            
            chainIncorrectAnimations()
        }
        
        if round + 1 > MAX_ROUNDS {
            gameOver = true
            showingScore = false
        } else {
            showingScore = true
            gameOver = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showAlert = true
        }
    }
    
    func chainIncorrectAnimations() {
        let animation = Animation.linear(duration: 0.05).repeatCount(1, autoreverses: true)
        
        withAnimation(animation) {
            wrongSpin = 20
            rightSpin = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(animation) {
                wrongSpin = -20
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(animation) {
                wrongSpin = 0
            }
        }
    }
}

struct FlagButton: View {
    var image: FlagImage
    var action: () -> ()
    
    var body : some View {
        Button(action: {
            action()
        }, label: {
            image
        })
    }
}

struct FlagImage: View {
    var image: String
    var body: some View {
        Image(image)
            .renderingMode(.original)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.black, lineWidth: 1))
            .shadow(color: .black, radius: 2)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
