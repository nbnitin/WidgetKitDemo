//
//  ApodImageProvider.swift
//  WidgetIntentConfigDemo
//
//  Created by Nitin Bhatia on 29/11/22.
//

import Foundation
import SwiftUI

enum ApodImageResponse {
    case Success(image: UIImage, title: String)
    case Failure
}

struct ApodApiResponse: Decodable {
    var url: String
    var title: String
}

class ApodImageProvider {
    static func getImageFromApi(completion: ((ApodImageResponse) -> Void)?) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let date = Date()
        //let urlString = "https://api.nasa.gov/planetary/apod?api_key=eaRYg7fgTemadUv1bQawGRqCWBgktMjolYwiRrHK&date=\(formatter.string(from: date))"
        let urlString = "https://jsonplaceholder.typicode.com/photos"
        
        let url = URL(string: urlString)!
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            parseResponseAndGetImage(data: data, urlResponse: urlResponse, error: error, completion: completion)
        }
        task.resume()
    }
    
    static func parseResponseAndGetImage(data: Data?, urlResponse: URLResponse?, error: Error?, completion: ((ApodImageResponse) -> Void)?) {
        
        guard error == nil, let content = data else {
            print("error getting data from API")
            let response = ApodImageResponse.Failure
            completion?(response)
            return
        }
        
        var apodApiResponse: [ApodApiResponse]
        //var apodApiResponse : ApodApiResponse
        do {
            apodApiResponse = try JSONDecoder().decode([ApodApiResponse].self, from: content)
            //apodApiResponse = try JSONDecoder().decode(ApodApiResponse.self, from: content)
        } catch {
            print("error parsing URL from data")
            let response = ApodImageResponse.Failure
            completion?(response)
            return
        }
        
        let url = /*URL(string: apodApiResponse.url)!*/ URL(string: apodApiResponse.first!.url)!
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            parseImageFromResponse(data: data, urlResponse: urlResponse, error: error, apodApiResponse: apodApiResponse.first! /*apodApiResponse*/, completion: completion) //apodApiResponse.first!
        }
        task.resume()
        
    }
    
    static func parseImageFromResponse(data: Data?, urlResponse: URLResponse?, error: Error?, apodApiResponse: ApodApiResponse, completion: ((ApodImageResponse) -> Void)?) {
        
        guard error == nil, let content = data else {
            print("error getting image data")
            let response = ApodImageResponse.Failure
            completion?(response)
            return
        }
        
        let image = UIImage(data: content)!
        let response = ApodImageResponse.Success(image: image, title: apodApiResponse.title)
        completion?(response)
    }
}
