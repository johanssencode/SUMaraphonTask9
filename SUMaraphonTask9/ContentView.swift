//
//  ContentView.swift
//  SUMaraphonTask9
//
//  Created by A.J. on 27.12.2024.
//

/*
 Два круга друг на друге. На верхнем круге иконка cloud.sun.rain.fill и его можно двигать по экрану.
 
 - Круг вытягивается из нижнего круга как капля.
 - Когда отпускаем круг, он возвращается в центр с инерцией.
 - Круг в центре - желтый, а который вытянули - красный.
 */

import SwiftUI

struct Droplet: View {
    
    // Основные параметры
    let circleSize: CGFloat = 100
    let blurRadius: CGFloat = 30
    let symbolSize: CGFloat = 30
    
    // Параметры анимации при возврате
    let springResponse: CGFloat = 0.6
    let springDamping: CGFloat = 0.7
    
    let gradient: [Color]
    let symbol: String
    
    @State var dragOffset = CGSize.zero
    @State var baseLocation: CGPoint
    
    init(
        gradient: [Color] = [.yellow.opacity(0.9), .red.opacity(0.9)],
        symbol: String = "cloud.sun.rain.fill",
        location: CGPoint = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
    ) {
        
        self.gradient = gradient
        self.symbol = symbol
        self._baseLocation = State(initialValue: location)
        
    }
    
    var body: some View {
        
        ZStack {
            
            Color(.black) // Фон
            
            Rectangle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: gradient),
                        center: .center,
                        startRadius: 50,
                        endRadius: 100
                    )
                )
                .mask {
                    
                    Canvas { context, size in
                        
                        // эффект
                        context.addFilter(.alphaThreshold(min: 0.5, color: .white))
                        context.addFilter(.blur(radius: blurRadius))
                        
                        // Получаем ссылки на наши круги (формы)
                        // Первый круг - неподвижный, второй двигаем двигать
                        let circle1 = context.resolveSymbol(id: 0)!
                        let circle2 = context.resolveSymbol(id: 1)!
                        
                        // рисуем два круга
                        context.drawLayer { context in
                            
                            context.draw(circle1, at: baseLocation)
                            context.draw(circle2, at: baseLocation)
                            
                        }
                        
                    } symbols: {
                        
                        // Основной круг
                        Circle()
                            .frame(width: circleSize)
                            .tag(0)
                        
                        // Перетаскиваемый круг
                        Circle()
                            .frame(width: circleSize)
                            .offset(dragOffset)
                            .tag(1)
                        
                    }//: Canvas > symbols
                    
                }//: mask
                .overlay {
                    
                    // Иконка
                    Image(systemName: symbol)
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: symbolSize, weight: .medium))
                        .foregroundStyle(.white)
                        .shadow(radius: 2)
                        .offset(dragOffset)
                        .gesture(dragGesture)
                    
                }//:overlay
            
        }//:ZStack
        .ignoresSafeArea()
        
    }//:body
    
    private var dragGesture: some Gesture {
        
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                
                withAnimation(.smooth) {
                    dragOffset = value.translation
                }
                
            }
            .onEnded { _ in
                withAnimation(.spring(response: springResponse,
                                      dampingFraction: springDamping)) {
                    dragOffset = .zero
                }
            }
        
    }//:dragGesture
    
}

#Preview {
    Droplet()
}
