import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation
import GPUImage
import SwiftUI
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

class ImageTouchViewController: UIViewController {

    @IBOutlet weak var imageTouchView: UIImageView!
    let apiKey = "602d63362348496ea03ae6a766b4527a"
    let apiEndPoint = "https://accessibility-ai-ly.cognitiveservices.azure.com/vision/v3.2/analyze?visualFeatures=Description" 
    
    var desc: String!
    var color_desc: String!
    let syntesizer = AVSpeechSynthesizer()
    var utterance = AVSpeechUtterance()
    
    var selectImage: UIImage
    var filteredImage: UIImage!
    var contouredImage: UIImage!
    
    var xMove: CGFloat!
    var yMove: CGFloat!
    let frameToBound = 44
    var viewScale: CGFloat!
    
    init?(coder: NSCoder,passImage: UIImage){
        self.selectImage = passImage
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pointTransfer(point: CGPoint) -> CGPoint{
        var new_point = CGPoint()
        print("xmove,ymove,frametobound:",xMove,yMove,frameToBound)
        new_point.x = (point.x - xMove) * viewScale
        new_point.y = (point.y - (CGFloat(frameToBound) + yMove)) * viewScale
        return new_point
    }
    func updateFrame(){
        var newFrame: CGRect!
        var newFrameSize: CGSize
        imageTouchView.image = selectImage
        newFrameSize = imageTouchView.imageSizeAfterAspectFit
        print("new frame size:",newFrameSize)
        viewScale = selectImage.size.width / newFrameSize.width
        print("viewScale:",viewScale)
        xMove = (imageTouchView.frame.width - newFrameSize.width)/2
        yMove = (imageTouchView.frame.height - newFrameSize.height)/2
        newFrame = CGRect(x: 0 + xMove, y: CGFloat(frameToBound) + yMove, width: newFrameSize.width, height: newFrameSize.height)
        imageTouchView.frame = newFrame
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateFrame()
        imageTouchView.image = selectImage.fixOrientation()
        contouredImage = detectVisionContours(sourceImage: selectImage.fixOrientation())
        print("selectimage:",selectImage.size)
        print("contoured:",contouredImage.size)
        //imageTouchView.image = contouredImage.fixOrientation()
        //imageTouchView.widthAnchor.constraint(equalTo: imageTouchView.heightAnchor, multiplier: selectImage.size.width / selectImage.size.height).isActive = true

        //print(newFrame.minX,newFrame.minY,newFrame.maxX,newFrame.maxY)
    
        //edgeDetection()
        //tap gesture
        //let tap = UITapGestureRecognizer(target: self, action: #selector(tapView(tap:)))
        imageTouchView.isUserInteractionEnabled = true
        //imageTouchView.addGestureRecognizer(tap)
        ImageUpload(self.selectImage)
        // Do any additional setup after loading the view.
        
        
    }
    
    @IBAction func playAgain(_ sender: Any) {
        self.audio(text: self.desc)
    }
    
    override var prefersStatusBarHidden: Bool {
            return true
        }
    
    //audio description
    func ImageUpload(_ image: UIImage) {
    guard image.jpegData(compressionQuality: 0.9) != nil else {
                self.dismiss(animated: true, completion: nil)
                return
            }
            let imagedata = image.jpegData(compressionQuality: 0.9)
            var imageSize: Double = Double(imagedata!.count)/1000.0
            print("actual size of image in KB: %f ", imageSize)
            //if bigger than 4M
            if(imageSize < 4096.0){
                let uploadDict = ["num": "123456789"] as [String:String]
                let headers: HTTPHeaders = ["Ocp-Apim-Subscription-Key":apiKey]
                Alamofire.upload(multipartFormData: { MultipartFormData in
                   
                    MultipartFormData.append(imagedata!, withName: "image" , fileName: "image.jpg" , mimeType: "image/jpg")
                    for(key,value) in uploadDict{
                        MultipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)}
                },to:apiEndPoint, headers: headers, encodingCompletion: {
                    EncodingResult in
                    switch EncodingResult{
                    case .success(let upload, _, _):
                        upload.responseJSON { [self] response in
                            guard let json = response.result.value! as? [String: Any] else {
                                return
                            }
                            print("json:",json)
                            let des = json["description"] as! [String: Any]
                            let cap = des["captions"] as! [[String: Any]]
                            let destext = cap[0]["text"] as! String
                            self.desc = destext
                            print(self.desc!)
                            self.audio(text: self.desc)
                        }
                    case .failure(let encodingError):
                        print("ERROR RESPONSE: \(encodingError)")
                    }
                })
            }else{
                self.desc = "NULL"
                self.audio(text: self.desc)
            }
            
        }
    
    func audio(text: String) {
        utterance = AVSpeechUtterance (string: text)
            // 语音的速度
            utterance.rate = 0.3
            // 开始朗读
            syntesizer.speak(utterance)
        }
    
    func findColor(new_loc: CGPoint){
        let color = self.selectImage.cxg_getPointColor(withImage: self.selectImage, point: new_loc)
        print("color:",color)
        print("color_in_255:",color.rgb())
        let color_array = color.rgbFloat()
        self.color_desc = recogColor(r: color_array.0, g: color_array.1, b: color_array.2)
        print("color_desc:",self.color_desc!)
        self.audio(text: self.color_desc)
    }
    
    func findEdge(new_loc: CGPoint){
        let edge = self.selectImage.cxg_getPointColor(withImage: self.contouredImage, point: new_loc)
        print("color:",edge)
        let edge_array = edge.rgbFloat()
        if(edge_array.0 >= 0.5){
            print("edge:",edge_array)
            self.audio(text: "Edge")
        }
       
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let tapPoint = touch.location(in: view)
            let loc = tapPoint
            print("view loc:",loc)
            let new_loc = pointTransfer(point: loc)
            print("image loc:",new_loc)
            if (self.imageTouchView.frame.contains(loc)){
                print("IN FRAME")
                findColor(new_loc: new_loc)
                findEdge(new_loc: new_loc)
            }else{
                print("OUTSIDE")
            }
            
            //imageTouchView.image = detectVisionContours(sourceImage: selectImage)
            //edge
            //edgeDetection()
            //color
            /*
            let tapPoint = touch.location(in: self.view)
            let loc = tapPoint
            let color = imageTouchView.colorOfTouch(point: loc)
            print(color.rgb())
             */
           
            /*
            let tapPoint = touch.location(in: self.view)
            let loc = tapPoint
            /*
            if (self.imageTouchView.frame.contains(loc)){
                print("loc:",loc)
                print("IN FRAME")
            }else{
                print("loc:",loc)
                print("OUTSIDE")
            }
            */
            let color = imageTouchView.colorOfTouch(point: loc)
            print("color:",color)
            print("color_in_255:",color.rgb())
            let color_array = color.rgbFloat()
            self.color_desc = recogColor(r: color_array.0, g: color_array.1, b: color_array.2)
            print("color_desc:",self.color_desc!)
            self.audio(text: self.color_desc)
            */
            //let color = imageTouchView.image!.getPixelColor(pos: loc)
            
            
            
            /*
            let edge_color = self.filteredImage.getPixelColor(pos: loc)
            print("edge_color:",edge_color)
            print("edge_color_in_255:",edge_color.rgb())
            let edge_color_array = edge_color.rgbFloat()
            print(edge_color_array)
            if(edge_color_array.0 >= 0.6){
                self.audio(text: "edge")
            }
             */
            
            //print(color.rgb())
            //print("edge:",edge_color)
            
            
        }
    }
    
    func recogColor(r: Float, g: Float, b: Float) -> String{
        let rgb_array = [r,g,b]
        print("r-g:",r-g)
        print("r-b:",r-b)
        print("g-b:",g-b)
        var final_color: String!
        var color_threshold: Float
        var color_threshold2: Float
        color_threshold = 0.15
        color_threshold2 = 0.05
        if (r == 1.0 && g == 1.0 && b == 1.0){
            final_color = "White"
        }else if (r == 0.0 && g == 0.0 && b == 0.0){
                final_color = "Black"
        }else if (abs(r-g) <= color_threshold2 && abs(r-b) <= color_threshold2 && abs(g-b) <= color_threshold2){
            final_color = "Gray"
        }else if (rgb_array.max() == r){
            /*
            if(r-g <= color_threshold && r-b >= color_threshold){
                final_color = "Yellow"
            }
            else if(r-g >= color_threshold && r-b <= color_threshold){
                final_color = "Pink"
            }
            else{
                final_color = "Red"
            }
            */
            if (g >= b){
                if (r-g <= color_threshold){
                    final_color = "Yellow"
                }
                else{
                    final_color = "Red"
                }
            }
            if (b > g){
                if (r-b <= color_threshold){
                    final_color = "Pink"
                }
                else{
                    final_color = "Red"
                }
            }
            
        }else if (rgb_array.max() == g){
            if (r >= b){
                if(g-r <= color_threshold){
                    final_color = "Yellow"
                }
                else{
                    final_color = "Green"
                }
            }
            if(b > r){
                if(g-b <= color_threshold){
                    final_color = "Cyan"
                }
                else{
                    final_color = "Green"
                }
            }
            
            /*
            if(g-r <= color_threshold && g-b >= color_threshold){
                final_color = "Yellow"
            }
            else if(g-r >= color_threshold && g-b <= color_threshold){
                final_color = "Cyan"
            }
            else{
                final_color = "Green"
            }
             */
        }else if (rgb_array.max() == b){
            if(r >= g){
                if(b-r <= color_threshold){
                    final_color = "Pink"
                }
                else{
                    final_color = "Blue"
                }
            }
            else if(g > r){
                if(b-g <= color_threshold){
                    final_color = "Cyan"
                }
                else{
                    final_color = "Blue"
                }
            }
            
            /*
            if(b-r <= color_threshold && b-g >= color_threshold){
                final_color = "Pink"
            }
            else if(b-r >= color_threshold && b-g <= color_threshold){
                final_color = "Cyan"
            }
            else{
                final_color = "Blue"
            }
             */
        }
            return final_color
    }
    
    //edge detection(canny)
    func edgeDetection(){
        let inputImage = self.selectImage
        let filter = SobelEdgeDetection()
        filter.edgeStrength = 3
        //let filter = CannyEdgeDetection()
        //filter.lowerThreshold = 0.3
        //filter.upperThreshold = 0.5
        let filteredImage = inputImage.filterWithOperation(filter)
        self.filteredImage = filteredImage
        //self.imageTouchView.image = filteredImage
    }
    
    func drawContours(contoursObservation: VNContoursObservation, sourceImage: CGImage) -> UIImage {
        let size = CGSize(width: sourceImage.width, height: sourceImage.height)
        let renderer = UIGraphicsImageRenderer(size: size)
        let renderedImage = renderer.image { (context) in
        let renderingContext = context.cgContext
        
        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height)
        renderingContext.concatenate(flipVertical)

        renderingContext.scaleBy(x: size.width, y: size.height)
        //renderingContext.setLineWidth(15.0 / CGFloat(size.width))
        renderingContext.setLineWidth(0.01)
        //renderingContext.setLineWidth(5.0)
        let redUIColor = UIColor.red
        renderingContext.setStrokeColor(redUIColor.cgColor)
        //renderingContext.setFillColor(whiteUIColor.cgColor)
        renderingContext.addPath(contoursObservation.normalizedPath)
        renderingContext.strokePath()
        }
        
        return renderedImage
    }
    
    
    func detectVisionContours(sourceImage: UIImage) -> UIImage{
        //let aaimage = UIImage.init(named: "coins")?.cgImage
        let context = CIContext()

        var inputImage = CIImage.init(cgImage: sourceImage.cgImage!)
        var preProcessImage: UIImage!
        var contouredImage: UIImage!
        
        let contourRequest = VNDetectContoursRequest.init()
        contourRequest.revision = VNDetectContourRequestRevision1
        contourRequest.contrastAdjustment = 2.0
        //contourRequest.contrastPivot = 0.65
        contourRequest.detectDarkOnLight = true
        
        //contourRequest.maximumImageDimension = 512
        
        do {
                let noiseReductionFilter = CIFilter.gaussianBlur()
                noiseReductionFilter.radius = 0.5
                noiseReductionFilter.inputImage = inputImage

                let blackAndWhite = CustomFilter()
                blackAndWhite.inputImage = noiseReductionFilter.outputImage!
                let filteredImage = blackAndWhite.outputImage!
            
//                    let monochromeFilter = CIFilter.colorControls()
//                    monochromeFilter.inputImage = noiseReductionFilter.outputImage!
//                    monochromeFilter.contrast = 20.0
//                    monochromeFilter.brightness = 4
//                    monochromeFilter.saturation = 50
//                    let filteredImage = monochromeFilter.outputImage!


                inputImage = filteredImage
                if let cgimg = context.createCGImage(filteredImage, from: filteredImage.extent) {
                    preProcessImage = UIImage(cgImage: cgimg)
                }
            }

        let requestHandler = VNImageRequestHandler.init(ciImage: inputImage, options: [:])

        try! requestHandler.perform([contourRequest])
        let contoursObservation = contourRequest.results?.first as! VNContoursObservation
        contouredImage = drawContours(contoursObservation: contoursObservation, sourceImage: sourceImage.cgImage!)
        return contouredImage

    }
}


class CustomFilter: CIFilter {
    var inputImage: CIImage?
    
    override public var outputImage: CIImage! {
        get {
            if let inputImage = self.inputImage {
                let args = [inputImage as AnyObject]
                
                let callback: CIKernelROICallback = {
                (index, rect) in
                    return rect.insetBy(dx: -1, dy: -1)
                }
                
                return createCustomKernel().apply(extent: inputImage.extent, roiCallback: callback, arguments: args)
            } else {
                return nil
            }
        }
    }

    
    func createCustomKernel() -> CIKernel {
            return CIColorKernel(source:
                "kernel vec4 replaceWithBlackOrWhite(__sample s) {" +
                    "if (s.r > 0.25 && s.g > 0.25 && s.b > 0.25) {" +
                    "    return vec4(0.0,0.0,0.0,1.0);" +
                    "} else {" +
                    "    return vec4(1.0,1.0,1.0,1.0);" +
                    "}" +
                "}"
                )!
           
        }
}

    /*
    @objc func tapView(tap: UITapGestureRecognizer) {
        print("single tap")
        
        //show color
        let tapPoint = tap.location(in: self.view)
        let loc = tapPoint
        let color = imageTouchView.colorOfTouch(point: loc)

        print(color.rgb())
        print(color.hex())
    }
   
    @objc func colorTap(tap: UITapGestureRecognizer){
        let tapPoint = tap.location(in: self.view)
        let loc = tapPoint
        let color = imageTouchView.colorOfTouch(point: loc)

        print(color.rgb())
        print(color.hex())
    }
    */
   

    
  
    
    
    
