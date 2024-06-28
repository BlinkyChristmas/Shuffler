// Copyright © 2024 Charles Kerr. All rights reserved.

import Foundation
class ShuffleMusic : NSObject {
    @objc dynamic var musicName:String?
    @objc dynamic var frameCount = 0
    init(musicName: String? = nil, frameCount: Int = 0) {
        self.musicName = musicName
        self.frameCount = frameCount
    }
}

extension ShuffleMusic: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        return ShuffleMusic(musicName: self.musicName, frameCount: self.frameCount)
    }
}
