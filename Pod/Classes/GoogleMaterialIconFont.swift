//
//  GoogleMaterialIconFont.swift
//  Pods
//
//  Created by Yusuke Kita on 9/23/15.
//
//

import UIKit

public extension String {
    public static func materialIcon(font: MaterialIconFont) -> String {
        return IconFont.codes[font.rawValue]
    }
}

public extension NSString {
    public static func materialIcon(font: MaterialIconFont) -> NSString {
        return NSString(string: String.materialIcon(font: font))
    }
}

public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block:(Void)->Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}

public extension UIFont {
    public static func materialIconOfSize(size: CGFloat) -> UIFont {
        let filename = "MaterialIcons-Regular"
        let fontname = "Material Icons"

        if UIFont.fontNames(forFamilyName: fontname).isEmpty {
            DispatchQueue.once(token: "GoogleMaterialIconLoadFont") {
                FontLoader.loadFont(name: filename)
            }
        }
        
        guard let font = UIFont(name: fontname, size: size) else {
            fatalError("\(fontname) not found")
        }
        return font
    }
}

private class FontLoader {
    class func loadFont(name: String) {
        let bundle = Bundle(for: FontLoader.self)
        let identifier = bundle.bundleIdentifier
        let fileExtension = "ttf"
        
        let url: NSURL?
        if identifier?.hasPrefix("org.cocoapods") == true {
            url = bundle.url(forResource: name, withExtension: fileExtension, subdirectory: "GoogleMaterialIconFont.bundle") as NSURL?
        } else {
            url = bundle.url(forResource: name, withExtension: fileExtension) as NSURL?
        }
        
        guard let fontURL = url else { fatalError("\(name) not found in bundle") }
        
        guard let data = NSData(contentsOf: fontURL as URL),
            let provider = CGDataProvider(data: data) else { return }
        let font = CGFont(provider)
        
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            let errorDescription: CFString = CFErrorCopyDescription(error!.takeUnretainedValue())
            let nsError = error!.takeUnretainedValue() as AnyObject as! NSError
            NSException(name: NSExceptionName.internalInconsistencyException, reason: errorDescription as String, userInfo: [NSUnderlyingErrorKey: nsError]).raise()
        }
    }
}
