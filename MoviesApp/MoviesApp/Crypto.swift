//
//  Crypto.swift
//  MoviesApp
//
//  Created by Ajit Singh on 07/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

import UIKit

// Note: 
// Since as per the assignment requirenments, I have to use only core foundation
// or foundation class, and also I cannot use any third part libs, I am
// implementing custom crypto funcitons.

// Crypto is a custom encryption method, that encrypts the input string by -
// 1. incrementing each character's ascii value by 32. Since ascii characters
// range from 0 to 127, we are rolling them when incrementing
// 2. XORing the ascii value of each character with 32
class Crypto: NSObject {
    static func encrypt(input: String) -> String {
        var output: String = ""
        for char in input {
            var finalIncrementedCharAsciiValue: UInt32 = 0
            let incrementedCharAsciiValue = char.ascii! + 32
            if incrementedCharAsciiValue > 127 {
                finalIncrementedCharAsciiValue = incrementedCharAsciiValue - 127
            } else {
                finalIncrementedCharAsciiValue = incrementedCharAsciiValue
            }
            let xoredCharAsciiValue = finalIncrementedCharAsciiValue ^ 32
            let newChar = Character(UnicodeScalar(xoredCharAsciiValue)!)
            output.append(newChar)
        }
        return output
    }

    static func decrypt(input: String) -> String {
        var output: String = ""
        for char in input {
            let xoredCharAsciiValue: Int = Int(char.ascii! ^ 32)
            var finalDecrementedCharAsciiValue: UInt32 = 0
            let decrementedCharAsciiValue: Int = Int(xoredCharAsciiValue - 32)
            if decrementedCharAsciiValue < 0 {
                finalDecrementedCharAsciiValue = UInt32(127 + decrementedCharAsciiValue)
            } else {
                finalDecrementedCharAsciiValue = UInt32(decrementedCharAsciiValue)
            }
            let newChar = Character(UnicodeScalar(finalDecrementedCharAsciiValue)!)
            output.append(newChar)
        }
        return output
    }
}

// ASCII characters have a scalar value between 0 and 127
extension Character {
    var ascii: UInt32? {
        return String(self).unicodeScalars.filter {$0.isASCII}.first?.value
    }
}
