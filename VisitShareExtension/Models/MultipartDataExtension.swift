//
//  MultipartDataExtension.swift
//  JustAMultipartRequest
//
//  Created by JustMacApps.net on 09/10/2024.
//  Copyright © 2023-2026 JustMacApps. All rights reserved.
//

import Foundation

public extension Data 
{

    mutating func append(_ string:String, encoding:String.Encoding = .utf8) 
    {

        guard let data = string.data(using:encoding) 
        else { return }

        append(data)

        return

    }   // End of mutating func append(string:, encoding:)

}   // End of public extension Data.

