//
//  Pixellation.swift
//  Video Editor
//
//  Created by Владимир Воробьев on 12.12.2022.
//

import Foundation
import GPUImage

class ImagePixellateFilter: FilterMaker {
//    GPUImagePixellateFilter: Applies a pixellation effect on an image or video
//
//    fractionalWidthOfAPixel: How large the pixels are, as a fraction of the width and height of the image (0.0 - 1.0, default 0.05)
    
    func createFilters()-> [GPUImageFilter] {
        let filter = GPUImagePixellateFilter()
        filter.fractionalWidthOfAPixel = 0.005
        return [filter]
    }
    
    func getFilteredImage(original image: UIImage) -> UIImage {
        return createFilters()[0].image(byFilteringImage: image)
    }

}
