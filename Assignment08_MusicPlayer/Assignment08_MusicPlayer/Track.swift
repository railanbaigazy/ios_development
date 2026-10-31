import Foundation
import UIKit

struct Track {
    let title: String
    let artist: String
    let audioFileName: String
    let coverImage: UIImage
    
    var resourceName: String {
        (audioFileName as NSString).deletingPathExtension
    }
    
    var resourceExtension: String {
        (audioFileName as NSString).pathExtension
    }
}
