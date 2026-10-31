import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    private let tracks = TrackLibrary.tracks
    private var currentIndex = 0
    private var isPlaying = false
    private var player: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAudioSession()
        loadCurrentTrack()
        updateUI()
    }

    @IBAction func playPauseTapped(_ sender: Any) {
        guard let player else {
            reportError("Can't play \"\(tracks[currentIndex].title)\": the audio file failed to load.")
            return
        }
 
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        
        isPlaying.toggle()
        updateUI()
    }
    
    @IBAction func previousTapped(_ sender: Any) {
        changeTrack(by: -1)
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        changeTrack(by: 1)
    }
    
    private func changeTrack(by offset: Int) {
        guard !tracks.isEmpty else { return }
        
        let count = tracks.count
        currentIndex = (currentIndex + offset + count) % count
        let loaded = loadCurrentTrack()
        
        if isPlaying {
            if loaded {
                player?.play()
            } else {
                isPlaying = false
            }
        }
        
        updateUI()
    }
    
    @discardableResult
    private func loadCurrentTrack() -> Bool {
        player?.stop()
        player = nil
        
        guard tracks.indices.contains(currentIndex) else { return false }
        let track = tracks[currentIndex]
        
        guard let url = Bundle.main.url(forResource: track.resourceName, withExtension: track.resourceExtension)
        else {
            reportError("\"\(track.audioFileName)\" is not in the app bundle")
            return false
        }
        
        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            
            newPlayer.delegate = self
            newPlayer.prepareToPlay()
            player = newPlayer
            
            return true
        } catch {
            reportError("Couldn't open \"\(track.audioFileName)\": \(error.localizedDescription)")
            return false
        }
    }
    
    private func updateUI() {
        guard tracks.indices.contains(currentIndex) else { return }
        let track = tracks[currentIndex]
 
        coverImageView.image = track.coverImage
        titleLabel.text = track.title
        artistLabel.text = track.artist
 
        let icon = UIImage(systemName: isPlaying ? "pause.fill" : "play.fill")
        
        playPauseButton.setImage(icon, for: .normal)
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("🛑 Audio session setup failed: \(error)")
        }
    }
    
    private func reportError(_ message: String) {
        print("🛑 \(message)")
 
        guard viewIfLoaded?.window != nil, presentedViewController == nil else { return }
    
        let alert = UIAlertController(title: "Playback error", message: message, preferredStyle: .alert)
    
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ViewController: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.changeTrack(by: 1)
        }
    }
}

