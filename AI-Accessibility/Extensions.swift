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

    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
    
}

 
extension UIImageView {
    
    var imageSizeAfterAspectFit: CGSize {
           var newWidth: CGFloat
           var newHeight: CGFloat

           guard let image = image else { return frame.size }

           if image.size.height >= image.size.width {
               newHeight = frame.size.height
               newWidth = ((image.size.width / (image.size.height)) * newHeight)
               print("newWidth:",newWidth,"newHeight:",newHeight)
               
               if CGFloat(newWidth) > (frame.size.width) {
                   print("if CGFloat(newWidth) > (frame.size.width)")
                   newWidth = frame.size.width
                   newHeight = ((image.size.height / (image.size.width)) * newWidth)
                   print("newWidth:",newWidth,"newHeight:",newHeight)
               }
               /*
               if CGFloat(newWidth) > (frame.size.width) {
                   print("if CGFloat(newWidth) > (frame.size.width)")
                   let diff = (frame.size.width) - newWidth
                   newHeight = newHeight + CGFloat(diff) / newHeight * newHeight
                   newWidth = frame.size.width
                   print("newWidth:",newWidth,"newHeight:",newHeight)
               }
                */
           } else {
               print("else")
               newWidth = frame.size.width
               newHeight = (image.size.height / image.size.width) * newWidth
               print("newWidth:",newWidth,"newHeight:",newHeight)
               
               if newHeight > frame.size.height {
                   print("if newHeight > frame.size.height")
                   let diff = Float((frame.size.height) - newHeight)
                   newWidth = newWidth + CGFloat(diff) / newWidth * newWidth
                   newHeight = frame.size.height
                   print("newWidth:",newWidth,"newHeight:",newHeight)
               }
           }
           return .init(width: newWidth, height: newHeight)
       }
    
    
    

}
