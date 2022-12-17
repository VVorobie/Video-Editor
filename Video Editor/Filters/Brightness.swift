//
//  Brightness.swift
//  Video Editor
//
//  Created by Владимир Воробьев on 12.12.2022.
//

import Foundation
import GPUImage

//Brightness
class ImageBrightnessFilter: FilterMaker {

//    GPUImageBrightnessFilter: Adjusts the brightness of the image
//
//    brightness: The adjusted brightness (-1.0 - 1.0, with 0.0 as the default)
    
    func createFilters()-> [GPUImageFilter] {
        let filter = GPUImageBrightnessFilter()
        filter.brightness  = 0.2
        return [filter]
    }
    
    func getFilteredImage(original image: UIImage) -> UIImage {
        return createFilters()[0].image(byFilteringImage: image)
    }
}
