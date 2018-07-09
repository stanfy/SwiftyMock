import Foundation
import UIKit

protocol Random {
    static func random() -> Self
}

extension Array: Random {
    private static func randomElement() -> Element? {
        guard Element.self is Random.Type else {
            return nil
        }
        return (Element.self as? Random.Type)?.random() as? Element
    }

    static func random() -> [Element] {
        return (0...Int(arc4random() % 3))
            .map { _ in randomElement() }
            .compactMap { $0 }
    }
}

extension Optional: Random {
    private static func randomElement() -> Wrapped? {
        guard Wrapped.self is Random.Type else {
            return nil
        }
        return (Wrapped.self as? Random.Type)?.random() as? Wrapped
    }

    static func random() -> Wrapped? {
        return Int(arc4random() % 2) == 0
            ? nil
            : randomElement()
    }
}

extension String: Random {
    static func random() -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)

        var randomString = ""

        for _ in 0 ..< 20 {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
}

extension Int: Random {
    static func random() -> Int {
        return Int(arc4random() % 200)
    }
}

extension UInt: Random {
    static func random() -> UInt {
        return UInt(arc4random() % 200)
    }
}

extension Int32: Random {
    static func random() -> Int32 {
        return Int32(arc4random() % 300)
    }
}

extension Int64: Random {
    static func random() -> Int64 {
        return Int64(arc4random() % 300)
    }
}

extension Double: Random {
    static func random() -> Double {
        return Double(arc4random() % 1000) / 100
    }
}

extension Float: Random {
    static func random() -> Float {
        return Float(arc4random() % 1000) / 100
    }
}

extension Bool: Random {
    static func random() -> Bool {
        return arc4random() % 2 == 1
    }
}

extension Data: Random {
    static func random() -> Data {
        let bytes = [UInt32](repeating: 0, count: 10).map { _ in arc4random() }
        return Data(bytes: bytes, count: 10 )
    }
}

extension Date: Random {
    static func random() -> Date {
        return Date(timeIntervalSince1970: Double.random())
    }
}

extension UIImage {
    static func random() -> UIImage {
        let color = UIColor.random()
        let rect = CGRect(origin: CGPoint(x: 0, y:0), size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!

        context.setFillColor(color.cgColor)
        context.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

extension UIColor {
    static func random() -> UIColor {
        let literal = CGFloat(arc4random() % 255)
        return .init(red: literal, green: literal, blue: literal, alpha: literal)
    }
}

extension NSError {
    static func random() -> NSError {
        return NSError(domain: .random(), code: .random(), userInfo: nil)
    }
}

extension URL: Random {
    static func random() -> URL {
        return URL(string: .random())!
    }
}
