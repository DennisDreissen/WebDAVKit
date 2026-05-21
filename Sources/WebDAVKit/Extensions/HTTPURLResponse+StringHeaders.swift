//
//  HTTPURLResponse+StringHeaders.swift
//  WebDAVKit
//
//  Created by Dennis Dreissen on 17/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension HTTPURLResponse {

    var stringHeaders: [String: String] {
        Dictionary(uniqueKeysWithValues: allHeaderFields.compactMap { key, value in
            guard let k = key as? String, let v = value as? String else {
                return nil
            }

            return (k, v)
        })
    }
}
