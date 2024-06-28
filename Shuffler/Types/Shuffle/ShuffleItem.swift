// Copyright © 2024 Charles Kerr. All rights reserved.

import Foundation

class ShuffleItem : NSObject {
    
    @objc dynamic var name: String?
    @objc dynamic var sourceLocation:String?
    @objc dynamic var chunks = [Chunk]()
    var frameLength:Int {
        var length = 0
        for chunk in chunks {
            length = max(length,chunk.frameLength)
        }
        return length
    }
    
    init(name: String? = nil, sourceLocation: String? = nil, chunks: [Chunk] =  [Chunk]()) {
        self.name = name
        self.sourceLocation = sourceLocation
        self.chunks = chunks
    }
    
    convenience init(element:XMLElement) throws {
        self.init()
        guard element.name?.lowercased() == "shuffleitem" else {
            throw GeneralError(errorMessage: "ShuffleItem requested with bad element name: \(element.name ?? "")")
        }
        var node = element.attribute(forName: "name")
        self.name = node?.stringValue
        
        node = element.attribute(forName: "sourceLocation")
        guard node?.stringValue != nil else {
            throw GeneralError(errorMessage: "ShuffleItem: \(name ?? "") missing sourceLocation")
        }
        sourceLocation = node?.stringValue
        
        for child in element.elements(forName: "chunk") {
            chunks.append(try Chunk(element: child))
        }
    }
}
extension ShuffleItem : NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        return ShuffleItem(name: self.name, sourceLocation: self.sourceLocation, chunks: chunks.map{ $0.copy() as! Chunk})
    }
}

extension ShuffleItem {
    func moveData( inData: [UInt8], outData: inout [UInt8]) {
        for chunk in chunks {
            var amount = chunk.amount
            if inData.count < chunk.inputOffset + amount {
                amount = max(inData.count - chunk.inputOffset,0)
            }
            if amount > 0 {
                if outData.count < chunk.outputOffset + amount {
                    amount = max(outData.count - amount,0)
                }
            }
            if amount > 0 {
                outData[chunk.outputOffset..<chunk.outputOffset + amount] = inData[chunk.inputOffset..<chunk.inputOffset+amount]
            }
        }
    }
    func shuffle(baseLocation:URL, outputData: inout [[UInt8]], musicName:String) throws {
        guard let sourceLocation = self.sourceLocation else {
            throw GeneralError(errorMessage: "Shuffle item: \(self.name ?? "") has no valid sourceLocation")
        }
        let lightURL = baseLocation.appending(path: sourceLocation).appending(path: musicName).appendingPathExtension("light")
        do {
            guard lightURL.exist else { throw GeneralError(errorMessage: "File does not exist: \(lightURL.path())")}
            let frameCount = outputData.count
            let inputData = try LightFile(url: lightURL)
            let inputCount = inputData.frameCount
            for frame in 0..<frameCount {
                if frame < inputCount {
                    moveData(inData: inputData.lightData[frame], outData: &outputData[frame])
                }
            }
        }
        catch {
            throw GeneralError(errorMessage: "Error processing shuffleItem: \(self.name ?? "")", failure: error.localizedDescription)
        }
    }
}
