//
//  AppXmlToJsonConverter.swift
//  SpreadsheetML Viewer
//
//  Converts XML to JSON when spreadsheet parsing fails
//  v1.0300 - Fallback for non-spreadsheet XML files
//

import Foundation
import XMLCoder

// Converter for XML to JSON fallback display
// Used when XML file is not a spreadsheet or parsing returns empty results

class AppXmlToJsonConverter
{
    
    struct ClassInfo
    {
        static let sClsId        = "AppXmlToJsonConverter"
        static let sClsVers      = "v1.0201"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    // MARK: - Properties...
    
               private let xmlDecoder:XMLDecoder
               private let jsonEncoder:JSONEncoder
    
    // MARK: - Initialization...
    
    init() 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")
        
        // Configure XML decoder...

        self.xmlDecoder = XMLDecoder()

        xmlDecoder.shouldProcessNamespaces = false
        xmlDecoder.trimValueWhitespaces    = true
        
        // Configure JSON encoder for readable output...

        self.jsonEncoder = JSONEncoder()

        jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        
        appLogMsg("\(sCurrMethodDisp) Exiting - Initialization complete...")

        return

    }   // End of init().
    
    // MARK: - Public Methods...
    
    func convertXMLToDictionary(xmlData:Data)->[String:Any]? 
    {

        // Attempts to convert XML Data to a dictionary representation
        //     - Parameter 'xmlData': The raw XML data
        //     - Returns:             Dictionary representation if successful, nil otherwise

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'xmlData' is [\(xmlData)]...")
        appLogMsg("\(sCurrMethodDisp) Intermediate - Attempting to convert XML (Data) to dictionary...")
        
        guard let xmlString = String(data:xmlData, encoding:.utf8) 
        else 
        {
            appLogMsg("\(sCurrMethodDisp) Exiting - Failed to convert (XML) Data to a String - Error!")

            return nil
        }
        
        appLogMsg("\(sCurrMethodDisp) Intermediate - Input XML string length: #(\(xmlString.count)) characters...")
        
        // Try to parse as generic XML structure...

        do 
        {
            // Use XMLCoder to decode into a generic structure...

            let result     = try xmlDecoder.decode(GenericXMLElement.self, from:xmlData)
            let dictionary = result.toDictionary()
            
            appLogMsg("\(sCurrMethodDisp) Intermediate - Successfully converted XML Data to dictionary...")
            appLogMsg("\(sCurrMethodDisp) Intermediate -   Dictionary has #(\(dictionary.keys.count)) top-level keys...")
            
            return dictionary
            
        } 
        catch
        {
            appLogMsg("\(sCurrMethodDisp) Intermediate - Failed to convert XML Data to dictionary - Failure: [\(error.localizedDescription)] - Error!")
            
            return nil
        }

    }   // End of func convertXMLToDictionary(xmlData:Data)->[String:Any]?.
    
    func convertXMLToJSONString(xmlData:Data)->String?
    {

        // Converts XML Data to formatted JSON string
        //     - Parameter 'xmlData': The raw XML data
        //     - Returns:             Formatted JSON string if successful, nil otherwise

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'xmlData' is [\(xmlData)]...")
        appLogMsg("\(sCurrMethodDisp) Intermediate - Converting XML (Data) to JSON string...")
        
        guard let dictionary = convertXMLToDictionary(xmlData:xmlData)
        else 
        {
            appLogMsg("\(sCurrMethodDisp) Intermediate - Failed to get a dictionary from XML (Data) - Error!...")

            return nil
        }
        
        do 
        {
            let jsonData = try JSONSerialization.data(withJSONObject:dictionary, options:[.prettyPrinted, .sortedKeys])
            
            guard let jsonString = String(data:jsonData, encoding:.utf8) 
            else 
            {
                appLogMsg("\(sCurrMethodDisp) Intermediate - Failed to convert JSON data to string - Error!")

                return nil
            }
            
            appLogMsg("\(sCurrMethodDisp) Intermediate - Successfully converted to JSON string of length: #(\(jsonString.count)) characters...")
            
            return jsonString
        } 
        catch 
        {
            appLogMsg("\(sCurrMethodDisp) Intermediate - Failed to serialize JSON to a string - Failure: [\(error.localizedDescription)] - Error!")

            return nil
        }

    }   // End of func convertXMLToJSONString(xmlData:Data)->String?.
    
    func getDisplayItems(xmlData:Data)->[JsonDisplayItem]
    {

        // Gets display items for SwiftUI list presentation
        //     - Parameter 'xmlData': The raw XML data
        //     - Returns:             Array of JsonDisplayItem for UI presentation

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'xmlData' is [\(xmlData)]...")
        appLogMsg("\(sCurrMethodDisp) Intermediate - Getting display items from XML (Data)...")
        
        guard let dictionary = convertXMLToDictionary(xmlData:xmlData) 
        else 
        {
            appLogMsg("\(sCurrMethodDisp) Intermediate - Failed to get dictionary for display items - Error!")

            return [JsonDisplayItem]()
        }
        
        let items = JsonDisplayItem.fromDictionary(dictionary)

        appLogMsg("\(sCurrMethodDisp) Exiting - Created #(\(items.count)) display items...")
        
        return items

    }   // End of func getDisplayItems(xmlData:Data)->[JsonDisplayItem].
    
}   // End of class AppXmlToJsonConverter.

// MARK: - Generic XML Element

// Generic structure to decode any XML element
// Uses dynamic member lookup to handle arbitrary XML structures

private struct GenericXMLElement:Codable
{
    
    struct ClassInfo
    {
        static let sClsId        = "GenericXMLElement"
        static let sClsVers      = "v1.0101"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    // MARK: - Properties...
    
                       var value:String?                         = nil
                       var attributes:[String:String]            = [String:String]()
                       var children:[String:[GenericXMLElement]] = [String:[GenericXMLElement]]()
    
    enum CodingKeys: String, CodingKey
    {
        case value = ""
    }
    
    init()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Default initialization...

        self.value      = nil
        self.attributes = [String:String]()
        self.children   = [String:[GenericXMLElement]]()

        // Exit...

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of init().
    
    init(from decoder:Decoder) throws
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'decoder' is [\(decoder)]...")

        // Try to decode as a simple value first...

        if let container   = try? decoder.singleValueContainer(),
           let stringValue = try? container.decode(String.self)
        {
            self.value = stringValue

            return
        }
        
        // Otherwise decode as a container with potential children...

        let container = try decoder.container(keyedBy:DynamicCodingKey.self)
        
        for key in container.allKeys 
        {
            let keyString = key.stringValue
            
            if let childArray = try? container.decode([GenericXMLElement].self, forKey:key)
            {
                // Try to decode as array of elements...

                children[keyString] = childArray
            }
            else if let childElement = try? container.decode(GenericXMLElement.self, forKey:key)
            {
                // Try to decode as single element

                children[keyString] = [childElement]
            }
            else if let stringValue = try? container.decode(String.self, forKey:key)
            {
                // Try to decode as string value...

                if keyString.hasPrefix("@")
                {
                    // It's an attribute...

                    attributes[String(keyString.dropFirst())] = stringValue
                } 
                else if keyString.isEmpty
                {
                    // It's the text content...

                    value = stringValue
                } 
                else 
                {
                    // It's a child element with string value...

                    var element = GenericXMLElement()

                    element.value       = stringValue
                    children[keyString] = [element]
                }
            }
        }

    }   // End of init(from decoder:Decoder) throws.
    
    func encode(to encoder:Encoder) throws
    {

        // Encoding not needed for this use case...

    }   // End of func encode(to encoder:Encoder) throws.
    
    func toDictionary()->[String:Any]
    {

        // Converts the generic XML element to a dictionary...

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        var dict:[String:Any] = [String:Any]()
        
        // Add attributes if present...

        if !attributes.isEmpty 
        {
            for (key, value) in attributes
            {
                dict["@\(key)"] = value
            }
        }
        
        // Add value if present...

        if let val = value, !val.isEmpty 
        {
            dict["#text"] = val
        }
        
        // Add children...

        for (key, elements) in children
        {
            if elements.count == 1 
            {
                // Single element - flatten it...

                let childDict = elements[0].toDictionary()

                if childDict.count == 1, let textValue = childDict["#text"]
                {
                    dict[key] = textValue
                } 
                else 
                {
                    dict[key] = childDict.isEmpty ? (elements[0].value as Any?) : childDict
                }
            } 
            else 
            {
                // Multiple elements - create array...

                dict[key] = elements.map 
                { element in

                    let childDict = element.toDictionary()

                    return childDict.isEmpty ? (element.value as Any?) : childDict

                }
            }
        }
        
        return dict
    }
    
}   // End of struct GenericXMLElement:Codable.

// MARK: - Dynamic Coding Key

// Dynamic coding key for XML parsing...

private struct DynamicCodingKey:CodingKey
{
    
    var stringValue:String
    var intValue:Int?
    
    init?(stringValue:String)
    {
        self.stringValue = stringValue
        self.intValue    = nil
    }
    
    init?(intValue:Int) 
    {
        self.stringValue = "\(intValue)"
        self.intValue    = intValue
    }
    
}   // End of struct DynamicCodingKey:CodingKey.

// MARK: - Display Models

// Item for displaying JSON data in SwiftUI lists...

struct JsonDisplayItem:Identifiable, Hashable
{
    
    struct ClassInfo
    {
        static let sClsId        = "JsonDisplayItem"
        static let sClsVers      = "v1.0201"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }
    
    // MARK: - Properties...
    
    let id:UUID                    = UUID()
    var key:String
    var value:String
    var children:[JsonDisplayItem] = [JsonDisplayItem]()

    var isExpandable:Bool
    {
        return !children.isEmpty
    }
    
    static func fromDictionary(_ dict:[String:Any], prefix:String = "")->[JsonDisplayItem]
    {

        // Creates display items from a dictionary...

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'dict' is [\(dict)] - 'prefix' is [\(prefix)]...")

        var items:[JsonDisplayItem] = [JsonDisplayItem]()
        
        // Sort keys for consistent display...

        let sortedKeys = dict.keys.sorted()
        
        for key in sortedKeys
        {
            let fullKey = prefix.isEmpty ? key : "\(prefix).\(key)"
            
            if let value = dict[key]
            {
                items.append(fromValue(key:key, value:value, fullKey:fullKey))
            }
        }
        
        return items

    }   // End of static func fromDictionary(_ dict:[String:Any], prefix:String = "")->[JsonDisplayItem].
    
    private static func fromValue(key:String, value:Any, fullKey:String)->JsonDisplayItem
    {

        // Creates a display item from a value (handles nested structures)

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'key' is [\(key)] - 'value' is [\(value)] - 'fullKey' is [\(fullKey)]...")

        if let dict = value as? [String:Any]
        {
            // Nested dictionary...

            let children = fromDictionary(dict, prefix:fullKey)

            return JsonDisplayItem(key:key, value:"[\(children.count) items]", children:children)
        } 
        else if let array = value as? [Any]
        {
            // Array...

            let children = fromArray(array, prefix:fullKey)

            return JsonDisplayItem(key:key, value:"[\(array.count) items]", children:children)
        } 
        else
        {
            // Simple value...

            let stringValue = "\(value)"

            return JsonDisplayItem(key:key, value:stringValue, children:[])
        }

    }   // End of private static func fromValue(key:String, value:Any, fullKey:String)->JsonDisplayItem.
    
    private static func fromArray(_ array:[Any], prefix:String)->[JsonDisplayItem]
    {

        // Creates display items from an array...

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'array' is [\(array)] - 'prefix' is [\(prefix)]...")

        var items:[JsonDisplayItem] = [JsonDisplayItem]()
        
        for (index, element) in array.enumerated()
        {
            let key     = "[\(index)]"
            let fullKey = "\(prefix)[\(index)]"

            items.append(fromValue(key:key, value:element, fullKey:fullKey))
        }
        
        return items

    }   // End of private static func fromArray(_ array:[Any], prefix:String)->[JsonDisplayItem].
    
}   // End of struct JsonDisplayItem:Identifiable, Hashable.

