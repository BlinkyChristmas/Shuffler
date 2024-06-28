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
    
    var shuffleData:Shuffle?
    
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
            do {
                self.shuffleData = try Shuffle(url: panel.url!)
                self.shuffleURL = panel.url
            }
            catch {
                NSAlert(error: GeneralError(errorMessage: "Unable to process: \(panel.url!.path())", failure: error.localizedDescription)).beginSheetModal(for: self.window)
            }
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
        do {
            for source in arrayController.arrangedObjects as! [ShuffleMusic] {
                //let source = input as! ShuffleMusic
                let outputURL = outputLocation?.appending(path: source.musicName!).appendingPathExtension("light")
                do {
                    let shuffler = try Shuffle(url: shuffleURL!)
                    let outputFrameLength = shuffler.frameLength
                    let frameCount = source.frameCount
                    var data = [[UInt8]].init(repeating: [UInt8].init(repeating: 0, count: outputFrameLength), count: frameCount)
                    for shuffle in shuffler.shuffleItems {
                        try shuffle.shuffle(baseLocation: settingsData.lightDirectory!, outputData: &data, musicName: source.musicName!)
                    }
                    let outputLightFile = LightFile(frameCount: frameCount, frameLength: outputFrameLength, musicName: source.musicName!, framePeriod: 0.037, lightData: data)
                    try outputLightFile.saveTo(url: outputURL!)
                }
                catch {
                    throw GeneralError(errorMessage: "Shuffle Error on \(source.musicName!)", failure: error.localizedDescription)
                }
            }
        }
        catch {
            NSAlert(error: error).beginSheetModal(for: self.window)
        }

    }
    @IBAction func selectMusic(_ sender: Any?) {
        let panel = NSOpenPanel()
        panel.directoryURL = settingsData.musicDirectory
        panel.allowedContentTypes = [UTType.wav]
        panel.allowsMultipleSelection = true
        panel.prompt = "Select Music to Shuffle"
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

