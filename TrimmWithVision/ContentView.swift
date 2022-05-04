//
//  ContentView.swift
//  TrimmWithVision
//
//  Created by Diego Castro on 02/05/22.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation
import SwiftUI
import Vision

struct ContentView: View {
    
    @State private var faceCountLabel: String = ""
    @State private var showImagePicker: Bool = false
    @State private var inputImage: UIImage?
    @State private var image: Image?
    
    func getImage () {
        guard let inputImage = inputImage else {
            return
        }
        image = Image (uiImage: inputImage)
    }
    
    
    func faceDetection(completion: @escaping ([VNFaceObservation]?) -> Void) {
        
        guard let image=inputImage,
              let ciImage = CIImage(image: image),
              let cgImage=CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent ),
              let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)) else {
            return completion (nil)
        }
        
        let request = VNDetectFaceRectanglesRequest()
        
        let handler = VNImageRequestHandler(cgImage: cgImage,orientation: orientation, options: [:])
        
        DispatchQueue.global().async {
            try? handler.perform([request])
            guard let observedResults = request.results else {
                return completion(nil)
            }
            return completion(observedResults)
        }
        
    }
    
    var body: some View {
        VStack {
            Text ("Face Detection")
                .font(.system(size: 34))
                .fontWeight(.heavy)
            Spacer()
            
            Divider ()
            
      
                image?
                    .resizable()
                    .scaledToFit()
            Spacer()
            
            
            
            Divider()
            
            Button {
                showImagePicker = true
                self.faceCountLabel = ""
                
            } label: {
                Text ("Choose picture")
            }
            .padding()
            .foregroundColor(Color.white)
            .background(Color.blue)
            .cornerRadius(8)
            
            
            Button {
                
                self.faceDetection { results in
                    if let results = results {
                        if results.count == 1 {
                        self.faceCountLabel = "\(results.count) face detected"
                        } else {
                            self.faceCountLabel = "\(results.count) faces detected"
                        }
                        
                    } else {   self.faceCountLabel = "Faces not detected"}
                    
                }
            } label: {
                Text ("Face Count")
            }
            .padding()
            .foregroundColor(Color.white)
            .background(Color.blue)
            .cornerRadius(8)
            
            Text (self.faceCountLabel)
            
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $inputImage)
        }
        .onChange(of: inputImage) { _ in getImage() }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
