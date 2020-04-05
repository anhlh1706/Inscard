//
//  CardView.swift
//  InsCard
//
//  Created by Lê Hoàng Anh on 4/4/20.
//  Copyright © 2020 Lê Hoàng Anh. All rights reserved.
//

import UIKit

extension UIView {
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while responder is UIView {
            responder = responder!.next
        }
        return responder as? UIViewController
    }
    
    func selfCapture(frame: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.translateBy(x: frame.origin.x * -1, y: frame.origin.y * -1)
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

final class CardView: UIView {
    @IBOutlet private var labels: [UILabel]!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var smallProfileImageView: UIImageView!
    @IBOutlet private weak var plusImageView: UIImageView!
    
    private let shadowLayer = CAShapeLayer()
    private var updatingImageView: UIImageView?
    private var originalTouchPoint: CGPoint = .zero
    private var translation = CGPoint(x: 0, y: 0)
    private var lastPoint: CGFloat = 0
    
    var updateBackgroundImage: ((UIImage?) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labels.forEach { $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editText(_:)))) }
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editProfileImage)))
        backgroundImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editProfileImage)))
        
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panned(recognizer:))))
        
        plusImageView.layer.borderWidth = 1.5
        plusImageView.layer.borderColor = UIColor.white.cgColor
        smallProfileImageView.layer.borderWidth = 1.5
        smallProfileImageView.layer.borderColor = UIColor.white.cgColor
    }
    
    override func layoutSubviews() {
        shadowLayer.removeFromSuperlayer()
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 30).cgPath
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.fillColor = UIColor.clear.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 0, height: 4)
        shadowLayer.shadowOpacity = 0.8
        shadowLayer.shadowRadius = 18
        layer.insertSublayer(shadowLayer, at: 0)
    }
}

private extension CardView {
    //TODO: Move and resize view
    @objc func panned(recognizer: UIPanGestureRecognizer) {
        let touchPoint = recognizer.location(in: self)
        switch recognizer.state {
        case .began:
            originalTouchPoint = touchPoint
        case .changed:
            guard let corner = getCornerOfPoint(originalTouchPoint) else { return }
            switch corner {
            case .layerMinXMinYCorner:
//                translation = CGPoint(x: touchPoint.x - originalTouchPoint.x, y: touchPoint.y - originalTouchPoint.y)
//                transform = CGAffineTransform(translationX: 0, y: translation.y)
                lastPoint = touchPoint.y
            case .layerMinXMaxYCorner:
                print("xy")
            case .layerMaxXMinYCorner:
                print("yx")
            case .layerMaxXMaxYCorner:
                print("yy")
            default:
                break
            }
        case .ended, .cancelled:
            frame.origin.x += translation.x
            frame.origin.y += translation.y
            transform = .identity
            translation = .zero
        default:
            break
        }
    }
    
    func getCornerOfPoint(_ point: CGPoint) -> CACornerMask? {
        switch (point.x, point.y) {
        case (0...30, 0...30):
            return CACornerMask.layerMinXMinYCorner
        case (0...30, (bounds.maxY-30...bounds.maxY)):
            return CACornerMask.layerMinXMaxYCorner
        case ((bounds.maxX-30...bounds.maxY), 0...30):
            return CACornerMask.layerMaxXMinYCorner
        case ((bounds.maxX-30...bounds.maxY), (bounds.maxX-30...bounds.maxY)):
            return CACornerMask.layerMaxXMaxYCorner
        default:
            return nil
        }
    }
    
    @objc func editText(_ sender: UITapGestureRecognizer) {
        guard let senderView = sender.view as? UILabel else { return }
        let alert = UIAlertController(title: nil, message: "Enter new text", preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "New text"
        }
        alert.addCancelAction()
        alert.addOkAction {
            senderView.text = alert.textFields?.first?.text
        }
        parentViewController?.present(alert, animated: true, completion: nil)
    }
    
    @objc func editProfileImage(_ sender: UITapGestureRecognizer) {
        updatingImageView = sender.view as? UIImageView
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(title: "From library") {
            self.showPicker(sourceType: .photoLibrary)
        }
        
        alert.addAction(title: "Take new photo") {
            self.showPicker(sourceType: .camera)
        }
        
        alert.addCancelAction()
        
        parentViewController?.present(alert, animated: true, completion: nil)
    }
    
    func showPicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        parentViewController?.present(imagePicker, animated: true, completion: nil)
    }
    
    func updateImage(_ image: UIImage) {
        let imageSize = CGSize(width: 250, height: 250)
        let resizedImage = image.scaleToFit(size: imageSize)
        
        updatingImageView?.image = resizedImage
        
        if updatingImageView == backgroundImageView {
            updateBackgroundImage?(resizedImage)
        } else {
            smallProfileImageView.image = resizedImage
        }
    }
}

//MARK: UIPickerControllerDelegate
extension CardView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[.editedImage] as? UIImage {
            updateImage(pickedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
