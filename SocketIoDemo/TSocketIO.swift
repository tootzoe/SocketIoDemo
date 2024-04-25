//
//  TSocketIO.swift
//  SocketIoDemo
//
//  Created by thor on 21/4/24
//  
//
//  Email: toot@tootzoe.com  Tel: +855 69325538 
//
//



import Foundation
import SwiftUI
import Combine

import SocketIO



class TSocketIO: ObservableObject {
    
    static public let inst = TSocketIO()
    
        // let manager = SocketManager(socketURL: URL(string: "http://localhost:8900")!, config: [.log(true), .compress])
    let manager = SocketManager(socketURL: URL(string: "http://192.168.1.178:8900")!, config: [.log(true), .compress])
   
    
    var socket:SocketIOClient!
   
    var resetAck: SocketAckEmitter?
    
    @Published  var name: String?
    @Published  var networkStatus  = "Disconnected...."
    @Published  var gameStatus  = "Waiting for Opponent...."
    
    @Published private var linePoints: [CGPoint] = [.zero, .zero]
 
    let btnCoordTeller = PassthroughSubject< (String, Int,Int) , Never >()
    
    public var allBtnPoints = [CGPoint](repeating: .zero, count: 9)
    
     
//    
//    public var btnColor : Color {
//        name?.lowercased() == "x" ? Color.blue : Color.green
//    }
//    
    
    private init(){
        socket = manager.defaultSocket
        addHandlers()
         socket.connect()
        
    }
    
    func addHandlers() {
        
        socket.on(clientEvent: .connect) {data, ack in
            
            self.networkStatus  = "Connected...."
        }
 
        socket.on("startGame") {[weak self] data, ack in
             self?.handleStart()
        }
        
        socket.on("name") {[weak self] data, ack in
            if let name = data[0] as? String {
                    self?.name = name
            }
        }
        
        socket.on("playerMove") {[weak self] data, ack in
            if let name = data[0] as? String, let x = data[1] as? Int, let y = data[2] as? Int {
                self?.btnCoordTeller.send(  (name , x, y))
            }
        }
        
        socket.on("win") {[weak self] data, ack in
            if let name = data[0] as? String, let typeDict = data[1] as? NSDictionary {
               self?.handleWin(name, type: typeDict)
            }
        }
        
        socket.on("draw") {[weak self] data, ack in
           
             self?.handleDraw()
            return
        }
        
        socket.on("currentTurn") {[weak self] data, ack in
            if let name = data[0] as? String {
                 self?.handleCurrentTurn(name)
                
            }
        }
        
        socket.on("gameReset") {[weak self] data, ack in
            guard let self = self else { return }
            self.resetAck = ack
            btnCoordTeller.send(( "gameReset......" , -2, -2))
        }
        
        socket.on("gameOver") { [weak self]  data, ack in
            self?.gameStatus = ("gameOver......")
            
          //  exit(0)
        }
        
        socket.onAny {print("Got event: \($0.event), with items: \($0.items!)")}
    }
    
    
    func handleStart() {
        if name == "X" {
           gameStatus = ("Your turn!")
        } else {
            gameStatus = ("Opponents turn!")
        }
    }
     
    
    func handleCurrentTurn(_ name: String) {
        if name == self.name! {
             gameStatus = ( "Your turn!" )
        } else {
            gameStatus = ("Opponents turn!" )
        }
    }
    
    func handleDraw() {
        gameStatus = ( "Draw!")
    }
    
    
    func handleWin(_ name: String, type: NSDictionary) {
        gameStatus =  ("Player \(name) won!")
        drawWinLine(type)
        btnCoordTeller.send(( gameStatus , -1, -1))
    }
    
    func handleGameReset() {
        resetAck?.with(true)
        gameStatus = "Waiting for Opponent...."
    }
    
    
    
    func drawWinLine(_ type: NSDictionary) {
        let winType = type["type"] as! String
        let to: Int
        let from: Int
        
        
        if winType == "row" {
            let row = type["num"] as! Int
            
            switch row {
            case 0:
                
                to = 2 // btn2.center
                from = 0 // btn0.center
            case 1:
                to = 3 // btn3.center
                from = 5 // btn5.center
            case 2:
                to = 6 // btn6.center
                from = 8 // btn8.center
            default:
                to = 0 // CGPoint(x: 0.0, y: 0.0)
                from = 0 // CGPoint(x: 0.0, y: 0.0)
            }
        } else if winType == "col" {
            let row = type["num"] as! Int
            
            switch row {
            case 0:
                to = 6 // btn6.center
                from = 0 // btn0.center
            case 1:
                to = 7 // btn7.center
                from = 1 // btn1.center
            case 2:
                to = 2 // btn2.center
                from = 8 // btn8.center
            default:
                to = 0 // CGPoint(x: 0.0, y: 0.0)
                from = 0 // CGPoint(x: 0.0, y: 0.0)
            }
        } else {
            let coord = type["coord"] as! NSDictionary
            let x = coord["x"] as! Int
            let y = coord["y"] as! Int
            
            switch (x, y) {
            case (0, 0):
                to = 8 // btn8.center
                from = 0 // btn0.center
            case (0, 2):
                to = 6 // btn6.center
                from = 2 // btn2.center
            case (2, 2):
                to = 0 // btn0.center
                from = 8 // btn8.center
            case (2, 0):
                to = 2 // btn2.center
                from = 6 // btn6.center
            default:
                to = 0 //  CGPoint(x: 0.0, y: 0.0)
                from = 0 // CGPoint(x: 0.0, y: 0.0)
            }
        }
        
        btnCoordTeller.send(( "drawline" , from, to))
        
   
    }
    
    
}









