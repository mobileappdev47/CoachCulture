
import UIKit
import AmazonIVSPlayer

class JoinLiveClassVC: BaseViewController {
    
    private let dateFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
    
    // MARK: IBOutlet
    
    @IBOutlet private var playerView: IVSPlayerView!
    @IBOutlet private var bufferView: UIView!
    @IBOutlet private var bufferSpinnerView: LoadingIndicatorView!
    @IBOutlet private var muteButton: UIButton!
    @IBOutlet private var detailsView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var avatarImageView: UIImageView!
    @IBOutlet private var usernameLabel: UILabel!
    @IBOutlet private var onlineTimerLabel: UILabel!
    @IBOutlet private var shareButton: UIButton!
    @IBOutlet private var likeButton: UIButton!
    @IBOutlet private var topGradientView: UIView!
    @IBOutlet weak var lblClassStarts: PaddingLabel!
    
    // MARK: IBAction
    
    @IBAction func btnBackClick(_ sender: Any) {
        if didEndStreamingBlock != nil {
            didEndStreamingBlock(self.isSuccessfullyJoinned)
        }
        self.popVC(animated: true)
    }
    
    @IBAction private func didTapMute(_ sender: Any) {
        if let player = player {
            toggleMuteStatus(!player.muted)
        }
    }
    
    @objc private func didTapPlayerView() {
        player?.state == .playing ? player?.pause() : player?.play()
    }
    
    // MARK: Application Lifecycle
    
    @objc private func applicationDidEnterBackground(notification: Notification) {
        if player?.state == .playing || player?.state == .buffering {
            pausePlayback()
        }
    }
    
    @objc private func applicationWillEnterForeground(notification: Notification) {
        startPlayback()
    }
    
    private func addApplicationLifecycleObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidEnterBackground(notification:)),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector:
                                                #selector(applicationWillEnterForeground(notification:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    private func removeApplicationLifecycleObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    // MARK: View setup
    
    private var delegate: StreamDelegate?
    var stream : StreamInfo?
    var streamUrl: URL?
    private var gradientTop: CAGradientLayer?
    private var gradientBottom: CAGradientLayer?
    var didEndStreamingBlock: ((_ isSuccessfullyJoinned: Bool) -> Void)!
    var isSuccessfullyJoinned = false
    var isForClassWaiting = true
    var classStartingTime = ""

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblClassStarts.text = classStartingTime
        didSupportAllOrientation = true
        checkMicrophonePermission()
        if !isForClassWaiting {
            self.lblClassStarts.isHidden = true
        } else {
            self.lblClassStarts.isHidden = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DispatchQueue.main.async {
            didSupportAllOrientation = false
            let value = UIInterfaceOrientationMask.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            self.view.layoutIfNeeded()
        }
    }

    func checkMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                self.initialSetupForStreaming()
            } else {
                self.initialSetupForStreaming()
            }
        }
    }
    
    func initialSetupForStreaming() {
        DispatchQueue.main.async {
            self.setup()
            self.startPlayback()
        }
    }
    
    func setup(_ stream: StreamInfo, delegate: StreamDelegate) {
        self.delegate = delegate
        self.stream = stream
    }
    
    private func setup() {
        if stream != nil {
            muteButton.setImage(UIImage(named: "ic_pause"),for: .normal)
            muteButton.tintColor = .white
            bufferSpinnerView.endColor = UIColor.white
            rotateLoadingView()
            
            view.setNeedsLayout()
            view.layoutIfNeeded()
            
            playerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapPlayerView)))
            
            //gradientTop == nil ? gradientTop = appendGradient(to: topGradientView, startAlpha: 0.6, endAlpha: 0) : ()
            //gradientBottom == nil ? gradientBottom = appendGradient(to: detailsView, startAlpha: 0, endAlpha: 0.6) : ()
            
            loadStream()
        }
    }
    
    private func durationString(since: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        if let startDate = isoFormatter.date(from: since) {
            let components = Calendar.current.dateComponents([.minute, .hour, .day], from: startDate, to: Date())
            return dateFormatter.string(from: components) ?? "0m"
        } else {
            return "0m"
        }
    }
    
    private func appendGradient(to view: UIView, startAlpha: CGFloat, endAlpha: CGFloat) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0, green: 0, blue: 0, alpha: startAlpha).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: endAlpha).cgColor
        ]
        gradientLayer.frame = CGRect(origin: view.bounds.origin,
                                     size: CGSize(width: UIScreen.main.bounds.width, height: view.bounds.height))
        view.layer.insertSublayer(gradientLayer, at: 0)
        return gradientLayer
    }
    
    // MARK: - Player
    
    private var player: IVSPlayer? {
        didSet {
            if oldValue != nil {
                removeApplicationLifecycleObservers()
            }
            playerView?.player = player
            if player != nil {
                addApplicationLifecycleObservers()
            }
        }
    }
    
    // MARK: Playback Control
    
    func loadStream() {
        if stream != nil {
            let player: IVSPlayer
            if let existingPlayer = self.player {
                player = existingPlayer
            } else {
                player = IVSPlayer()
                player.delegate = self
                self.player = player
                print("ℹ️ Player initialized: version \(player.version)")
            }
            
            let streamUrl = URL(string: stream?.playbackurl ?? "")
            if let streamUrl = streamUrl, self.streamUrl == nil {
                player.load(streamUrl)
                self.streamUrl = streamUrl
            }
            
            player.muted = true
            pausePlayback()
        }
    }
    
    func startPlayback() {
        player?.play()
    }
    
    func pausePlayback() {
        player?.pause()
    }
    
    // MARK: State
    
    private func updateForState(_ state: IVSPlayer.State) {
        bufferView.isHidden = state != .buffering
        if state == .playing {
            //playerView.backgroundColor = UIColor.black
        }
    }
    
    private func rotateLoadingView() {
        bufferSpinnerView.layer.removeAllAnimations()
        UIView.animate(withDuration: 1, delay: 0, options: [.curveLinear], animations: {
            self.bufferSpinnerView.transform = self.bufferSpinnerView.transform.rotated(by: .pi / 2)
        }) { (finished) -> Void in
            finished ? self.rotateLoadingView() : ()
        }
    }
    
    private func toggleMuteStatus(_ newStatus: Bool) {
        if let player = player {
            player.muted = newStatus
            muteButton.setImage(
                newStatus ? UIImage(named: "ic_pause") : UIImage(named: "ic_play"),
                for: .normal)
            muteButton.tintColor = .white
        }
        player?.state == .playing ? player?.pause() : player?.play()
    }
}

//MARK: - EXTENSION IVSPLAYER DELEGATE

extension JoinLiveClassVC: IVSPlayer.Delegate {
    func player(_ player: IVSPlayer, didChangeState state: IVSPlayer.State) {
        updateForState(state)
        if state == .ended {
            if didEndStreamingBlock != nil {
                didEndStreamingBlock(self.isSuccessfullyJoinned)
                self.popVC(animated: true)
            }
        } else if state == .playing {
            self.isSuccessfullyJoinned = true
        }
    }
    
    func player(_ player: IVSPlayer, didFailWithError error: Error) {
        self.isSuccessfullyJoinned = false
        delegate?.presentError(error, componentName: "Player")
    }
    
    func player(_ player: IVSPlayer, didChangeVideoSize videoSize: CGSize) {
        playerView.videoGravity = player.videoSize.height > player.videoSize.width ? AVLayerVideoGravity.resizeAspectFill : AVLayerVideoGravity.resizeAspect
    }
}

protocol StreamDelegate {
    func presentError(_ error: Error, componentName: String)
    func presentAlert(_ message: String, componentName: String)
    func didTapShare(_ items: [Any])
}

class StreamInfo {
    var map: Map!
    var class_completed = false
    var ingest_endpoint = ""
    var playbackurl = ""
    var started_at = ""
    var streamdata = ""
    
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        class_completed = map.value("class_completed") ?? false
        ingest_endpoint = map.value("ingest_endpoint") ?? ""
        playbackurl = map.value("playbackurl") ?? ""
        started_at = map.value("started_at") ?? ""
        streamdata = map.value("streamdata") ?? ""
    }
}
