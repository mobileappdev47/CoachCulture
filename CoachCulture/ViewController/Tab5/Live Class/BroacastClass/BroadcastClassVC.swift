
import UIKit
import AmazonIVSBroadcast

class BroadcastClassVC: BaseViewController {
    
    // MARK: - Properties

    // UI Outlets
    @IBOutlet private var startButton: UIButton!
    @IBOutlet private var previewView: UIView!
    @IBOutlet private var connectionView: UIView!
    @IBOutlet private var cameraButton: UIButton!
    @IBOutlet private var microphoneButton: UIButton!
    @IBOutlet private var muteButton: UIButton!

    // State management
    var didEndStreamingBlock: ((_ isSuccessfullyJoinned: Bool) -> Void)!

    private var isRunning = false {
        didSet {
            startButton.setTitle(isRunning ? "End" : "Start", for: .normal)
            startButton.backgroundColor = isRunning ? COLORS.ON_DEMAND_COLOR : COLORS.THEME_RED
        }
    }
    
    private var isMuted = false {
        didSet {
            applyMute()
        }
    }
    private var attachedCamera: IVSDevice? {
        didSet {
            cameraButton.setTitle(attachedCamera?.descriptor().friendlyName ?? "None", for: .normal)

            if let preview = try? (attachedCamera as? IVSImageDevice)?.previewView(with: .fill) {
                attachCameraPreview(container: previewView, preview: preview)
            } else {
                previewView.subviews.forEach { $0.removeFromSuperview() }
            }
        }
    }
    private var attachedMicrophone: IVSDevice? {
        didSet {
            microphoneButton.setTitle(attachedMicrophone?.descriptor().friendlyName ?? "None", for: .normal)
            // When a new microphone is attached it has a default gain of 1. This reapplies the mute setting
            // immediately after the new microphone is attached.
            applyMute()
        }
    }

    // This broadcast session is the main interaction point with the SDK
    private var broadcastSession: IVSBroadcastSession?
    var streamObj : StreamInfo?
    var isSuccessfullyJoinned = false

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.initialSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The SDK will not handle disabling the idle timer for you because that might
        // interfere with your application's use of this API elsewhere.
        UIApplication.shared.isIdleTimerDisabled = true

        checkAVPermissions { [weak self] granted in
            if granted {
                if self?.broadcastSession == nil {
                    self?.setupSession()
                }
            } else {
                self?.displayPermissionError()
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }

    // MARK: - User Interaction

    @IBAction private func startTapped(_ sender: UIButton) {
        if isRunning {
            // Stop the session if we're running
            broadcastSession?.stop()
            isRunning = false
            self.classEndedBlock()
            self.popVC(animated: true)
        } else {
            // Start the session if we're not running.
            guard let endpointPath = streamObj?.ingest_endpoint, let url = URL(string: "rtmps://\(endpointPath)/app"), let key = streamObj?.streamdata else {
                let alert = UIAlertController(title: "Invalid Endpoint",
                                              message: "The endpoint or streamkey you provided is invalid",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
            }
            do {
                // store this endpoint/key pair to share with the screen capture extension
                // and to auto-complete the next time this app is launched
                let authItem = AuthItem(endpoint: endpointPath, streamKey: key)
                UserDefaultsAuthDao.shared.insert(authItem)
                try broadcastSession?.start(with: url, streamKey: key)
                isRunning = true
            } catch {
                displayErrorAlert(error, "starting session")
            }
        }
    }

    @IBAction private func cameraTapped(_ sender: UIButton) {
        chooseDevice(sender, type: .camera, deviceName: "Camera", deviceSelected: setCamera(_:))
    }

    @IBAction private func microphoneTapped(_ sender: UIButton) {
        chooseDevice(sender, type: .microphone, deviceName: "Microphone", deviceSelected: setMicrophone(_:))
    }

    @IBAction private func muteTapped(_ sender: UIButton) {
        isMuted.toggle()
    }
    
    func initialSetup() {
        isMuted = false // trigger didSet because Storyboards don't support iOS version checks.

        // Tapping on the preview image will dismiss the keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(previewTapped))
        previewView.addGestureRecognizer(tap)
        
        connectionView.addCornerRadius(connectionView.frame.height / 2)
        startButton.addCornerRadius(7)
    }
    
    private func applyMute() {
        // It is important to note that when muting a microphone by adjusting the gain, the microphone will still be recording.
        // The orange light indicator on iOS devices will remain active. The SDK is still receiving all the real audio
        // samples, it is just applying a gain of 0 to them. To make the orange light turn off you need to detach the microphone
        // completely from the SDK, not just mute it.

        let gain: Float = isMuted ? 0 : 1
        let muteAll = true // toggle to change the mute strategy. Both are functionally equivalent in this sample app

        // In case there are any pending changes, let them finish and then update the mute status.
        broadcastSession?.awaitDeviceChanges { [weak self] in
            guard let `self` = self else { return }
            if (muteAll) {
                // This mutes all attached devices audio devices, doing so will mute all incoming audio until the gain
                // on one of the IVSAudioDevices is changed, or a new device is attached with a non-zero gain.
                self.broadcastSession?.listAttachedDevices()
                    .compactMap { $0 as? IVSAudioDevice }
                    .forEach { $0.setGain(gain) }
            } else {
                // This mutes just a single device
                (self.attachedMicrophone as? IVSAudioDevice)?.setGain(gain)
            }
        }

        let imageName = isMuted ? "ic_mute" : "ic_unmute"
        muteButton.setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate), for: .normal)
        muteButton.tintColor = .white
    }

    private func chooseDevice(_ sender: UIButton, type: IVSDeviceType, deviceName: String, deviceSelected: @escaping (IVSDeviceDescriptor) -> Void) {
        let alert = UIAlertController(title: "Choose a \(deviceName)", message: nil, preferredStyle: .actionSheet)
        IVSBroadcastSession.listAvailableDevices()
            .filter { $0.type == type }
            .forEach { device in
                alert.addAction(UIAlertAction(title: device.friendlyName, style: .default, handler: { _ in
                    deviceSelected(device)
                }))
            }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.popoverPresentationController?.sourceView = sender
        alert.popoverPresentationController?.sourceRect = sender.bounds
        present(alert, animated: true)
    }

    @objc
    private func previewTapped() {
        // This allows the user to tap on the preview view to dismiss the keyboard when
        // entering the endpoint and stream key.
        view.endEditing(false)
    }

    // MARK: - Utility Functions

    private func setupSession() {
        do {
            // Create the session with a preset config and camera/microphone combination.
            IVSBroadcastSession.applicationAudioSessionStrategy = .playAndRecord
            let broadcastSession = try IVSBroadcastSession(configuration: IVSPresets.configurations().standardPortrait(),
                                                           descriptors: IVSPresets.devices().frontCamera(),
                                                           delegate: self)
            broadcastSession.awaitDeviceChanges { [weak self] in
                let devices = broadcastSession.listAttachedDevices()
                let cameras = devices
                    .filter { $0.descriptor().type == .camera }
                    .compactMap { $0 as? IVSImageDevice }

                self?.attachedCamera = cameras.first
                self?.attachedMicrophone = devices.first(where: { $0.descriptor().type == .microphone })
            }
            self.broadcastSession = broadcastSession
        } catch {
            displayErrorAlert(error, "setting up session")
        }
    }

    private func setCamera(_ device: IVSDeviceDescriptor) {
        guard let broadcastSession = self.broadcastSession else { return }

        // either attach or exchange based on current state.
        if attachedCamera == nil {
            broadcastSession.attach(device, toSlotWithName: nil) { newDevice, _ in
                self.attachedCamera = newDevice
            }
        } else if let currentCamera = self.attachedCamera, currentCamera.descriptor().urn != device.urn {
            broadcastSession.exchangeOldDevice(currentCamera, withNewDevice: device) { newDevice, _ in
                self.attachedCamera = newDevice
            }
        }
    }

    func setMicrophone(_ device: IVSDeviceDescriptor) {
        guard let broadcastSession = self.broadcastSession else { return }

        // either attach or exchange based on current state.
        if attachedMicrophone == nil {
            broadcastSession.attach(device, toSlotWithName: nil) { newDevice, _ in
                self.attachedMicrophone = newDevice
            }
        } else if let currentMic = self.attachedMicrophone, currentMic.descriptor().urn != device.urn {
            broadcastSession.exchangeOldDevice(currentMic, withNewDevice: device) { newDevice, _ in
                self.attachedMicrophone = newDevice
            }
        }
    }

    private func refreshAttachedDevices() {
        guard let session = broadcastSession else { return }
        let attachedDevices = session.listAttachedDevices()
        let cameras = attachedDevices.filter { $0.descriptor().type == .camera }
        let microphones = attachedDevices.filter { $0.descriptor().type == .microphone }
        attachedCamera = cameras.first
        attachedMicrophone = microphones.first
    }
}

// MARK: - IVS Broadcast SDK Delegate

extension BroadcastClassVC : IVSBroadcastSession.Delegate {

    func broadcastSession(_ session: IVSBroadcastSession, didChange state: IVSBroadcastSession.State) {
        print("IVSBroadcastSession state did change to \(state.rawValue)")
        DispatchQueue.main.async {
            switch state {
            case .invalid:
                self.connectionView.backgroundColor = .darkGray
                self.isSuccessfullyJoinned = false
            case .connecting: self.connectionView.backgroundColor = .yellow
            case .connected: self.connectionView.backgroundColor = .green
                self.isSuccessfullyJoinned = true
            case .disconnected:
                self.connectionView.backgroundColor = .darkGray
                self.isRunning = false
                if !self.isSuccessfullyJoinned {
                    self.isSuccessfullyJoinned = false
                }
                self.classEndedBlock()
            case .error:
                self.connectionView.backgroundColor = .red
                self.isRunning = false
                self.isSuccessfullyJoinned = false
                self.classEndedBlock()
            @unknown default: self.connectionView.backgroundColor = .darkGray
            }
        }
    }
    
    func classEndedBlock() {
        if didEndStreamingBlock != nil {
            didEndStreamingBlock(self.isSuccessfullyJoinned)
            
        }
    }
    
    func broadcastSession(_ session: IVSBroadcastSession, didEmitError error: Error) {
        DispatchQueue.main.async {
            self.displayErrorAlert(error, "in SDK")
        }
    }

    func broadcastSession(_ session: IVSBroadcastSession, didAddDevice descriptor: IVSDeviceDescriptor) {
        print("IVSBroadcastSession did discover device \(descriptor)")
        // When audio routes change (like a Bluetooth headset turning off),
        // Apple will automatically switch the current route. Wait for the
        // IVS SDK to catch up and then refresh the current connected devices.
        session.awaitDeviceChanges {
            self.refreshAttachedDevices()
        }
    }

    func broadcastSession(_ session: IVSBroadcastSession, didRemoveDevice descriptor: IVSDeviceDescriptor) {
        print("IVSBroadcastSession did lose device \(descriptor)")
        // Same comment as didAddDevice above.
        session.awaitDeviceChanges {
            self.refreshAttachedDevices()
        }
    }

    func broadcastSession(_ session: IVSBroadcastSession, audioStatsUpdatedWithPeak peak: Double, rms: Double) {
        // This fires frequently, so we don't log it here.
    }

}
