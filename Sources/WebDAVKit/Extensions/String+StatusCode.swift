//
//  String+StatusCode.swift
//  WebDAVKit
//
//  Created by Dennis Dreissen on 14/11/2026.
//  Copyright © 2026 Dennis Dreissen
//

extension String {

    var isSuccessfulHTTPStatus: Bool {
        let parts = split(separator: " ")

        guard parts.count >= 2, let code = Int(parts[1]) else {
            return false
        }

        return (200..<300).contains(code)
    }
}
