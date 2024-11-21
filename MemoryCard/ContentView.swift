//
//  ContentView.swift
//  MemoryCard
//
//  Created by Sandro Lopes on 26/02/24.
//
import SwiftUI

private var fourColumnGrid = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
// Definindo a classe Card, que representa uma carta no jogo
class Card: Identifiable, ObservableObject {
    var id = UUID()
    @Published var isFaceUp = false
    @Published var isMatched = false
    var content: String

    init(content: String) {
        self.content = content
    }
}

// Definindo a estrutura ContentView, que representa a tela principal do jogo
struct ContentView: View {
    // State para armazenar as cartas do jogo
    @State private var cards = createMemoryGame()
    @State private var isGameOver = false
    var body: some View {
        VStack {
            HStack{Text("Jogo da Memória")
                    .font(.title)
                    .foregroundColor(.blue)
                    .padding()
                
            }
            // Exibindo as cartas em uma grade usando a estrutura Grid
           GeometryReader { geo in
                VStack {
                    LazyVGrid(columns: fourColumnGrid, spacing: 10) {
                        ForEach(cards) { card in
                            CardView(card: card )
                                .onTapGesture {
                                    withAnimation {
                                        choose(card)
                                    }
                                }
                        }
                       
                    }
                  
                }
                .foregroundColor(.red)
                .padding()
                .aspectRatio(2/3, contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }
           
        }
        
        if isGameOver == true {
            Button(action: {
                novojogo()
                
            }
                   
            ) {
                Text("JOGAR NOVAMENTE")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            .disabled(!isGameOver)
            
        }
    }

       
    
    // Função para tratar a escolha de uma carta
    func choose(_ card: Card) {
        if let chosenIndex = cards.firstIndex(where: { $0.id == card.id }),
           !cards[chosenIndex].isFaceUp, !cards[chosenIndex].isMatched {
            if let potentialMatchIndex = cards.firstIndex(where: { $0.isFaceUp && !$0.isMatched }) {
                if cards[chosenIndex].content == cards[potentialMatchIndex].content {
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                    
                    SoundManager.instance.playSound(sound: .dabum)
                    // Verifica se todas as cartas foram combinadas
                    if cards.allSatisfy({ $0.isMatched }) {
                                           isGameOver = true
                                       }
                } else {
                    cards[chosenIndex].isFaceUp = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        cards[chosenIndex].isFaceUp = false
                        cards[potentialMatchIndex].isFaceUp = false
                    }
                }
            } else {
                cards[chosenIndex].isFaceUp = true
            }
        }
    }
   
    //recomeça jogo
    func novojogo(){
             cards = ContentView.createMemoryGame()
                isGameOver = false
    }

    // Função para criar o jogo de memória com emojis
    static func createMemoryGame() -> [Card] {
     //   let emojis = ["🐱", "🐭", "🐹","🙊"]
     
       
         
         let emojis = ["🐱", "🐭", "🐹", "🦊", "🐻", "🐨", "🐼", "🐰",
                      "🐮", "🐷", "🐸", "🐵", "🙈", "🙉", "🙊"]
         
       
         
        
        var cards = [Card]()

        // Criando pares de cartas com emojis
        for emoji in emojis {
            cards.append(Card(content: emoji))
            cards.append(Card(content: emoji))
        }

        // Embaralhando as cartas
        return cards.shuffled()
        
    }
}

// Definindo a estrutura CardView, que representa a visualização de uma carta
struct CardView: View {
    @ObservedObject var card: Card

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Exibindo a face da carta se estiver virada para cima ou se já foi combinada
                if card.isFaceUp || card.isMatched {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .opacity(card.isMatched ? 0 : 1)
                    Text(card.content)
                        .font(.system(size: 200))
                        .minimumScaleFactor(0.01)
                        .aspectRatio(1, contentMode: .fit)
                        .rotationEffect(.degrees(card.isMatched ? 360 : 0))
                        .animation(.easeOut(duration: 1), value: card.isMatched)
                } else {
                    // Exibindo a parte de trás da carta
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue)
                }
            }
            .font(Font.system(size: fontSize(for: geometry.size)))
        }
        .aspectRatio(2/3, contentMode: .fit)
    }

    // Função para ajustar o tamanho da fonte com base no tamanho da carta
    private func fontSize(for size: CGSize) -> CGFloat {
        min(size.width, size.height) * 0.75
    }
}

// Definindo a estrutura ContentView_Previews para visualização no Canvas
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// Definindo a estrutura Grid para exibir uma grade de itens
struct Grid<Item, ItemView>: View where Item: Identifiable, ItemView: View {
    private var items: [Item]
    private var viewForItem: (Item) -> ItemView

    // Inicializador da estrutura Grid
    init(items: [Item], viewForItem: @escaping (Item) -> ItemView) {
        self.items = items
        self.viewForItem = viewForItem
    }

    // Corpo da View
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible())]) {
            ForEach(items) { item in
                viewForItem(item)
                    
            }
        }
    }
}
