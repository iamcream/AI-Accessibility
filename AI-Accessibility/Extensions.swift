import Foundation
import UIKit

extension UIView {
    func colorOfTouch (point: CGPoint) -> UIColor {
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.translateBy(x: -point.x, y: -point.y)
        self.layer.render(in: context)
        let color = UIColor(red: CGFloat(pixel[0]) / 255,
                            green: CGFloat(pixel[1] / 255),
                            blue: CGFloat(pixel[2]) / 255,
                            alpha: CGFloat(pixel[3]) / 255)
        print("pixel:",pixel)
        
        pixel.deallocate()
        return color
    }
}

extension UIColor {
    func hex () -> String {
        guard let components = cgColor.components, components.count >= 3 else {
            return ""
        }
        
        let r = Float(components[0]) * 255
        let g = Float(components[1]) * 255
        let b = Float(components[2]) * 255

        return String(format: "%02X%02X%02X",
                          lroundf(r),
                          lroundf(g),
                          lroundf(b))
    }
    
    func rgb() -> String {
        guard let components = cgColor.components, components.count >= 3 else {
            return ""
        }
        
        let r = Float(components[0]) * 255
        let g = Float(components[1]) * 255
        let b = Float(components[2]) * 255

        return String(format: "R: %d G: %d B: %d",
                          lroundf(r),
                          lroundf(g),
                          lroundf(b))
    }
}
