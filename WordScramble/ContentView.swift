//
//  ContentView.swift
//  WordScramble
//
//  Created by Bjørn Hoxmark on 06/04/2022.
// TODO: add hint, hvilke ord mangler?
// Kanskje legge til en animation, rød sirkle som stareter om man har brukt 30 sekunder tenketid. 
//

import SwiftUI

struct ContentView: View {
    @State private var usedWord = [String]()
    @State private var rootWord = "Hello"
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var errorDisplay = false
    

    @State private var score = 0
    
    var body: some View {
        VStack{
            NavigationView {
                List{
                    Section{
                        TextField("Enter your word", text: $newWord).autocapitalization(.none)
                    }
                    Section{
                        ForEach(usedWord, id: \.self) { word in
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                            
                        }
                    }
                }
                .navigationTitle(rootWord)
                .onSubmit(addWord)
                .onAppear(perform: loadFile)
                .toolbar {
                    Button("New", action:startGame)
                }
                .alert(errorTitle, isPresented: $errorDisplay ){
                    Button("OK", role: .cancel){}
                } message: {
                    Text(errorMessage )
                }
            }
            Section{
                Text("Score: \(score)")
            }.padding(5)
        }
    }
    
    func addWord(){
        let w = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard w.count > 2 else {
            wordError(title: "Too Short", message: "must be 3 or more chars")
            return
            
        }
        
        guard isOriginal(word: w) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: w) else {
            wordError(title: "Not a part of root word", message: "Try again")
            return
        }
        
        guard inDict(word: w) else {
            wordError(title: "Word not in dictionary" , message: "Try again")
            return
        }
        
        
        
        
        withAnimation{
            usedWord.insert(w, at: 0)
        }
        
        score += w.count
                
        newWord = ""
    }
    
    
    func startGame(){
        newWord = ""
        loadFile()
        usedWord = [String]()
        score = 0
    }
    
    
    func isPossible(word: String)->Bool{
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    
    func isOriginal(word: String)->Bool{
        return !usedWord.contains(word)
    }
    
    func inDict(word:String)->Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let missSpelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        let allgood = missSpelledRange.location == NSNotFound
        
        if allgood{
            return true
        } else{
            return false
        }
        
    }
//
    func loadFile(){
        if let fileURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let fileContents = try? String(contentsOf: fileURL){
                //regular string
                
                let allWords = fileContents.components(separatedBy: "\n")
                print(allWords)
                rootWord = allWords.randomElement() ?? "Person"
                return
            }
            
        }
        
        fatalError("Could not load start.txt file")

    }
    
    func wordError(title:String, message:String){
        errorMessage = message
        errorTitle = title
        errorDisplay = true
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
