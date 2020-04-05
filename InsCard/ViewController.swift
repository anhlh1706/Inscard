//
//  ViewController.swift
//  InsCard
//
//  Created by Lê Hoàng Anh on 4/4/20.
//  Copyright © 2020 Lê Hoàng Anh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var gradientImageView: UIImageView!
    
    private lazy var cardView: CardView = {
        let bundle = Bundle.main
        let nib = bundle.loadNibNamed("CardView", owner: nil, options: [:])?.first as? CardView
        nib?.updateBackgroundImage = updateBackground
        return nib ?? CardView()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: view.topAnchor, constant: 90),
            cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -180),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
        ])
    }
}

private extension ViewController {
    
    func updateBackground(_ image: UIImage?) {
        gradientImageView.image = image
    }
    
    @IBAction func saveImage(_ sender: Any) {
        if let finalImage = view.selfCapture(frame: view.bounds) {
            UIImageWriteToSavedPhotosAlbum(finalImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        AlertService.show(in: self, msg: error?.localizedDescription ?? "Saved!")
    }
}
