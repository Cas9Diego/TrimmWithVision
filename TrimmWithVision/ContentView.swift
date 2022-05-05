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
    @State private var boundingBoxesArray:[CGRect]?
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
            ForEach((0...boundingBoxesArray!.count-1), id: \.self)  {
                return  Rectangle()
                    .path(in: CGRect(
                        x: boundingBoxesArray![$0].minX * geometry.size.width,
                        y: boundingBoxesArray![$0].minY * geometry.size.height,
                        width: boundingBoxesArray![$0].width * geometry.size.width,
                        height: boundingBoxesArray![$0].height * geometry.size.height))
                    .stroke(Color.yellow, lineWidth: 1.5)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                
                Divider ()
                
                if faceCountLabel == "" || faceCountLabel == "0"  {
                    GeometryReader { geo in
                        image?
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geo.size.width * 0.95)
                            .frame(width: geo.size.width, height: geo.size.height)
                        //                        .frame(width: UIScreen.main.bounds.width*3/4,
                        //                               height: UIScreen.main.bounds.height*3/4,
                        //                               alignment: .center)
                        
                    }
                }
                else {
                    GeometryReader { geo in
                        ZStack {
                            image?
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geo.size.width * 0.95)
                                .frame(width: geo.size.width, height: geo.size.height)
                        }
                        
                        drawBoundingBoxes(geometry: geo)
                        
                        
                        
                    }
                }
                
                Spacer()
                
                Divider()
                
                HStack {
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
                            if let results = results{
                                var boundingBoxes: [CGRect] = []
                                
                                if results.count == 1 {
                                    boundingBoxes.append(results[0].boundingBox)
                                } else if results.count > 1 {
                                    for i in 0...results.count-1 {
                                        boundingBoxes.append(results[i].boundingBox)
                                    }
                                }
                                
                                self.boundingBoxesArray = boundingBoxes
                                
                                if results.count == 1 {
                                    self.faceCountLabel = "\(results.count)"
                                    
                                } else {
                                    self.faceCountLabel = "\(results.count)"
                                    
                                }
                                
                            } else {   self.faceCountLabel = "Faces not detected"}
                            
                        }
                    } label: {
                        Text ("Scan")
                    }
                    .padding()
                    .foregroundColor(Color.white)
                    .background(Color.green)
                    .cornerRadius(8)
                    
                }
                .padding(.bottom, 10)
                .padding(.top, 10)
                if image != nil {
                    if self.faceCountLabel == "" {
                        Text ("Tap the Scan Button")
                    } else if self.faceCountLabel == "0" {
                        Text ("Detected faces: 0")
                            .padding(.bottom)
                    } else {
                        Text ("Detected faces: \(self.faceCountLabel)")
                            .padding(.bottom)
                    }
                } else {
                    Text ("No pictures found")
                        .padding(.bottom)
                }
                
            }
            .sheet(isPresented: $showImagePicker) {
                
                ImagePicker(image: $inputImage)
                
            }
            .onChange(of: inputImage) { _ in getImage() }
            .navigationTitle("Face detection")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        faceCountLabel = ""
                        image = nil
                    } label: {
                        Image(systemName: "arrow.uturn.left.circle")
                    }
                }
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
