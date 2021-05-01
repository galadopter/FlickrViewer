//
//  NetworkService.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 29.04.21.
//

import Foundation

class NetworkService<API: RequestType> {
    
    let network: Network<API>
    
    init(network: Network<API> = Network()) {
        self.network = network
    }
}
