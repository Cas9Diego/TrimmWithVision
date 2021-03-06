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
    @State private var boundingBoxes: [CGRect] = []
    var spacerMinLenght: Double = 10
    let textTransitionDuration: Double = 0.3
    
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
              let orientation = inputImage?.imageOrientation.rawValue else {
            return completion (nil)
        }
        
        let request = VNDetectFaceRectanglesRequest()
        request.revision = VNDetectFaceRectanglesRequestRevision3

        
        
        let handler = VNImageRequestHandler(cgImage: cgImage,orientation: getCGOrientationFromUIImage(orientation), options: [:])
        print(inputImage!.imageOrientation.rawValue, "The orientation")
        print((inputImage!.size.height/inputImage!.size.width), "Ratio")
        
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
                    Rectangle()
                    .path(in: CGRect(
                        x: boundingBoxesArray![$0].minX * geometry.size.width,
                        y: boundingBoxesArray![$0].minY * geometry.size.height,
                        width: boundingBoxesArray![$0].width * geometry.size.width,
                        height: boundingBoxesArray![$0].height * geometry.size.height))
                    .stroke(Color.yellow, lineWidth: 1.5)
            }
            
            if (inputImage!.size.height/inputImage!.size.width) == 0.75 {
                
            }
        
        }
    }
    
    
    func getCGOrientationFromUIImage(_ uiOrientationValue: Int?) -> CGImagePropertyOrientation {
//Since the return from the metadata coming from a UIImage is incompatible with the metadata from CGImagePropertyOrientation, a sort of "dictionary" is needed.
        if (inputImage!.size.height/inputImage!.size.width) <= 1 && (inputImage!.size.height/inputImage!.size.width) != 0.75 {
            //This dispossition is the result of a trial and error research about the orientation obtained throught the Image.Orientation feature. Apparetly, with landscape photoes, the orinetaton should be modified in a mirrored way compared to that thrown by the orientation feature.
            switch uiOrientationValue {
            case 0:
                return .downMirrored //Check
            case 1:
                return .upMirrored //Check
            case 2:
                return .right //Check
            case 3:
                return .left //Check
            case 4:
                return .upMirrored
            case 5:
                return .down
            case 6:
                return .rightMirrored
            case 7:
                return .leftMirrored
            @unknown default:
                fatalError()
            }
        }
        else if (inputImage!.size.height/inputImage!.size.width) == 0.75 {
            switch uiOrientationValue {
                //The software seems to have special roblems with pictures having 0.75 ratio
            case 0:
                return .upMirrored //Check
            case 1:
                return .upMirrored //Check
            case 2:
                return .right //Check
            case 3:
                return .left //Check
            case 4:
                return .downMirrored
            case 5:
                return .down
            case 6:
                return .rightMirrored
            case 7:
                return .leftMirrored
            @unknown default:
                fatalError()
            }
        }
        else {
        switch uiOrientationValue {
//            This feature appears to have some kind of problem woth left and right when it comes to portrait photos. Whereas it has a problem with up and down when it comes to landscape photos. The options were deined based on trial and error.
        case 0:
            return .downMirrored //Check
        case 1:
            return .rightMirrored //Check
        case 2:
            return .up //Check
        case 3:
            return .rightMirrored //Check
        case 4:
            return .left
        case 5:
            return .upMirrored
        case 6:
            return .downMirrored
        case 7:
            return .leftMirrored
        @unknown default:
            fatalError()
        }
    }
    }
    
    func roundedRectangleFilled (cornerRadious: Double, width: Double, height: Double, color: Color, alignment: Alignment ) -> some View {
        return RoundedRectangle(cornerRadius: cornerRadious, style: .continuous)
            .fill(color)
            .frame(width: width,
                   height: height,
                   alignment: alignment)
        
    }
    
    func roundedRectangleStroke (cornerRadious: Double, width: Double, height: Double, strokeColor: Color, lineWidth: Double, alignment: Alignment ) -> some View {
        return RoundedRectangle(cornerRadius: cornerRadious, style: .continuous)
            .strokeBorder(strokeColor, lineWidth: lineWidth)
            .frame(width: width,
                   height: height,
                   alignment: alignment)
        
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                
                if image == nil {
                    Button {
                        showImagePicker = true
                        self.faceCountLabel = ""
                    } label: {
                        ZStack {
                            roundedRectangleStroke(cornerRadious: 25, width: UIScreen.main.bounds.width*(9/10), height: UIScreen.main.bounds.height*(2/4), strokeColor: Color(UIColor.lightGray), lineWidth: 8, alignment: .center)
                            
                            roundedRectangleFilled(cornerRadious: 25, width: UIScreen.main.bounds.width*(9/10), height: UIScreen.main.bounds.height*(2/4), color: Color(UIColor.lightGray).opacity(0.2), alignment: .center)
                            
                            VStack {
                                Image(systemName: "plus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.width*1/12,
                                           alignment: .center)
                                
                                Text ("Choose a picture ")
                                    .font(.custom("Arial", size: 20))
                            }
                            
                            
                            
                        }
                    }
                    
                }
                else if faceCountLabel == "" || faceCountLabel == "0" || self.boundingBoxes == [] {
                    ZStack {
                        roundedRectangleStroke(cornerRadious: 25, width: UIScreen.main.bounds.width*(9/10), height: UIScreen.main.bounds.height*(2/4), strokeColor: Color(UIColor.lightGray), lineWidth: 8, alignment: .center)
                        
                        GeometryReader { geo in
                            VStack {

                                Spacer(minLength: spacerMinLenght)
                                image?
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geo.size.width * 0.9)
                                    .frame(width: geo.size.width * 1)
                                
                                Spacer(minLength: spacerMinLenght)
                            }
                            
                        }
                    }
                }
                else {
                    ZStack {
                        roundedRectangleStroke(cornerRadious: 25, width: UIScreen.main.bounds.width*(9/10), height: UIScreen.main.bounds.height*(2/4), strokeColor: Color(UIColor.lightGray), lineWidth: 8, alignment: .center)
                        GeometryReader { geo in
                            VStack {
                                Spacer(minLength: spacerMinLenght)
                                image?
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geo.size.width * 0.9)
                                    .frame(width: geo.size.width * 1)
                                Spacer(minLength: spacerMinLenght)
                            }
                            
                            
                            drawBoundingBoxes(geometry: geo)
                            
                        }
                    }
                }
                
                
                Spacer()
                
                if image != nil {
                    
                    if self.faceCountLabel == "" {
                        Text ("Tap the Scan Button")
                            .font(.custom("Arial", size: 23))
                            .foregroundColor(.green)
                            .padding()
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration: textTransitionDuration)))
                    } else if self.faceCountLabel == "0"  || self.faceCountLabel == "Faces not detected" {
                        Text ("0 faces detected")
                            .font(.custom("Arial", size: 23))
                            .padding()
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration:textTransitionDuration)))
                    }
                    else if self.faceCountLabel == "1" {
                        Text ("\(self.faceCountLabel) face detected")
                            .font(.custom("Arial", size: 23))
                            .foregroundColor(.green)
                            .padding()
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration:textTransitionDuration))) }
                    else {
                        Text ("\(self.faceCountLabel) faces detected")
                            .font(.custom("Arial", size: 23))
                            .foregroundColor(.green)
                            .padding()
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration:textTransitionDuration)))
                    }
                } else {
                    Text ("No picture selected ????")
                        .font(.custom("Arial", size: 23))
                        .foregroundColor(.red)
                        .padding()
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration:textTransitionDuration)))
                }
                
                HStack {
                    
                    Button {
                        if image != nil {
                            self.faceDetection { results in
                                if let results = results{
                                    
                                    if results.count == 1 {
                                        boundingBoxes.append(results[0].boundingBox)
                                    } else if results.count > 1 {
                                        for i in 0...results.count-1 {
                                            boundingBoxes.append(results[i].boundingBox)
                                        }
                                    }
                                    
                                    self.boundingBoxesArray = boundingBoxes
                                    
                                        self.faceCountLabel = "\(results.count)"
                                
                                    
                                } else {   self.faceCountLabel = "Faces not detected"}
                                
                            }
                        }
                    } label: {
                        ZStack {
                            
                            roundedRectangleFilled(cornerRadious: 8, width: UIScreen.main.bounds.width*0.5, height: UIScreen.main.bounds.height*0.07, color: Color(uiColor: .systemGreen), alignment: .center)
                            
                            roundedRectangleStroke(cornerRadious: 8, width: UIScreen.main.bounds.width*0.5, height: UIScreen.main.bounds.height*0.07, strokeColor: Color(uiColor: .systemGray), lineWidth: 1, alignment: .center)
                            
                            Text ("Scan")
                                .font(.system(size: 25))
                        }
                    }
                    .foregroundColor(Color.white)
                    .cornerRadius(8)
                    
                }
                
            }
            .frame(width: UIScreen.main.bounds.width*9/10,
                   height: UIScreen.main.bounds.height*1/4,
                   alignment: .center)
            .sheet(isPresented: $showImagePicker) {
                
                ImagePicker(image: $inputImage)
                
            }
            .onChange(of: inputImage) { _ in getImage() }
            .navigationTitle("Face detection")
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        faceCountLabel = ""
                        showImagePicker = true
                        self.faceCountLabel = ""
                        self.boundingBoxes = []
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        faceCountLabel = ""
                        image = nil
                        self.boundingBoxes = []
                    } label: {
                        Image(systemName: "minus.circle")
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
