//
//  Comby2.swift
//  Video Editor
//
//  Created by Владимир Воробьев on 12.12.2022.
//

import Foundation
import GPUImage

//combi2 - combination from two filters from group "Visual effects"
class ImageEmbossFilter: FilterMaker {
    
    // This filter is combined from two GPU filters of groupe Visual Effects
    
    //        1. GPUImageEmbossFilter: Applies an embossing effect on the image
    //
    //        intensity: The strength of the embossing, from 0.0 to 4.0, with 1.0 as the normal level
    
//    2. GPUImagePosterizeFilter: This reduces the color dynamic range into the number of steps specified, leading to a cartoon-like simple shading of the image.
//
//    colorLevels: The number of color levels to reduce the image space to. This ranges from 1 to 256, with a default of 10.
//
    

    func createFilters()-> [GPUImageFilter] {
        let filter1 = GPUImageEmbossFilter()
        filter1.intensity = 1.5
        let filter2 = GPUImagePosterizeFilter()
        filter2.colorLevels = 100
        return [filter1, filter2]
    }
    
    func getFilteredImage(original image: UIImage) -> UIImage {
        let filters = createFilters()
        let picture = GPUImagePicture(image: image)
        picture?.addTarget(filters[0])
        filters[0].addTarget(filters[1])
        filters[1].useNextFrameForImageCapture()
        picture?.processImage()
        return filters[1].imageFromCurrentFramebuffer()
    }
    

}
