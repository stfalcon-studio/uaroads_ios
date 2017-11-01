//
//  TracksFileManager.swift
//  UARoads_swift
//
//  Created by Roman on 7/26/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation

class TracksFileManager {

    // MARK: Public class funcs
    
//    class func trackData(from track: TrackModel) -> Data? {
//        let trackFilePath = TracksFileManager.pathToTrackFile(with: track.trackID)
//
//        if FileManager.default.fileExists(atPath: trackFilePath.path) == false {
//            if TracksFileManager.writeTrackToFile(track) == false {
//                return nil
//            }
//        }
//
//        guard let trackData = FileManager.default.contents(atPath: trackFilePath.path) else {
//            return nil
//        }
//        guard let gzippedData = TracksFileManager.gzippedData(trackData) else {
//            return nil
//        }
//        return gzippedData
//    }

    class func trackStringData(from track: TrackModel) -> String {
        let trackFilePath = TracksFileManager.pathToTrackFile(with: track.trackID)

        if FileManager.default.fileExists(atPath: trackFilePath.path) == false {
            if TracksFileManager.writeTrackToFile(track) == false {
                return ""
            }
        }

        guard let trackData = FileManager.default.contents(atPath: trackFilePath.path) else {
            return ""
        }
        guard let gzippedData = TracksFileManager.gzippedData(trackData) else {
            return ""
        }
        let base64TrackStr = gzippedData.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))

        return base64TrackStr
    }
    
    class func removeFile(for track: TrackModel) {
        let trackFilePath = TracksFileManager.pathToTrackFile(with: track.trackID)
        
        do {
            try FileManager.default.removeItem(at: trackFilePath)
        } catch {
            pl("remove track file error -> \n\(error)")
        }
    }
    
    class func documentsDirectory() -> URL {
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
        
        let documentsDir: URL = urls.first!
        return documentsDir
    }
    
    
    // MARK: Private funcs
    
    private class func writeTrackToFile(_ track: TrackModel) -> Bool {
        var pitsDataString = ""
        let trackFilePath = TracksFileManager.pathToTrackFile(with: track.trackID)
        
        for pit in track.pits {
            let pitStr = TracksFileManager.pitDataString(pit: pit)
            pitsDataString.append("\(pitStr)")
        }
        
        do {
            try pitsDataString.write(to: trackFilePath,
                                     atomically: false,
                                     encoding: String.Encoding.utf8)
        } catch {
            pl("write pitsDataStr to file error -> \n\(error)")
            return false
        }
        
        return true
    }
    
    private class func tracksDirectoryPath() -> URL {
        let fm = FileManager.default
        
        let dirName = "Tracks"
        let path = self.documentsDirectory().appendingPathComponent(dirName)
        
        if fm.fileExists(atPath: path.absoluteString) == false {
            do {
                try fm.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                pl(error.localizedDescription)
            }
        }
        return path
    }
    
    private class func pathToTrackFile(with fileName: String) -> URL {
        let fileNameComponent = "track-\(fileName).track"
        let trDirectory = TracksFileManager.tracksDirectoryPath()
        let filePath = trDirectory.appendingPathComponent(fileNameComponent)
        
        return filePath
    }
    
    
    private class func gzippedData(_ data: Data) -> Data? {
        return (data as NSData).gzippedData(withCompressionLevel: -1.0) ?? nil
    }
    
    private class func pitDataString(pit: PitModel) -> String {
        let pitValueStr = (pit.value == 0.0) ? "0" : "\(NSString(format: "%.5f", pit.value))"
        let result = "\(pit.time);\(pitValueStr);\(pit.latitude);\(pit.longitude);\(pit.tag);\(pit.horizontalAccuracy);\(pit.speed)#"
        return result;
    }
}
