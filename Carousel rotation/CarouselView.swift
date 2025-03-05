//
//  ContentView.swift
//  Carousel rotation
//
//  Created by Niloufar Rabiee on 05/03/25.
//

import SwiftUI


struct Page: Identifiable {
    let id = UUID()
    let number: Int
}


struct CardView: View {
    let page: Page
    let currentIndex: Int
    
    private var isActive: Bool {
        page.number == currentIndex + 1
    }
    
    private var relativePosition: Int {
        page.number - (currentIndex + 1)
    }
    
    var body: some View {
        VStack(spacing: -8) {
           
            cardView(page)
                .overlay(reflectionOverlay())

        }
        .modifier(CarouselEffect(index: page.number - 1, currentIndex: currentIndex, translation: 0))
    }
    
    private func cardView(_ page: Page) -> some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .cornerRadius(30)
                .background(
                    Rectangle()
                        .fill(Color(red: 0, green: 0.1, blue: 0.05).opacity(0.6))
                        .cornerRadius(20)
                        .blur(radius: 10)
                )
                .frame(width: 280, height: 400)
                .overlay(
                    Text("\(page.number)")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                )
                .shadow(color: .white.opacity(0.2), radius: 50, x: -10, y: -10)
                .shadow(color: .black.opacity(0.5), radius: 15, x: 10, y: 10)
        }
    }
    
    private func reflectionOverlay() -> some View {
        LinearGradient(
            colors: [.white.opacity(0.0), .white.opacity(0)],
            startPoint: .top,
            endPoint: .center
        )
    }
    
    private func reflectionMask() -> some View {
        LinearGradient(
            colors: [.white.opacity(0.4), .clear],
            startPoint: .top,
            endPoint: .center
        )
    }
}


struct CarouselView: View {
 
    private let pages = (1...5).map { Page(number: $0) }
    
 
    @State private var currentIndex: Int = 2
    @GestureState private var translation: CGFloat = 0
    @State private var rotation: Double = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
              
                Color(red: 0, green: 0.1, blue: 0.05)
                    .edgesIgnoringSafeArea(.all)
                
              
                ZStack {
                    ForEach(Array(zip(pages.indices, pages)), id: \.0) { index, page in
                        CardView(page: page, currentIndex: currentIndex)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
       
                HStack {
                   
                }
                .padding(.horizontal, 40)
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .gesture(
            DragGesture()
                .updating($translation) { value, state, _ in
                    state = value.translation.width
                }
                .onEnded { value in
                    let offset = value.translation.width
                    let progress = offset / 100
                    let newIndex = Int((CGFloat(currentIndex) - progress).rounded())
                    currentIndex = max(min(newIndex, pages.count - 1), 0)
                }
        )
    }
    
   
    private func nextPage() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            currentIndex = (currentIndex + 1) % pages.count
        }
    }
    
    private func previousPage() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            currentIndex = (currentIndex - 1 + pages.count) % pages.count
        }
    }
}


struct CarouselEffect: ViewModifier {
    let index: Int
    let currentIndex: Int
    let translation: CGFloat
    
    private var rotation: Double {
        Double(index - currentIndex) * 20 + Double(translation / 150.0 * 20.0)
    }
    
    private var offset: CGFloat {
        CGFloat(index - currentIndex) * 300 + translation
    }
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.5
            )
            .offset(x: offset)
            .opacity(index == currentIndex ? 1 : 0.5)
            .scaleEffect(index == currentIndex ? 1 : 0.8)
            .zIndex(index == currentIndex ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentIndex)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: translation)
    }
}

#Preview {
    CarouselView()
}
