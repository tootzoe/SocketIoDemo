//
//  TBtnExtension.swift
//  SocketIoDemo
//
//  Created by thor on 25/4/24
//  
//
//  Email: toot@tootzoe.com  Tel: +855 69325538 
//
//



import SwiftUI


struct TBtnAnchorPtPrefData: Equatable {
    let btnId : Int
    let centerPt :  CGPoint
}

struct TBtnAnchorPtPrefKey : PreferenceKey {
    
    typealias Value = [TBtnAnchorPtPrefData]
    static var defaultValue: [TBtnAnchorPtPrefData] = []
    
    static func reduce(value: inout [TBtnAnchorPtPrefData], nextValue: () -> [TBtnAnchorPtPrefData]) {
        value.append(contentsOf:  nextValue())
    }
}


extension View {
    
    public func keepAnchorPoints (btnId : Int ) ->some View {
        background {
            GeometryReader{ geo in
                let fr = geo.frame(in: .global)
                Color.red.preference(key: TBtnAnchorPtPrefKey.self, value: [TBtnAnchorPtPrefData(btnId: btnId, centerPt: CGPoint(x: fr.midX, y: fr.midY)) ])
            }
        }
        
    }
    
    public func fetchAnchorPts(btnId : Int ,     _ ptsLs : Binding< CGPoint >  ) -> some View {
        onPreferenceChange(TBtnAnchorPtPrefKey.self) { prefs in
            DispatchQueue.main.async {
                let p = prefs.first(where: {$0.btnId == btnId})
                ptsLs.wrappedValue = p?.centerPt ?? .zero
                print(ptsLs)
            }
        }
    }
    
}



