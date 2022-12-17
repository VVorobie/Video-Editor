//
//  Combi3.swift
//  Video Editor
//
//  Created by Владимир Воробьев on 12.12.2022.
//

import Foundation
import GPUImage


//comb3
class ImageHueFilter: FilterMaker {
    
    // This filter is combined from three GPU Filters:
    
//   1. GPUImageHueFilter: Adjusts the hue of an image
//
//    hue: The hue angle, in degrees. 90 degrees by default
    
//    2. GPUImageSaturationFilter: Adjusts the saturation of an image
//
//    saturation: The degree of saturation or desaturation to apply to the image (0.0 - 2.0, with 1.0 as the default)
    
//    3. GPUImageHighlightShadowFilter: Adjusts the shadows and highlights of an image
//
//    shadows: Increase to lighten shadows, from 0.0 to 1.0, with 0.0 as the default.
//    highlights: Decrease to darken highlights, from 1.0 to 0.0, with 1.0 as the default.
    
    func createFilters()-> [GPUImageFilter] {
        let filter1 = GPUImageHueFilter()
        filter1.hue  = 45
        let filter2 = GPUImageSaturationFilter()
        filter2.saturation = 2
        let filter3 = GPUImageHighlightShadowFilter()
        filter3.highlights = 0.5
        filter3.shadows = 0.5
        return [filter1, filter2, filter3]
    }
    
    func getFilteredImage(original image: UIImage) -> UIImage {
        let filters = createFilters()
        let picture = GPUImagePicture(image: image)
        picture?.addTarget(filters[0])
        filters[0].addTarget(filters[1])
        filters[1].addTarget(filters[2])
        filters[2].useNextFrameForImageCapture()
        picture?.processImage()
        return filters[2].imageFromCurrentFramebuffer()
    }
    
}
