import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation
import GPUImage

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
    
    init?(coder: NSCoder,passImage: UIImage){
        self.selectImage = passImage
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageTouchView.image = selectImage
        edgeDetection()
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
        }
    
    func audio(text: String) {
        utterance = AVSpeechUtterance (string: text)
            // 语音的速度
            utterance.rate = 0.3
            // 开始朗读
            syntesizer.speak(utterance)
        }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
 
        if let touch = touches.first {
            //edge
            edgeDetection()
            //color
            /*
            let tapPoint = touch.location(in: self.view)
            let loc = tapPoint
            let color = imageTouchView.colorOfTouch(point: loc)
            print(color.rgb())
             */
            let tapPoint = touch.location(in: self.view)
            let loc = tapPoint
            
            let color = self.selectImage.getPixelColor(pos: loc)
            //let color = imageTouchView.colorOfTouch(point: loc)
            print("color:",color)
            print("color_in_255:",color.rgb())
            let color_array = color.rgbFloat()
            self.color_desc = recogColor(r: color_array.0, g: color_array.1, b: color_array.2)
            print("color_desc:",self.color_desc!)
            self.audio(text: self.color_desc)
            
            let edge_color = self.filteredImage.getPixelColor(pos: loc)
            print("edge_color:",edge_color)
            print("edge_color_in_255:",edge_color.rgb())
            let edge_color_array = edge_color.rgbFloat()
            print(edge_color_array)
            if(edge_color_array.0 >= 0.6){
                self.audio(text: "edge")
            }
            
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
    
    //edge detection
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
   

    
  
    
    
    
    
}
