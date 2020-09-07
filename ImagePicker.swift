//
//  ImagePicker.swift
//  FilterGram
//
//  Created by Chloe Fermanis on 3/9/20.
//  Copyright © 2020 Chloe Fermanis. All rights reserved.
//
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presenationMode
    @Binding var image: UIImage?
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

        var parent: ImagePicker
    
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presenationMode.wrappedValue.dismiss()
        }
    }
        
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
        
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
        
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    
    }
    
    // typealias UIViewControllerType = UIImagePickerController

    
}
        

    

        
    

    
    
    
            

    
    
