//
//  FilterMaker.swift
//  Video Editor
//
//  Created by Владимир Воробьев on 29.11.2022.
//

import Foundation
import GPUImage

protocol FilterMaker {
    func createFilters () -> [GPUImageFilter]
    
    func getFilteredImage(original image: UIImage) -> UIImage

}

enum Filters: String {

    
    case brightness = "Яркость"
    case combi3 = "Оттенок"
    case pixellation = "Зернистость"
    case comby2  = "Тиснение"
    

}

extension Filters: FilterMaker {

    func createFilters() -> [GPUImageFilter] {
        switch self {
        case .brightness:
            return ImageBrightnessFilter().createFilters()
        case .combi3:
            return ImageHueFilter().createFilters()
        case .pixellation:
            return ImagePixellateFilter().createFilters()
        case .comby2:
            return ImageEmbossFilter().createFilters()
        }
    }
    
    func getFilteredImage(original image: UIImage) -> UIImage {
        switch self {
        case .brightness:
            return ImageBrightnessFilter().getFilteredImage(original: image)
        case .combi3:
            return ImageHueFilter().getFilteredImage(original: image)
        case .pixellation:
            return ImagePixellateFilter().getFilteredImage(original: image)
        case .comby2:
            return ImageEmbossFilter().getFilteredImage(original: image)
        }
    }
}
    
    











