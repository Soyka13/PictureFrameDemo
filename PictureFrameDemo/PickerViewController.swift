//
//  PickerViewController.swift
//  PictureFrameDemo
//
//  Created by Olena Stepaniuk on 24.05.2021.
//

import UIKit
import Then
import SnapKit

class PickerViewController: UIViewController {
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        showImagePicker()
    }
}

extension PickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func showImagePicker() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .fullScreen
        imagePicker.delegate = self
        
        present(imagePicker, animated: false, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        imagePicker.dismiss(animated: false, completion: nil)
        let vc = ARViewController(objectImage: image)
        navigationController?.pushViewController(vc, animated: false)
    }
}
