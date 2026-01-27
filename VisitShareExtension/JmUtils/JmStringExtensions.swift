//
//  JmStringExtensions.swift
//  JmUtils_Library
//
//  First version created by Daryl Cox on 05/19/2016.
//  Copyright (c) 2016-2026 JustMacApps. All rights reserved.
//

import Foundation

// Enumeration to indicate CharacterSet(s) to use to 'clean' a String.

enum StringCleaning
{
    case removeNone
    case removeAll
    case removeControl
    case removeDecomposables
    case removeIllegal
    case removeNewlines
    case removeNonBase
    case removePunctuation
    case removeSymbols
    case removeWhitespaces
    case removeWhitespacesAndNewlines
}

// Extension class to add extra method(s) to String - v8.0801.

extension String
{

    var length:Int
    {
        get
        {
            return self.count
        }
    }

    func containsString(s:String)->Bool
    {

        if (s.count < 1)
        {
            return false
        }

        let rangeSearch = self.range(of:s)

        return (rangeSearch != nil) ? true : false

    }   // End of func containsString(s:String)->Bool.

    func containsStringIgnoreCase(s:String)->Bool
    {

        if (s.count < 1)
        {
            return false
        }

        let rangeSearch = self.range(of:s, options:.caseInsensitive)

        return (rangeSearch != nil) ? true : false

    }   // End of func containsString(s:String)->Bool.

    func stringByReplacingAllOccurrencesOfString(target:String, withString:String)->String
    {

        if (target.count < 1)
        {
            return self
        }

        if (withString.count < 1)
        {
            return self
        }

        return self.replacingOccurrences(of:target, with:withString, options:String.CompareOptions.literal, range:nil)

    }   // End of func stringByReplacingAllOccurrencesOfString(target:String, withString:String)->String.

    func subString(startIndex:Int, length:Int)->String
    {

        if (startIndex < 0)
        {
            return self
        }

        if (length < 1)
        {
            return self
        }

        let cStartIndex = self.index(self.startIndex, offsetBy:startIndex)
        let cEndIndex   = self.index(self.startIndex, offsetBy:(startIndex + length))

        return String(self[cStartIndex..<cEndIndex])

    }   // End of func subString(startIndex:Int, length:Int)->String.

    func indexOfString(target:String)->Int
    {

        return self.indexOfString(target:target, startIndex:0)

    }   // End of func indexOfString(target:String)->Int.

    func indexOfString(target:String, startIndex:Int)->Int
    {

        if (target.count < 1)
        {
            return -1
        }

        if (startIndex < 0)
        {
            return -1
        }

        let substringIndex        = self.index(self.startIndex, offsetBy:startIndex)
        let sSearchString:String? = String(self[substringIndex..<self.endIndex])

        if let svSearchString = sSearchString
        {
            if let rangeOfSubstring = svSearchString.range(of:target)
            {
                return (self.distance(from:self.startIndex, to:rangeOfSubstring.lowerBound) + startIndex)
            }
        }

        return -1

    }   // End of func indexOfString(target:String, startIndex:Int)->Int.

    func lastIndexOfString(target:String)->Int
    {

        if (target.count < 1)
        {
            return -1
        }

        var index     = -1
        var stepIndex = self.indexOfString(target:target)

        while (stepIndex > -1)
        {
            index = stepIndex

            if ((stepIndex + target.length) < self.length)
            {
                stepIndex = self.indexOfString(target:target, startIndex:(stepIndex + target.length))
            }
            else
            {
                stepIndex = -1
            }
        }

        return index

    }   // End of func lastIndexOfString(target:String)->Int.

    func rightPartitionStrings(target:String)->[String]?
    {

        if (target.count < 1)
        {
            return nil
        }

        let partitionIndex = self.lastIndexOfString(target:target)

        if (partitionIndex < 0)
        {
            return nil
        }

        //            1         2         3         4         5
        //  0123456789+123456789+123456789+123456789+123456789+
        // "/Volumes/MacMini HD/work/Video/DSC00181.jpg"
        //  123456789+123456789+123456789+123456789+123456789+
        //           1         2         3         4         5

        let sLeftPartition  = self.subString(startIndex:0, length:partitionIndex)
        let sRightPartition = self.subString(startIndex:(partitionIndex + target.length), length:(self.length - partitionIndex - target.length))

        return [sLeftPartition, target, sRightPartition]

    }   // End of func rightPartitionStrings(target:String)->[String]?.

    func leftPartitionStrings(target:String)->[String]?
    {

        if (target.count < 1)
        {
            return nil
        }

        let partitionIndex = self.indexOfString(target:target)

        if (partitionIndex < 0)
        {
            return nil
        }

        //            1         2         3         4         5
        //  0123456789+123456789+123456789+123456789+123456789+
        // "/Volumes/MacMini HD/work/Video/DSC00181.jpg"
        //  123456789+123456789+123456789+123456789+123456789+
        //           1         2         3         4         5

        let sLeftPartition  = self.subString(startIndex:0, length:partitionIndex)
        let sRightPartition = self.subString(startIndex:(partitionIndex + target.length), length:(self.length - partitionIndex - target.length))

        return [sLeftPartition, target, sRightPartition]

    }   // End of func leftPartitionStrings(target:String)->[String]?.

    func expandTildeInString()->String
    {

        return NSString(string:self).expandingTildeInPath as String

    }   // End of func expandingTildeInString()->String.

    func removeUnwantedCharacters(charsetToRemove:[StringCleaning], sExtraCharacters:String = "", sJoinCharacters:String = "", bResultIsLowerCased:Bool = false)->String
    {
        
        var sCleanedValueToWork:String        = self
        var bCSUnwantedDelimitersUpdated:Bool = false
        var csUnwantedDelimiters:CharacterSet = CharacterSet()

        if (charsetToRemove.count > 0)
        {
            for currentCharactersToRemove in charsetToRemove
            {
                switch currentCharactersToRemove
                {
                case StringCleaning.removeNone:
                    break
                case StringCleaning.removeAll:
                    csUnwantedDelimiters         = csUnwantedDelimiters.union(CharacterSet.controlCharacters)
                    csUnwantedDelimiters         = csUnwantedDelimiters.union(CharacterSet.decomposables)
                    csUnwantedDelimiters         = csUnwantedDelimiters.union(CharacterSet.illegalCharacters)
                    csUnwantedDelimiters         = csUnwantedDelimiters.union(CharacterSet.newlines)
                    csUnwantedDelimiters         = csUnwantedDelimiters.union(CharacterSet.nonBaseCharacters)
                    csUnwantedDelimiters         = csUnwantedDelimiters.union(CharacterSet.punctuationCharacters)
                    csUnwantedDelimiters         = csUnwantedDelimiters.union(CharacterSet.symbols)
                    csUnwantedDelimiters         = csUnwantedDelimiters.union(CharacterSet.whitespaces)
                    csUnwantedDelimiters         = csUnwantedDelimiters.union(CharacterSet.whitespacesAndNewlines)
                    bCSUnwantedDelimitersUpdated = true
                case StringCleaning.removeControl:
                    csUnwantedDelimiters         = csUnwantedDelimiters.union(CharacterSet.controlCharacters)
                    bCSUnwantedDelimitersUpdated = true
                case StringCleaning.removeDecomposables:
                    csUnwantedDelimiters         = csUnwantedDelimiters.union(CharacterSet.decomposables)
                    bCSUnwantedDelimitersUpdated = true
                case StringCleaning.removeIllegal:
                    csUnwantedDelimiters         = csUnwantedDelimiters.union(CharacterSet.illegalCharacters)
                    bCSUnwantedDelimitersUpdated = true
                case StringCleaning.removeNewlines:
                    csUnwantedDelimiters         = csUnwantedDelimiters.union(CharacterSet.newlines)
                    bCSUnwantedDelimitersUpdated = true
                case StringCleaning.removeNonBase:
                    csUnwantedDelimiters         = csUnwantedDelimiters.union(CharacterSet.nonBaseCharacters)
                    bCSUnwantedDelimitersUpdated = true
                case StringCleaning.removePunctuation:
                    csUnwantedDelimiters         = csUnwantedDelimiters.union(CharacterSet.punctuationCharacters)
                    bCSUnwantedDelimitersUpdated = true
                case StringCleaning.removeSymbols:
                    csUnwantedDelimiters         = csUnwantedDelimiters.union(CharacterSet.symbols)
                    bCSUnwantedDelimitersUpdated = true
                case StringCleaning.removeWhitespaces:
                    csUnwantedDelimiters         = csUnwantedDelimiters.union(CharacterSet.whitespaces)
                    bCSUnwantedDelimitersUpdated = true
                case StringCleaning.removeWhitespacesAndNewlines:
                    csUnwantedDelimiters         = csUnwantedDelimiters.union(CharacterSet.whitespacesAndNewlines)
                    bCSUnwantedDelimitersUpdated = true
                }
            }
        }
        
        if (sExtraCharacters.count > 0)
        {
            csUnwantedDelimiters.insert(charactersIn:sExtraCharacters)

            bCSUnwantedDelimitersUpdated = true
        }
        
        if (bCSUnwantedDelimitersUpdated == true)
        {
            let listCleanedValueToWork:[String] = sCleanedValueToWork.components(separatedBy:csUnwantedDelimiters)
            sCleanedValueToWork                 = listCleanedValueToWork.joined(separator:sJoinCharacters)
        }
            
        if (bResultIsLowerCased == true)
        {
            sCleanedValueToWork = sCleanedValueToWork.lowercased()
        }
        
        return sCleanedValueToWork
        
    }   // End of func removeUnwantedCharacters(charsetToRemove:[StringCleaning], sExtraCharacters:String, sJoinCharacters:String, bResultIsLowerCased:Bool)->String.
    
    func stripOptionalStringWrapper()->String
    {

        if (self.count < 1)
        {
            return self
        }

        let sOptionalStringPrefix:String = "Optional("
        let sOptionalStringSuffix:String = ")"

        guard self.hasPrefix(sOptionalStringPrefix) && self.hasSuffix(sOptionalStringSuffix)
        else
        {
            return self
        }

        // Remove "Optional(" from the start and ")" from the end...

        let indexOptionalStart = self.index(self.startIndex, offsetBy:sOptionalStringPrefix.count)
        let indexOptionalEnd   = self.index(self.endIndex,   offsetBy:-(sOptionalStringSuffix.count))

        return String(self[indexOptionalStart..<indexOptionalEnd])

    }   // End of func stripOptionalStringWrapper()->String.

    func stripStringWrapper(sWrapperCharacters:String = "")->String
    {

        if (self.count < 1)
        {
            return self
        }

        if (sWrapperCharacters.count < 1)
        {
            return self
        }

        let sOptionalStringPrefix:String = sWrapperCharacters
        let sOptionalStringSuffix:String = sWrapperCharacters

        guard self.hasPrefix(sOptionalStringPrefix) && self.hasSuffix(sOptionalStringSuffix)
        else
        {
            return self
        }

        // Remove 'sWrapperCharacters' from the start and from the end...

        let indexOptionalStart = self.index(self.startIndex, offsetBy:sOptionalStringPrefix.count)
        let indexOptionalEnd   = self.index(self.endIndex,   offsetBy:-(sOptionalStringSuffix.count))

        return String(self[indexOptionalStart..<indexOptionalEnd])

    }   // End of func stripStringWrapper(sWrapperCharacters:String)->String.

    func stripStringLeadingPrefix(sPrefixCharacters:String = "")->String
    {

        if (self.count < 1)
        {
            return self
        }

        if (sPrefixCharacters.count < 1)
        {
            return self
        }

        let sOptionalStringPrefix:String = sPrefixCharacters

        guard self.hasPrefix(sOptionalStringPrefix)
        else
        {
            return self
        }

        // Remove 'sWrapperCharacters' from the start...

        let indexOptionalStart = self.index(self.startIndex, offsetBy:sOptionalStringPrefix.count)

        return String(self[indexOptionalStart...])

    }   // End of func stripStringLeadingPrefix(sWrapperCharacters:String)->String.

    func stripStringTrailingSuffix(sSuffixCharacters:String = "")->String
    {

        if (self.count < 1)
        {
            return self
        }

        if (sSuffixCharacters.count < 1)
        {
            return self
        }

        let sOptionalStringSuffix:String = sSuffixCharacters

        guard self.hasSuffix(sOptionalStringSuffix)
        else
        {
            return self
        }

        // Remove 'sWrapperCharacters' from the end...

        let indexOptionalEnd = self.index(self.endIndex, offsetBy:-(sOptionalStringSuffix.count))

        return String(self[..<indexOptionalEnd])

    }   // End of func stripStringTrailingSuffix(sSuffixCharacters:String)->String.

    func extractEmbeddedContent(from firstPattern:String = "", after lastPattern:String = "")->String
    {
        
        // Check parameter(s)...
        
        if (firstPattern.count < 1)
        {
            return ""
        }
        
        if (lastPattern.count < 1)
        {
            return ""
        }
        
        // Find the range of the first pattern...
        
        let firstPatternRange = self.range(of:firstPattern, options:.caseInsensitive)
        
        if (firstPatternRange == nil)
        {
            print("...bad 'firstPatternRange' - 'self' is [\(self)] - 'firstPattern' is [\(firstPattern)]... - Error!")
            
            return ""
        }
        
        // Get the 'remaining' substring after the first pattern...
        
        let afterFirstPatternIndex      = firstPatternRange!.upperBound
        let remainingString:SubSequence = self[afterFirstPatternIndex...]
        
        // Find the range of the last pattern in the 'remaining' substring...
        
        let lastPatternRange = remainingString.range(of:lastPattern, options:.caseInsensitive)
        
        if (lastPatternRange == nil)
        {
            print("...bad 'lastPatternRange' - 'remainingString' is [\(remainingString)] - 'lastPattern' is [\(lastPattern)]... - Error!")
            
            return ""
        }
        
        // Extract the content between the 2 patterns...
        
        let beforeLastPatternIndex       = lastPatternRange!.lowerBound
        let extractedContent:SubSequence = remainingString[..<beforeLastPatternIndex]
        let sReturnString:String         = String(extractedContent)
        
        return sReturnString
        
    }   // End of func extractEmbeddedContent(from firstPattern:String, after lastPattern:String)->String.
    
    func extractPrefixAndSuffix(delimiter:String)->(prefix:String, suffix:String)?
    {

        if (self.count < 1)
        {
            return nil
        }
        
        if (delimiter.count < 1)
        {
            return nil
        }
        
        let listStringComponents:[String] = self.components(separatedBy:delimiter)

        // Check if the delimiter exists in the string...

        guard listStringComponents.count > 1
        else
        {
            return nil
        }

        let sPrefix:String = listStringComponents[0]
        let sSuffix:String = listStringComponents.dropFirst().joined(separator:delimiter)

        return (sPrefix, sSuffix)

    }   // func extractPrefixAndSuffix(delimiter:String)->(prefix:String, suffix:String)?.

    // Computed 'value': Alternative validation method as a String extension...

    var isValidNetworkURL:Bool 
    {
        guard !self.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty 
        else { return false }

        guard let url = URL(string:self) 
        else { return false }

        guard let scheme = url.scheme?.lowercased(),
              (scheme == "http" || scheme == "https") 
        else { return false }

        guard let host = url.host, !host.isEmpty 
        else { return false }

        return true
    }

}   // End of extension String.

