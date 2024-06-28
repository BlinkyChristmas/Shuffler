// Copyright © 2024 Charles Kerr. All rights reserved.

import Foundation

class Chunk : NSObject {
    @objc dynamic var inputOffset = 0
    @objc dynamic var amount = 0
    @objc dynamic var outputOffset = 0
    @objc dynamic var name:String?
    @objc dynamic var frameLength:Int {
        return outputOffset + amount
    }
    
    init(inputOffset: Int = 0, amount: Int = 0, outputOffset: Int = 0, name: String? = nil) {
        self.inputOffset = inputOffset
        self.amount = amount
        self.outputOffset = outputOffset
        self.name = name
    }
    
    convenience init(element:XMLElement) throws {
        self.init()
        guard element.name?.lowercased() == "chunk" else {
            throw GeneralError(errorMessage: "Element for chunk had incorrect name: \(element.name ?? "")")
        }
        var node = element.attribute(forName: "name")
        self.name = node?.stringValue
        
        node = element.attribute(forName: "inputOffset")
        guard node?.stringValue != nil else {
            throw GeneralError(errorMessage: "Chunk: \(name ?? "") missing inputOffset")
        }
        guard let temp = Int(node!.stringValue!) else {
            throw GeneralError(errorMessage: "Chunk: \(name ?? "") had invalid inputOffset: \(node!.stringValue!)")
        }
        inputOffset = temp
        
        node = element.attribute(forName: "outputOffset")
        guard node?.stringValue != nil else {
            throw GeneralError(errorMessage: "Chunk: \(name ?? "") missing outputOffset")
        }
        guard let temp1 = Int(node!.stringValue!) else {
            throw GeneralError(errorMessage: "Chunk: \(name ?? "") had invalid outputOffset: \(node!.stringValue!)")
        }
        outputOffset = temp1

        node = element.attribute(forName: "byteAmount")
        guard node?.stringValue != nil else {
            throw GeneralError(errorMessage: "Chunk: \(name ?? "") missing byteAmount")
        }
        guard let temp2 = Int(node!.stringValue!) else {
            throw GeneralError(errorMessage: "Chunk: \(name ?? "") had invalid byteAmount: \(node!.stringValue!)")
        }
        amount = temp2

    }
}

extension Chunk : NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        return Chunk( inputOffset: self.inputOffset, amount: self.amount, outputOffset: self.outputOffset, name: self.name)
    }
}

