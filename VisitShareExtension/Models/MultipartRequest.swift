//
//  MultipartRequest.swift
//  JustAMultipartRequest
//
//  Created by JustMacApps.net on 09/10/2024.
//  Copyright © 2023-2026 JustMacApps. All rights reserved.
//

import Foundation

public struct MultipartRequest
{
    
    struct ClassInfo
    {
        static let sClsId          = "MultipartRequest"
        static let sClsVers        = "v1.0201"
        static let sClsDisp        = sClsId+"(.swift).("+sClsVers+"):"
        static let sClsCopyRight   = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace       = true
        static let bClsFileLog     = true
    }

    // App Data field(s):

    public  let boundary:String
    private let separator:String = "\r\n"
    private var data:Data

    public  var httpContentTypeHeaderValue:String 
    {
        return "multipart/form-data; boundary=\(boundary)"
    }

    public  var httpBody:Data
    {
        var bodyData = data

        bodyData.append("--\(boundary)--")

        return bodyData
    }

    public init(boundary:String = UUID().uuidString)
    {

        self.boundary = boundary
        self.data     = .init()

        return

    }   // End of public init(boundary:).
    
    private mutating func appendBoundarySeparator() 
    {

        data.append("--\(boundary)\(separator)")

        return

    }   // End of private mutating func appendBoundarySeparator().
    
    private mutating func appendSeparator() 
    {

        data.append(separator)

        return

    }   // End of private mutating func appendSeparator().

    private func disposition(_ key:String) -> String 
    {

        return "Content-Disposition: form-data; name=\"\(key)\""

    }   // End of private func disposition(key:) -> String.

    public mutating func add(key:String, value:String) 
    {

        appendBoundarySeparator()

        data.append(disposition(key)+separator)

        appendSeparator()

    //  data.append(value+separator)
        data.append("\(key)=\(value)\(separator)")

        return

    }   // End of public mutating func add(key:,value:).

    public mutating func add(key:String, fileName:String, fileMimeType:String, fileData:Data) 
    {

        appendBoundarySeparator()

        data.append(disposition(key)+"; filename=\"\(fileName)\""+separator)
        data.append("Content-Type: \(fileMimeType)"+separator+separator)
        data.append(fileData)

        appendSeparator()

        return

    }   // End of public mutating func add(key:,fileName:,fileMimeType:,fileData:).

}   // End of public struct MultipartRequest.

