// 

import Cocoa
import UniformTypeIdentifiers
import AVFoundation
@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!
    @IBOutlet var arrayController:NSArrayController!
    
    @IBOutlet var settingsData:SettingsData!
    
    @objc dynamic var shuffleURL:URL?
    @objc dynamic var outputLocation:URL?
    @objc dynamic var musicNames = [ShuffleMusic]()

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


    @IBAction func selectShuffleFile(_ sender: Any?) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.shuffle]
        panel.directoryURL = settingsData.shuffleDirectory
        panel.prompt = "Select Shuffle File"
        panel.beginSheetModal(for: self.window) { response in
            guard response == .OK, panel.url != nil else { return }
            self.shuffleURL = panel.url
        }
    }
    @IBAction func selectOutputLocation( _ sender: Any?) {
        let panel = NSOpenPanel()
        panel.directoryURL = settingsData.lightDirectory
        panel.canCreateDirectories = true
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.prompt = "Select Light File(s) Destination"
        panel.beginSheetModal(for: self.window) { response in
            guard response == .OK, panel.url != nil else { return }
            self.outputLocation = panel.url
        }

    }
    @IBAction func cancelApplication(_ sender: Any?) {
        self.window.close()
    }
    @IBAction func shuffleData(_ sender: Any?) {
        for input in arrayController.selectedObjects {
            let source = input as! ShuffleMusic
            let outputURL = outputLocation?.appending(path: source.musicName!).appendingPathExtension("light")
            do {
                let shuffler = try Shuffle(url: shuffleURL!)
                let outputFrameLength = shuffler.frameLength
                let frameCount = source.frameCount
                var data = [[UInt8]].init(repeating: [UInt8].init(repeating: 0, count: outputFrameLength), count: frameCount)
                //var outputLightFile = LightFile(frameCount: frameCount, frameLength: outputFrameLength, musicName: source.musicName, framePeriod: 0.037, lightData: [[])
               for shuffle in shuffler.shuffleItems {
                    
                }
            }
            catch {
                
            }
        }
    }
    @IBAction func selectMusic(_ sender: Any?) {
        let panel = NSOpenPanel()
        panel.directoryURL = settingsData.musicDirectory
        panel.allowedContentTypes = [UTType.wav]
        panel.allowsMultipleSelection = true
        panel.beginSheetModal(for: self.window) { response in
            guard response == .OK , !panel.urls.isEmpty else { return }
            var temp = [ShuffleMusic]()
            _ = Task{
                for url in panel.urls {
                    let name = url.deletingPathExtension().lastPathComponent
                    let asset = AVAsset(url: url)
                    var duration = 0.0
                    
                    let timeduration = try? await asset.load(.duration)
                    if timeduration != nil {
                        duration = CMTimeGetSeconds(timeduration!)
                    }
                    let frameCount = Int( (duration / ( Double(BlinkyGlobals.framePeriod) / 1000.0)).rounded())
                    temp.append(ShuffleMusic(musicName: name,frameCount: frameCount))
                }
                self.arrayController.add(contentsOf: temp)
            }
        }
    }
}

