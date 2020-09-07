//
//  ContentView.swift
//  FilterGram
//
//  Created by Chloe Fermanis on 3/9/20.
//  Copyright © 2020 Chloe Fermanis. All rights reserved.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    
    @State private var image: Image?
    
    @State private var filterIntensity = 0.5
    @State private var filterRadius = 0.5
    @State private var filterScale = 50.0
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    @State private var showingFilterSheet = false
    @State private var filterName = "Sepia Tone"
    
    @State private var imageLoaded = false
    @State private var showImageAlert = false
    
    var body: some View {
        
        let intensity = Binding<Double>(
            get: {
                self.filterIntensity
        },
            set: {
                self.filterIntensity = $0
                self.applyProcessing()
        })
        
        let radius = Binding<Double>(
            get: {
                self.filterRadius
        },
            set: {
            self.filterRadius = $0
            self.applyProcessing()
        })
        
        let scale = Binding<Double>(
                get: {
                    self.filterScale
            },
                set: {
                self.filterScale = $0
                self.applyProcessing()
            })
        
        return NavigationView {
            
            VStack {
                
                ZStack {
                    
                    Rectangle()
                        .fill(Color.secondary)
                    
                    if image != nil {
                        image?
                            .resizable()
                            .scaledToFit()
                    }
                    else  {
                        Text("Tap to select a picture")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .onTapGesture {
                    self.showingImagePicker = true
                }
                
                HStack {
                    Text("Intensity")
                    Slider(value: intensity)
                }
                .padding(.vertical)
    
                HStack {
                    Text("Radius")
                    Slider(value: radius)
                }
                .padding(.vertical)
                
                HStack {
                    Text("Scale")
                    Slider(value: scale)
                }
                .padding(.vertical)
    
                HStack {
                    Button(action: {
                        self.showingFilterSheet = true
                        
                    }) {
                        Text("\(filterName)")
                    }
                    .buttonStyle(GradientBackgroundStyle())
                    
                    Button(action: {
                        
                        if self.imageLoaded {
                        
                            guard let processedImage = self.processedImage else { return }
                            let imageSaver = ImageSaver()
                            imageSaver.writeToPhotoAlbum(image: processedImage)
                        
                            imageSaver.successHandler = {
                                print("Success!")
                            }
                
                            imageSaver.errorHandler = {
                                print("Oops: \($0.localizedDescription)")
                            }
                            
                        } else {
                            self.showImageAlert = true
                        }
                    })
                    {
                        Text("Save")
                        
                    }
                    .alert(isPresented: $showImageAlert) {
                        Alert(title: Text("Error:"), message: Text("Image has not been loaded, please select an image"), dismissButton: .default(Text("OK")))
                    }
                    .buttonStyle(GradientBackgroundStyle())
                }
                
            }
            .padding([.horizontal, .bottom])
            .navigationBarTitle("FilterGram", displayMode: .inline)
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
            .actionSheet(isPresented: $showingFilterSheet) {
                // action sheet here
                ActionSheet(title: Text("Select a filter"), buttons: [
                    .default(Text("Color Posterize")) {
                        self.filterName = "Color Posterize"
                        self.setFilter(CIFilter.colorPosterize()) },
                    .default(Text("Edges")) {
                        self.filterName = "Edges"
                        self.setFilter(CIFilter.edges()) },
                    .default(Text("Gaussian Blur")) {
                        self.filterName = "Gaussian Blur"
                        self.setFilter(CIFilter.gaussianBlur()) },
                    .default(Text("Pixellate")) {
                        self.filterName = "Pixellate"
                        self.setFilter(CIFilter.pixellate()) },
                    .default(Text("Sepia Tone")) {
                        self.filterName = "Sepia Tone"
                        self.setFilter(CIFilter.sepiaTone()) },
                    .default(Text("Unsharp Mask")) {
                        self.filterName = "Unsharp Mask"
                        self.setFilter(CIFilter.unsharpMask()) },
                    .default(Text("Vignette")) {
                        self.filterName = "Vignette"
                        self.setFilter(CIFilter.vignette()) },
                    .cancel()
                ])
            }
            
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }

        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
        self.imageLoaded = true

    }
    
    func applyProcessing() {
        
        //currentFilter.intensity = Float(filterIntensity)'                                                                                                                                                   
        // currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputScaleKey) }
        
        guard let outputImage = currentFilter.outputImage else { return }

        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
    
}

struct GradientBackgroundStyle: ButtonStyle {
 
    func makeBody(configuration: Self.Configuration) -> some View {
        
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(15)
            .foregroundColor(.white)
            .background(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(40)
            .padding(.horizontal, 10)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
