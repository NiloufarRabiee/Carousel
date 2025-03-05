//
//  rotation mood.swift
//  Carousel rotation
//
//  Created by Niloufar Rabiee on 05/03/25.
//

import SwiftUI

struct RotatingCarouselView: View {
    let items = ["Page 1", "Page 2", "Page 3", "Page 4", "Page 5"]
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            
            TabView {
                ForEach(0..<items.count, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue.opacity(0.8))
                            .frame(width: width * 0.75, height: width * 0.5)
                            .shadow(radius: 5)
                        
                        Text(items[index])
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .bold()
                    }
                    .rotation3DEffect(
                        Angle(degrees: Double((width * 0.5) - geometry.frame(in: .global).midX) / -15),
                        axis: (x: 0, y: 1, z: 0)
                    )
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        }
        .frame(height: 300)
    }
}

struct RotationMood: View {
    var body: some View {
        RotatingCarouselView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CarouselView()
    }
}
