import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var imagePicker: UIImagePickerController!
    var selectImage: UIImage!
    var phototype: Int!

    @IBAction func btnStart(_ sender: Any) {
        showActions()
    }
    
    @IBSegueAction func mainToImageTouch(_ coder: NSCoder) -> ImageTouchViewController? {
        let controller = ImageTouchViewController(coder: coder, passImage: selectImage)
        return controller
    }
    
    @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {
    //        let sourceViewController = unwindSegue.source
            // Use data from the view controller which initiated the unwind segue
    }
    
    func showActions(){
        let alert = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            print("Camera")
            self.phototype = 1
            self.showImage(type: self.phototype)
            alert.dismiss(animated: true, completion: nil)
        }
        let photoLibraryAction = UIAlertAction(title: "Album", style:.default) { _ in
            print("Album")
            self.phototype = 2
            self.showImage(type: self.phototype)
            alert.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cameraAction)
        alert.addAction(photoLibraryAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showImage(type: Int){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        if (type == 1){
            imagePicker.sourceType = .camera
        }else if (type == 2){
            imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectImage = image
            if(self.phototype == 1){
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
            imagePicker.dismiss(animated: true){
                self.performSegue(withIdentifier: "showImageTouch", sender: nil)
            }
        }else {
            imagePicker.dismiss(animated: true, completion: nil)
        }
           
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

