//
//  ContentView.swift
//  HWS_100_SwiftUI_Project05_WordScramble
//
//  Created by Steve Blythe on 22/01/2021.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var restartGameAlert = false
    @State private var errorMessageAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    @State private var score = 0

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)

                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                Text("Score: \(score)")
                    .font(.title)
            }
            .navigationBarTitle(rootWord)
            .onAppear(perform: startGame)
            .alert(isPresented: $errorMessageAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationBarItems(trailing:
                Button("Restart") {
                    alertTitle = "Are you sure?"
                    alertMessage = "Press Restart to confirm restart or Cancel to continue the current game"
                    restartGameAlert = true
                }.alert(isPresented: $restartGameAlert) {
                    Alert(title: Text(alertTitle), message: Text(alertMessage), primaryButton: .destructive(Text("Restart")) {
                            startGame()
                        }, secondaryButton: .cancel())
                })
        }
    }
    
    func startGame() {
        usedWords.removeAll()
        score = 0
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: ".txt") {
            if let startWords = try? String.init(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: .whitespacesAndNewlines)
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        guard answer.count > 0 else {
            return
        }
        
        guard isLongEnough(word: answer) else {
            wordError(title: "Word too short", message: "Only words longer than 3 characters allowed")
            return
        }
        
        guard isNotRootWord(word: answer) else {
            wordError(title: "That's the root word", message: "Different words to the root word please.")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original.")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not allowed", message: "That word cannot be made from those letters.")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word.")
            return
        }

        usedWords.insert(answer, at: 0)
        
        // Calculate the score for the word
        // = numberOfWords + length
        score += (usedWords.count + newWord.count)
        
        newWord = ""
    }
    
    func isLongEnough(word: String) -> Bool {
        return word.count >= 3
    }
    
    func isNotRootWord(word: String) -> Bool {
        return word != rootWord
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        errorMessageAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
