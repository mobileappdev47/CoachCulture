// swiftlint:disable function_parameter_count line_length redundant_void_return identifier_name trailing_whitespace

import Foundation
import UIKit
import Toast_Swift
import libPhoneNumber_iOS

class Utility {
    
    // MARK: VARIABLE AND OBJECT
    
    static let shared = Utility()
    
    var enableLog = true
    
    // MARK: OPEN URL
    
    func openURLFor(urlStr: String?) {
        if let url = URL(string: urlStr ?? ""),
           UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler:nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else { }
    }
    
    
    
    // MARK: SHOW ALERT
    
    class func openAlert(vc : UIViewController,title: String?,
                         message: String?,
                         alertStyle:UIAlertController.Style,
                         actionTitles:[String],
                         actionStyles:[UIAlertAction.Style],
                         actions: [((UIAlertAction) -> Void)]){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        for(index, indexTitle) in actionTitles.enumerated(){
            let action = UIAlertAction(title: indexTitle, style: actionStyles[index], handler: actions[index])
            alertController.addAction(action)
        }
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alertController.popoverPresentationController?.sourceView = vc.view
            alertController.popoverPresentationController?.sourceRect = (vc.view as AnyObject).bounds
            alertController.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        vc.present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(vc: UIViewController, title: String?, message: String?, alertStyle: UIAlertController.Style, actionTitles: [String], actionStyles: [UIAlertAction.Style], actions: [((UIAlertAction) -> Void)]) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        for(index, indexTitle) in actionTitles.enumerated() {
            let action = UIAlertAction(title: indexTitle, style: actionStyles[index], handler: actions[index])
            alertController.addAction(action)
        }
        vc.present(alertController, animated: true)
    }
    
    // MARK: SHOW SIMPLE ALERT
    
    class func showMessageAlert(title: String, andMessage message: String, withOkButtonTitle okButtonTitle: String) {
        let alertWindow: UIWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: okButtonTitle, style: .default, handler: { (_ action) -> Void in
            alertWindow.isHidden = true
        }))
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: SHOW TOAST
    
    func showToast(_ alertMsg: String) -> Void {
        showToast(alertMsg, title: "")
    }
    
    func showToast(_ alertMsg: String, title: String) -> Void {
        DispatchQueue.main.async {
            if let window = UIApplication.shared.keyWindow {
                window.hideAllToasts()
                window.makeToast(alertMsg, duration: 3.0, position: .bottom)
            }
        }
    }
    
    func checkPhoneNumberValidation(number: String, countryCodeStr: String) -> Bool{
        let phoneUtil = NBPhoneNumberUtil()
        do {
            let phoneNumber: NBPhoneNumber = try phoneUtil.parse(number, defaultRegion: countryCodeStr)
            let value = phoneUtil.isValidNumber(phoneNumber)
            if(value == true) {
                return true
            } else {
                return false
            }
        }
        catch _ as NSError {
            //        showToast(message: Messages.Invalid_phone, view: view)
            //        print(error.localizedDescription)
            return false
        }
    }
    
    // MARK: INSTANTIATE VC FROM DIFF STORYBOARDS
    
    func getVCInstance(_ storyBoardID: String) -> UIViewController? {
        let storyboard = UIStoryboard.init(name: self.getStoryBoard(storyBoardID), bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: storyBoardID)
    }
    
    private func getStoryBoard(_ storyBoardID: String) -> String {
        /*if AlertConformationWithTextField.storyBoardID == storyBoardID {
         return "Main"
         }*/
        return "LoginSB"
    }
    
    class func isLogEnable() -> Bool {
        return self.shared.enableLog
    }
    
    class func enableLog() {
        self.shared.enableLog = true
    }
    
    class func disableLog() {
        self.shared.enableLog = false
    }
    
    func NameValidation(name : String) -> Bool {
        if name.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    func MobileValidation(MobileNumber : String) -> Bool {
        if MobileNumber.isNumeric {
            if MobileNumber.count >= 4 {
                return true
            }else{
                return false
            }
        }else{
            return false
        }
    }
    
    func EmailValidation(string :String) -> Bool {
        let emailRegEx = "[a-zA-Z0-9._-]+@[a-z]+\\.+[a-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: string)
    }
    
    func validatePassword(string: String) -> Bool {
        let regex = "^[A-Za-z0-9_$@!%*?&].{5,14}"//"^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&])[A-Za-z\\d$@$!%*?&]{6,15}"
        let isMatched = NSPredicate(format:"SELF MATCHES %@", regex).evaluate(with: string)
        return isMatched
    }
    
    func setChatsImage(data : Data, strUrlKey: String) {
        DEFAULTS.set(data, forKey: strUrlKey)
    }
    
    func getChatsImage(strURL: String) -> AnyObject {
        let retrievedImage = DEFAULTS.object(forKey: strURL) as AnyObject
        return retrievedImage
    }
    
    let docsTypes = ["public.text",
                     "com.apple.iwork.pages.pages",
                     "public.data",
                     "kUTTypeItem",
                     "kUTTypeContent",
                     "kUTTypeCompositeContent",
                     "kUTTypeData",
                     "public.database",
                     "public.calendar-event",
                     "public.message",
                     "public.presentation",
                     "public.contact",
                     "public.archive",
                     "public.disk-image",
                     "public.plain-text",
                     "public.utf8-plain-text",
                     "public.utf16-external-plain-​text",
                     "public.utf16-plain-text",
                     "com.apple.traditional-mac-​plain-text",
                     "public.rtf",
                     "com.apple.ink.inktext",
                     "public.html",
                     "public.xml",
                     "public.source-code",
                     "public.c-source",
                     "public.objective-c-source",
                     "public.c-plus-plus-source",
                     "public.objective-c-plus-​plus-source",
                     "public.c-header",
                     "public.c-plus-plus-header",
                     "com.sun.java-source",
                     "public.script",
                     "public.assembly-source",
                     "com.apple.rez-source",
                     "public.mig-source",
                     "com.apple.symbol-export",
                     "com.netscape.javascript-​source",
                     "public.shell-script",
                     "public.csh-script",
                     "public.perl-script",
                     "public.python-script",
                     "public.ruby-script",
                     "public.php-script",
                     "com.sun.java-web-start",
                     "com.apple.applescript.text",
                     "com.apple.applescript.​script",
                     "public.object-code",
                     "com.apple.mach-o-binary",
                     "com.apple.pef-binary",
                     "com.microsoft.windows-​executable",
                     "com.microsoft.windows-​dynamic-link-library",
                     "com.sun.java-class",
                     "com.sun.java-archive",
                     "com.apple.quartz-​composer-composition",
                     "org.gnu.gnu-tar-archive",
                     "public.tar-archive",
                     "org.gnu.gnu-zip-archive",
                     "org.gnu.gnu-zip-tar-archive",
                     "com.apple.binhex-archive",
                     "com.apple.macbinary-​archive",
                     "public.url",
                     "public.file-url",
                     "public.url-name",
                     "public.vcard",
                     "public.image",
                     "public.fax",
                     "public.jpeg",
                     "public.jpeg-2000",
                     "public.tiff",
                     "public.camera-raw-image",
                     "com.apple.pict",
                     "com.apple.macpaint-image",
                     "public.png",
                     "public.xbitmap-image",
                     "com.apple.quicktime-image",
                     "com.apple.icns",
                     "com.apple.txn.text-​multimedia-data",
                     "public.audiovisual-​content",
                     "public.movie",
                     "public.video",
                     "com.apple.quicktime-movie",
                     "public.avi",
                     "public.mpeg",
                     "public.mpeg-4",
                     "public.3gpp",
                     "public.3gpp2",
                     "public.audio",
                     "public.mp3",
                     "public.mpeg-4-audio",
                     "com.apple.protected-​mpeg-4-audio",
                     "public.ulaw-audio",
                     "public.aifc-audio",
                     "public.aiff-audio",
                     "com.apple.coreaudio-​format",
                     "public.directory",
                     "public.folder",
                     "public.volume",
                     "com.apple.package",
                     "com.apple.bundle",
                     "public.executable",
                     "com.apple.application",
                     "com.apple.application-​bundle",
                     "com.apple.application-file",
                     "com.apple.deprecated-​application-file",
                     "com.apple.plugin",
                     "com.apple.metadata-​importer",
                     "com.apple.dashboard-​widget",
                     "public.cpio-archive",
                     "com.pkware.zip-archive",
                     "com.apple.webarchive",
                     "com.apple.framework",
                     "com.apple.rtfd",
                     "com.apple.flat-rtfd",
                     "com.apple.resolvable",
                     "public.symlink",
                     "com.apple.mount-point",
                     "com.apple.alias-record",
                     "com.apple.alias-file",
                     "public.font",
                     "public.truetype-font",
                     "com.adobe.postscript-font",
                     "com.apple.truetype-​datafork-suitcase-font",
                     "public.opentype-font",
                     "public.truetype-ttf-font",
                     "public.truetype-collection-​font",
                     "com.apple.font-suitcase",
                     "com.adobe.postscript-lwfn​-font",
                     "com.adobe.postscript-pfb-​font",
                     "com.adobe.postscript.pfa-​font",
                     "com.apple.colorsync-profile",
                     "public.filename-extension",
                     "public.mime-type",
                     "com.apple.ostype",
                     "com.apple.nspboard-type",
                     "com.adobe.pdf",
                     "com.adobe.postscript",
                     "com.adobe.encapsulated-​postscript",
                     "com.adobe.photoshop-​image",
                     "com.adobe.illustrator.ai-​image",
                     "com.compuserve.gif",
                     "com.microsoft.bmp",
                     "com.microsoft.ico",
                     "com.microsoft.word.doc",
                     "com.microsoft.excel.xls",
                     "com.microsoft.powerpoint.​ppt",
                     "com.microsoft.waveform-​audio",
                     "com.microsoft.advanced-​systems-format",
                     "com.microsoft.windows-​media-wm",
                     "com.microsoft.windows-​media-wmv",
                     "com.microsoft.windows-​media-wmp",
                     "com.microsoft.windows-​media-wma",
                     "com.microsoft.advanced-​stream-redirector",
                     "com.microsoft.windows-​media-wmx",
                     "com.microsoft.windows-​media-wvx",
                     "com.microsoft.windows-​media-wax",
                     "com.apple.keynote.key",
                     "com.apple.keynote.kth",
                     "com.truevision.tga-image",
                     "com.sgi.sgi-image",
                     "com.ilm.openexr-image",
                     "com.kodak.flashpix.image",
                     "com.j2.jfx-fax",
                     "com.js.efx-fax",
                     "com.digidesign.sd2-audio",
                     "com.real.realmedia",
                     "com.real.realaudio",
                     "com.real.smil",
                     "com.allume.stuffit-archive",
                     "org.openxmlformats.wordprocessingml.document",
                     "com.microsoft.powerpoint.​ppt",
                     "org.openxmlformats.presentationml.presentation",
                     "com.microsoft.excel.xls",
                     "org.openxmlformats.spreadsheetml.sheet",
                     
                     
    ]
    
    public func readLocalFile(forName name: String) -> [String:Any]? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name, ofType: "json") {
                guard let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) else { return [:] }
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String:Any]
                    return jsonObject
                } catch  {
                    
                }
                
            }
        } catch {
            print(error)
        }
        return nil
    }
}

// MARK: PRINT LOG

func DLog(_ items: Any?..., function: String = #function, file: String = #file, line: Int = #line) {
    if isDevelopmentMode {
        print("-----------START-------------")
        let url = NSURL(fileURLWithPath: file)
        print("Message = ", items, "\n\n(File: ", url.lastPathComponent ?? "nil", ", Function: ", function, ", Line: ", line, ")")
        print("-----------END-------------\n")
    }
}

// MARK: ENUMARATION STORYBOARD

enum AppStoryboard: String {
    
    case Coach
    
    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    
    func viewController<T: UIViewController>(viewControllerClass: T.Type, function: String = #function, line: Int = #line, file: String = #file) -> T {
        
        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
        guard let scene = instance.instantiateViewController(withIdentifier: storyboardID) as? T else {
            fatalError("ViewController with identifier \(storyboardID), not found in \(self.rawValue) Storyboard.\nFile : \(file) \nLine Number : \(line) \nFunction : \(function)")
        }
        return scene
    }
    
    func initialViewController() -> UIViewController? {
        return instance.instantiateInitialViewController()
    }
}

enum LangaugeSelected: String {
    
    case english = "en"
    
    func description() -> String {
        switch self {
        case .english:
            return "English"
        }
    }
}

func getDirectoryPath() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

func createDirectory(MyFolderName : String) -> URL{
    
    let docURL = URL(string: getDirectoryPath())!
    let dataPath = docURL.appendingPathComponent(MyFolderName)
    if !FileManager.default.fileExists(atPath: dataPath.path) {
        do {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    return dataPath
}
