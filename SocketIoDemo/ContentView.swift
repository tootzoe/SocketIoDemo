//
//  ContentView.swift
//  SocketIoDemo
//
//  Created by thor on 21/4/24
//  
//
//  Email: toot@tootzoe.com  Tel: +855 69325538 
//
//



import SwiftUI



struct TTextPerferenceData2 {
    let idx : Int
    let anchors : Anchor<[CGPoint]>
}

struct TTextPerferenceKey2 : PreferenceKey {
    typealias Value = [TTextPerferenceData2]
    
    static var defaultValue: [TTextPerferenceData2] = []
    
    static func reduce(value: inout [TTextPerferenceData2], nextValue: () -> [TTextPerferenceData2]) {
        value.append(contentsOf: nextValue())
    }
     
}




struct ContentView: View {
    
   @ObservedObject var mysocket = TSocketIO.inst
    
    @State private var linePoints: [CGPoint] = [.zero, .zero]
   // @State private var allBtnPoints = [CGPoint](repeating: .zero, count: 9)
    
    
    
    @State private var btnLbStrLs = [String](repeating: "", count: 9)
    
    private let btnsGp = [0...2, 3...5, 6...8 ]
    
    @State private var showWinner = false
    @State private var showResetGameAlert = false
    @State private var winnerStr = ""
    
    @State private var canStart = false
     
     
 
     @State private var currBtnId = -1
    @State private var tmpAnchorPts :  CGPoint = .zero
    @State private var lastTappedBtnCenterPt = CGPoint.zero
    
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                 
                
                HStack {
                    Spacer()
                    Text("Your Name: \(mysocket.name ?? "?")")
                        .font(.title)
                        .bold()
                    Spacer()
                }
                
                Spacer()
                
                Text("Game Status: \(mysocket.gameStatus)")
              
                Spacer()
                
           
                
                ForEach (btnsGp , id: \.self) { ii in
                    Spacer()
                    HStack {
                        ForEach(ii , id: \.self) { jj in
                            TBtnWid2(currIdx: $currBtnId, labelTxt: btnLbStrLs[jj], idx: jj)
                                .disabled(!btnLbStrLs[jj].isEmpty )
                        }
                    }
                    Spacer()
                }
                
                Spacer()
                 
               Text("Network Status:  \(mysocket.networkStatus)")
                    .frame(maxWidth: .infinity , alignment: .center)
                    
            }    .backgroundPreferenceValue(TTextPerferenceKey2.self) { prefLs in
                GeometryReader { geo in
                    let p = prefLs.first(where: {$0.idx == self.currBtnId})
         
                  let pts = p != nil ?  geo[p!.anchors] : [.zero, .zero , .zero]
//                  let tl = pts[0]
//                  let bt = pts[1]
                    
                    if self.currBtnId >= 0 {
                        self.mysocket.allBtnPoints[self.currBtnId] = pts[2]
                    }
                    
                   // print(self.mysocket.allBtnPoints)
                    return Color.clear
                     
                }
            }
            .onChange(of: currBtnId) {
                
                if !canStart {
                    return
                }
                
                let coord:(x: Int, y: Int)
                
                let n =  mysocket.name ?? ""
                
                switch currBtnId {
                case 0:
                    coord = (0, 0)
                    btnLbStrLs[0] = n
                case 1:
                    coord = (0, 1)
                    btnLbStrLs[1] = n
                case 2:
                    coord = (0, 2)
                    btnLbStrLs[2] = n
                case 3:
                    coord = (1, 0)
                    btnLbStrLs[3] = n
                case 4:
                    coord = (1, 1)
                    btnLbStrLs[4] = n
                case 5:
                    coord = (1, 2)
                    btnLbStrLs[5] = n
                case 6:
                    coord = (2, 0)
                    btnLbStrLs[6] = n
                case 7:
                    coord = (2, 1)
                    btnLbStrLs[7] = n
                case 8:
                    coord = (2, 2)
                    btnLbStrLs[8] = n
                default:
                    coord = (-1, -1)
                }
                
                mysocket.socket.emit("playerMove", coord.x, coord.y)
            
                
            }
          
            
            TLineDrawingWid(points: linePoints)
                 .allowsHitTesting(false)
        }
        .onReceive(mysocket.btnCoordTeller) { val in
            // print(val)
           let n =  val.0
            let coord = (val.1 , val.2)
            
            let btnPts = TSocketIO.inst.allBtnPoints
            
            if n == "drawline" {
                linePoints = [btnPts[val.1 ] , btnPts[val.2]]
            }
            
                    switch coord {
                        
                    case (-1 , -1) :
                        winnerStr = n
                        showWinner = true   
                    case (-2 , -2) :
                        
                        Task{ @MainActor in
                            while showWinner {
                                try? await Task.sleep(nanoseconds: 500_000_000)
                            }
                            DispatchQueue.main.async {
                                showResetGameAlert = true
                            }
                            
                        }
                          
                    case (0, 0):
                        btnLbStrLs[0] = n
                    case (0, 1):
                        btnLbStrLs[1] = n
                        
                    case (0, 2):
                        btnLbStrLs[2] = n
                        
                    case (1, 0):
                        btnLbStrLs[3] = n
                       
                    case (1, 1):
                        btnLbStrLs[4] = n
                    case (1, 2):
                        btnLbStrLs[5] = n
                        
                    case (2, 0):
                        btnLbStrLs[6] = n
                        
                    case (2, 1):
                        btnLbStrLs[7] = n
                        
                    case (2, 2):
                        btnLbStrLs[8] = n
                         
                    default:
                        return
                    }
            
        }
        .alert(isPresented: $showResetGameAlert) {
            
            Alert(title:  Text("Play Again?") , message: Text("Do you want to play anothor round?") ,
                  primaryButton: .default(Text("OK"), action: {
                linePoints = [.zero, .zero]
                btnLbStrLs = [String](repeating: "", count: 9)
                mysocket.handleGameReset()
                
            })  , 
                  secondaryButton: .cancel(Text("Cancel"), action: {
               // print("Cancel...")
                mysocket.resetAck?.with(false)
            }) )
        }.overlay  {
            Color.clear.alert(isPresented: $showWinner)  {
                Alert(title: Text(winnerStr))
           }
        }
        .onAppear(){
            Task{ @MainActor in
                
                for ii in 0...8 {
                                        self.currBtnId = ii
                                        try? await Task.sleep(nanoseconds: 1_000_000)
                }
                
                self.currBtnId = -1
                canStart = true
                
//                For  ( 0...8   ){ ii in
//                    self.currBtnId = ii
//                    try? await Task.sleep(nanoseconds: 1_000_000)
//                }
                
               
                
//                DispatchQueue.main.async {
//                    showResetGameAlert = true
//                }
                
            }
        }
        
    }
 
}




struct TBtnWid2 : View {
    
    @Binding var currIdx : Int
     
    let labelTxt : String
    let idx : Int
    
    var body: some View {
        
        let cr = labelTxt.lowercased() == "x" ? Color.blue : Color.green
        
        RoundedRectangle(cornerRadius: 16)
            .foregroundStyle( labelTxt.isEmpty ? Color.white : cr)
            .overlay {
            Text(labelTxt)
                    .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.red)
        }
            .padding(10)
            .anchorPreference(key: TTextPerferenceKey2.self, value: .init([.topLeading, .bottomTrailing , .center]) ){
                  [TTextPerferenceData2(idx: self.idx, anchors:  $0 ) ]
                
            }
            .aspectRatio(contentMode: .fit)
            .frame(width: 100)
            .onTapGesture {
               self.currIdx = self.idx
            }
        
    }
    
}

 


#Preview {
    ContentView()
}
