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
        pixel.deallocate()
        return color
    }
    
    func edgeOfTouch (point: CGPoint) -> UIColor {
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.translateBy(x: -point.x, y: -point.y)
        //self.layer.render(in: context)
        let color = UIColor(red: CGFloat(pixel[0]) / 255,
                            green: CGFloat(pixel[1] / 255),
                            blue: CGFloat(pixel[2]) / 255,
                            alpha: CGFloat(pixel[3]) / 255)
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
    
    func rgbFloat() -> (r: Float,g: Float,b: Float) {
        guard let components = cgColor.components, components.count >= 3 else {
            return (-1.0,-1.0,-1.0)
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        /*return String(format: "R: %d G: %d B: %d",
                          lroundf(r),
                          lroundf(g),
                          lroundf(b))
         */
        return (r,g,b)
         
    }

    
}

extension UIImage{
    func getPixelColor(pos: CGPoint) -> UIColor {
        let pixelData = self.cgImage!.dataProvider!.data
        //let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.cgImage))
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        print("pos:",pos)
        print("x:",pos.x,"y:",pos.y)
        print("size:",self.size)
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
    
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    /*
    func cxg_getPointColor(withImage image: UIImage, point: CGPoint) -> UIColor {

        let pointX = trunc(point.x);
        let pointY = trunc(point.y);

        let width = image.size.width;
        let height = image.size.height;
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        var pixelData: [UInt8] = [0, 0, 0, 0]

        pixelData.withUnsafeMutableBytes { pointer in
            if let context = CGContext(data: pointer.baseAddress, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue), let cgImage = image.cgImage {
                context.setBlendMode(.copy)
                context.translateBy(x: -pointX, y: pointY - height)
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            }
        }

        let red = CGFloat(pixelData[0]) / CGFloat(255.0)
        let green = CGFloat(pixelData[1]) / CGFloat(255.0)
        let blue = CGFloat(pixelData[2]) / CGFloat(255.0)
        let alpha = CGFloat(pixelData[3]) / CGFloat(255.0)

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    */
   
}
