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
import CoreGraphics

struct ContentView: View {
    
    @State private var faceCountLabel: String = ""
    @State private var showImagePicker: Bool = false
    @State private var inputImage: UIImage?
    @State private var image: Image?
    @State private var countedBoundingBoxes:[CGRect]?
    @State private var geometryOfImage:GeometryProxy?
    
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
    
    func drawBoundingBoxes(geometry: GeometryProxy) -> some View  {
   return   ZStack {
        ForEach((0...countedBoundingBoxes!.count-1), id: \.self)  {
          return  Rectangle()
                .path(in: CGRect(
                  x: countedBoundingBoxes![$0].minX * geometry.size.width,
                    y: countedBoundingBoxes![$0].minY * geometry.size.height,
                    width: countedBoundingBoxes![$0].width * geometry.size.width,
                    height: countedBoundingBoxes![$0].height * geometry.size.height))
                .stroke(Color.red, lineWidth: 2.0)
    }
        }
    }
    
    var body: some View {
        VStack {
            Text ("Face Detection")
                .font(.system(size: 34))
                .fontWeight(.heavy)
            Spacer()
            
            Divider ()
            
           if faceCountLabel == "" || faceCountLabel == "0 faces detected"  {
                image?
                    .resizable()
                    .scaledToFit()
            }
            else {
                image?
                    .resizable()
                    .scaledToFit()
                    .overlay(

                                  GeometryReader { geometry in
                      
                                         drawBoundingBoxes(geometry: geometry)
                                   
                                      Rectangle()
                                          .path(in: CGRect(
                                            x: countedBoundingBoxes![0].minX * geometry.size.width,
                                              y: countedBoundingBoxes![0].minY * geometry.size.height,
                                              width: countedBoundingBoxes![0].width * geometry.size.width,
                                              height: countedBoundingBoxes![0].height * geometry.size.height))
                                          .stroke(Color.red, lineWidth: 2.0)

                                  }
                          )
            }
        
            
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
//                    print(results?[1].boundingBox, "BoundingBox results")
                    if let results = results{
                        var boundingBoxes: [CGRect] = []
                        
                        if results.count == 1 {
                            boundingBoxes.append(results[0].boundingBox)
                        } else if results.count > 1 {
                        for i in 0...results.count-1 {
                            boundingBoxes.append(results[i].boundingBox)
                        }
                        }
                        
                        self.countedBoundingBoxes = boundingBoxes
                        
                        if results.count == 1 {
                        self.faceCountLabel = "\(results.count) face detected"
//                            self.drawBoundingBoxes()
                        } else {
                            self.faceCountLabel = "\(results.count) faces detected"
//                            self.drawBoundingBoxes()
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
