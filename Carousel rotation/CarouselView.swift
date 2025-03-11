import SwiftUI

struct Page: Identifiable {
    let id = UUID()
    let number: Int
    let question: String
    let answers: [String]
}

struct CardView: View {
    let page: Page
    let currentIndex: Int
    let onAnswerSelected: (String) -> Void
    
    @State private var selectedAnswer: String? = nil
    @State private var showSelectedAnswer: Bool = false

    var body: some View {
        ZStack {
            cardView(page)
        }
        .modifier(CarouselEffect(index: page.number - 1, currentIndex: currentIndex, translation: 0))
    }
    
    private func cardView(_ page: Page) -> some View {
        ZStack {
            Rectangle()
                .fill(.clear)
                .background(
                    Rectangle()
                        .fill(Material.ultraThinMaterial)
                        .opacity(0.3)
                        .cornerRadius(30)
                        .clipped()
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .strokeBorder(
                            Color.white.opacity(0.2),
                            lineWidth: 0.5
                        )
                        .blur(radius: 0.3)
                )
                .frame(width: 300, height: 350)
                .overlay(
                    GeometryReader { geometry in
                        VStack {
                            Spacer()
                            
                            VStack(spacing: 30) {
                                Text(page.question)
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 30)
                                
                                VStack(spacing: 15) {
                                    ForEach(page.answers, id: \.self) { answer in
                                        Button(action: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                                selectedAnswer = answer
                                                showSelectedAnswer = true
                                            }
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                                onAnswerSelected(answer)
                                            }
                                        }) {
                                            Text(answer)
                                                .font(.system(size: 16))
                                                .foregroundColor(selectedAnswer == answer ? .yellow : .white.opacity(0.8))
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(Material.ultraThinMaterial)
                                                        .opacity(0.2)
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .strokeBorder(Color.white.opacity(0.3), lineWidth: 0.5)
                                                )
                                                .scaleEffect(selectedAnswer == answer ? 1.1 : 1.0)
                                                .padding(.horizontal, 20)
                                        }
                                        .disabled(selectedAnswer != nil)
                                    }
                                }
                                .padding(.bottom, 30)
                                
                                Spacer()
                            }
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .blur(radius: 3)
                        .opacity(0.2)
                        .cornerRadius(30)
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }
}

struct FloatingLeaf: View {
    @State private var isAnimating = false
    let randomOffset: CGFloat
    let randomSize: CGFloat
    let duration: Double
    
    var body: some View {
        Image(systemName: "leaf.fill")
            .foregroundColor(.green.opacity(0.2))
            .font(.system(size: randomSize))
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .offset(x: isAnimating ? randomOffset : -randomOffset,
                    y: isAnimating ? 200 : -50)
            .onAppear {
                withAnimation(
                    Animation
                        .easeInOut(duration: duration)
                        .repeatForever(autoreverses: false)
                ) {
                    isAnimating = true
                }
            }
    }
}

struct LeafField: View {
    var body: some View {
        ZStack {
            ForEach(0..<12) { index in
                FloatingLeaf(
                    randomOffset: CGFloat.random(in: -200...200),
                    randomSize: CGFloat.random(in: 10...25),
                    duration: Double.random(in: 8...15)
                )
                .offset(x: CGFloat.random(in: -150...150))
            }
        }
    }
}

struct CarouselView: View {
    private let pages = [
        Page(number: 1, question: "How do you usually commute?", answers: ["Drive", "Public Transport", "Bike"]),
        Page(number: 2, question: "How often do you eat meat?", answers: ["Daily", "Occasionally", "Vegetarian"]),
        Page(number: 3, question: "Energy use?", answers: ["Inefficiently", "Fairly", "Efficiently"]),
        Page(number: 4, question: "How often do you travel by plane?", answers: ["Several times a year", "Once a year", "Less than once a year"]),
        Page(number: 5, question: "How do you manage household waste?", answers: ["I waste without recycling", "I recycle most of my waste", "I compost and recycle"])
    ]
    
    @State private var currentIndex: Int = 0
    @State private var selectedAnswers: [Int: String] = [:]
    @State private var progressPercentage: Double = 0.0
    
    var body: some View {
        ZStack {
            Color(red: 0, green: 0.12, blue: 0.08)
                .edgesIgnoringSafeArea(.all)
            
            LeafField()
                .offset(y: 200)
                .opacity(0.6)
            
            VStack(spacing: 0) {
                CircularProgressView(progress: progressPercentage)
                    .frame(width: 100, height: 100)
                    .padding(.top, 60)
                
                Spacer()
                
                ZStack {
                    ForEach(Array(zip(pages.indices, pages)), id: \ .0) { index, page in
                        CardView(
                            page: page,
                            currentIndex: currentIndex,
                            onAnswerSelected: { answer in
                                withAnimation {
                                    selectedAnswers[index] = answer
                                    progressPercentage = Double(index + 1) / Double(pages.count)
                                }
                                if currentIndex < pages.count - 1 {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                            currentIndex += 1
                                        }
                                    }
                                }
                            }
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                .padding(.bottom, 50)
            }
        }
    }
}

struct WaveShape: Shape {
    var progress: Double
    var waveHeight: CGFloat = 10
    var phase: Double
    
    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let progressHeight = (1 - progress) * rect.height
        let midy = progressHeight
        
        path.move(to: CGPoint(x: 0, y: midy))
        for x in stride(from: 0, through: rect.width, by: 2) {
            let relativeX = x / rect.width
            let sine = sin(relativeX * .pi * 2 + phase)
            let y = midy + sine * waveHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

struct CircularProgressView: View {
    
    let progress: Double
    @State private var phase = 0.0
    @StateObject var motion: MotionManager = MotionManager()

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 8)
                .opacity(0.3)
                .foregroundColor(.white)
            
            GeometryReader { geometry in
                ZStack {
                    WaveShape(progress: progress, waveHeight: 5, phase: phase)
                        .fill(Color(red: 0.2, green: 0.6, blue: 0.9).opacity(0.8))
                        .rotation3DEffect(.init(radians: .pi), axis: (motion.fx/2, motion.fy/2, 0))
                    
                    WaveShape(progress: progress, waveHeight: 5, phase: phase + .pi)
                        .fill(Color(red: 0.1, green: 0.4, blue: 0.8).opacity(0.6))
                        .rotation3DEffect(.init(radians: .pi), axis: (motion.fx/2, motion.fy/2, 0))
                }
            }
            .clipShape(Circle())
            .onAppear {
                withAnimation(
                    .linear(duration: 2)
                    .repeatForever(autoreverses: false)
                ) {
                    phase += .pi * 2
                }
            }
            
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.2), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("\(Int(progress * 100))%")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

struct CarouselEffect: ViewModifier {
    let index: Int
    let currentIndex: Int
    let translation: CGFloat
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(Double(index - currentIndex) * 20),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.5
            )
            .offset(x: CGFloat(index - currentIndex) * 300 + translation)
            .opacity(index == currentIndex ? 1 : 0.5)
            .scaleEffect(index == currentIndex ? 1 : 0.8)
            .zIndex(index == currentIndex ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentIndex)
    }
}

struct CarouselView_Previews: PreviewProvider {
    static var previews: some View {
        CarouselView()
    }
}

import CoreMotion

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    
    var fx: CGFloat = 0
    var fy: CGFloat = 0
    var fz: CGFloat = 0
    
    var dx: Double = 0
    var dy: Double = 0
    var dz: Double = 0
    
    init() {
        motionManager.startDeviceMotionUpdates(to: .main) { data, error in
            guard let newData = data?.gravity else { return }
            
            self.dx = newData.x
            self.dy = newData.y
            self.dz = newData.z
            
            self.fx = CGFloat(newData.x)
            self.fy = CGFloat(newData.y)
            self.fz = CGFloat(newData.z)
            
            self.objectWillChange.send()
        }
    }
    
    func shutdown() {
        motionManager.stopDeviceMotionUpdates()
    }
}
