import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation


class ImageTouchViewController: UIViewController {

    @IBOutlet weak var imageTouchView: UIImageView!
    let apiKey = "602d63362348496ea03ae6a766b4527a"
    let apiEndPoint = "https://accessibility-ai-ly.cognitiveservices.azure.com/vision/v3.2/analyze?visualFeatures=Description" 
    
    let syntesizer = AVSpeechSynthesizer()
    var utterance = AVSpeechUtterance()
    
    var selectImage: UIImage
    
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
        
        //tap gesture
        //let tap = UITapGestureRecognizer(target: self, action: #selector(tapView(tap:)))
        imageTouchView.isUserInteractionEnabled = true
        //imageTouchView.addGestureRecognizer(tap)
        ImageUpload(self.selectImage)
        // Do any additional setup after loading the view.
        
    }
    
    override var prefersStatusBarHidden: Bool {
            return true
        }
    
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
                        print(destext)
                        self.audio(text: destext)
                    }
                case .failure(let encodingError):
                    print("ERROR RESPONSE: \(encodingError)")
                }
            })
        }
    
    func audio(text: String) {
        utterance = AVSpeechUtterance (string: text)
            // 语音的速度
            utterance.rate = 0.4
            // 开始朗读
            syntesizer.speak(utterance)
        }
    /*
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let tapPoint = touch.location(in: self.view)
            let loc = tapPoint
            let color = imageTouchView.colorOfTouch(point: loc)

            print(color.rgb())
            print(color.hex())
        }
    }

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
