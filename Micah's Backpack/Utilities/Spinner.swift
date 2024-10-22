//
//  Spinner.swift
//  Animation
//
//  Created by eyh.mac on 30.08.2023.
//

import SwiftUI

struct Spinner: View {
    
    let size: CGFloat
    @State var circleStart = 0.17
    @State var circleEnd = 0.325
    @State var rotationDegree: Angle = .degrees(0)
    
    let trackerRotation: Double = 2
    let animationDuration: Double = 0.75
    
    
    var body: some View {

        Circle()
            .trim(from: circleStart, to: circleEnd)
            .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
            .fill(.mbpBlack)
            .rotationEffect(rotationDegree)
            .frame(width: size, height: size)
            .onAppear {
                animateLoader()
                Timer.scheduledTimer(withTimeInterval: (trackerRotation * animationDuration) + animationDuration, repeats: true) { _ in
                    self.animateLoader()
                }
            }
        
       
        
       
    }
    
    
    func getRotationAngle() -> Angle {
        return .degrees(360 * trackerRotation) + .degrees(120)
    }
    
    func animateLoader() {
        withAnimation(.spring(response: animationDuration * 2)) {
            rotationDegree = .degrees(-57.5)
            circleEnd = 0.325
        }
        Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: false) { _ in
            withAnimation(.easeInOut(duration: trackerRotation * animationDuration)){
                self.rotationDegree = self.getRotationAngle()
            }
            
        }
        
        Timer.scheduledTimer(withTimeInterval: animationDuration * 1.25, repeats: false) { _ in
            withAnimation(.easeOut(duration: (trackerRotation * animationDuration) / 2.25)){
                circleEnd = 0.95
            }
            
        }
        
        Timer.scheduledTimer(withTimeInterval: animationDuration * 1.25, repeats: false) { _ in
            rotationDegree = .degrees(47.5)
            withAnimation(.easeInOut(duration: animationDuration)){
                circleEnd = 0.25
            }
            
        }
        
        
    }
}

#Preview {
    Spinner(size: 50)
}
