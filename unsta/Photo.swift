//
//  Photos.swift
//  unsta
//
//  Created by Islam on 31.05.17.
//  Copyright © 2017 ZeroToOneLabs. All rights reserved.
//

import Foundation
import Alamofire

class Photo: NSObject {
    
    var url: String?
    
    init(url: String) {
        self.url = url
    }
    
    static func fetchPhotoBy(username: String?, completion: @escaping (([Photo]?, String?) -> Void)) {
        guard let username = username else { return }
        let parameters: [String: Any] = [
            "SearchForm[username]" : username,
            "SearchForm[maxid]" : "",
            "SearchForm[token]" : "token",
            ]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            for (key, value) in parameters {
                guard let data = (value as AnyObject).data(using: String.Encoding.utf8.rawValue, allowLossyConversion: true) else { continue }
                multipartFormData.append(data, withName: key)
            }
            
            
        }, to: "https://unsta.me/site/show/") { result in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    print(progress)
                })
                upload.responseJSON { response in
                    if response.result.isSuccess {
                        guard let json = response.result.value as? [String: AnyObject],
                            let code =  json["code"] as? Int else {
                                completion(nil, "Incorrect data format")
                                return
                        }
                        var urls: [Photo] = []
                        if let photos = json["photos"] as? [[String: AnyObject]], code == 0 {
                            photos.map {
                                if let url = $0["url"] {
                                    let photoUrl = Photo(url: url as! String)
                                    urls.append(photoUrl)
                                } else {
                                    completion(nil, "sadads")
                                }
                                completion(urls, nil)
                            }
                        }
                        
                    }
                }
            case .failure(let encodingError):
                completion(nil, encodingError.localizedDescription)
            }
        }
    }
}
