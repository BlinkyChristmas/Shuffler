// Copyright © 2024 Charles Kerr. All rights reserved.

import Foundation

class Shuffle : NSObject {
    @objc dynamic var shuffleItems = [ShuffleItem]()
    @objc dynamic var frameLength:Int {
        var length = 0
        for shuffleItem in shuffleItems  {
            length = max(length,shuffleItem.frameLength)
        }
        return length 
    }
    init(shuffleItems: [ShuffleItem] = [ShuffleItem]()) {
        self.shuffleItems = shuffleItems
    }
    convenience init(url:URL) throws {
        self.init()
        do {
            let doc = try XMLDocument(contentsOf: url,options: [.documentTidyXML])
            guard let root = doc.rootElement() else { throw GeneralError(errorMessage: "Missing root element")}
            guard root.name?.lowercased() == "shuffle" else {throw GeneralError(errorMessage: "Invalid root element: \(root.name ?? "")") }
            for child in root.elements(forName: "shuffleItem") {
                shuffleItems.append(try ShuffleItem(element: child))
            }
        }
        catch{
            throw GeneralError(errorMessage: "Error processing: \(url.path())", failure: error.localizedDescription)
        }
    }
}
