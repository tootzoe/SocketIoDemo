//
//  TLineDrawingWid.swift
//  SocketIoDemo
//
//  Created by thor on 21/4/24
//  
//
//  Email: toot@tootzoe.com  Tel: +855 69325538 
//
//



import SwiftUI

struct TLineDrawingWid: View {
   let  points: [CGPoint]
        @State private var colors: [Color] = [Color.purple, Color.cyan, Color.yellow]
    
//    
//    init(colors: [Color]) {
//        self.colors = colors
//    }
//    
    
        
        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    Path { path in
                        if let firstPoint = points.first , firstPoint != .zero {
                            path.move(to: firstPoint)
                            for point in points {
                                path.addLine(to: point)
                            }
                        }
                    }
                    .stroke(LinearGradient(gradient: Gradient(colors: colors), startPoint: .leading, endPoint: .trailing), lineWidth: 5)
                    .background(.clear)
 
                }
            }
        }
}








#Preview {
    EmptyView()
   // TLineDrawingWid()
}
