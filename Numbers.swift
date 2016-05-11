//
//  EENumbers.swift
//  galaxy
//
//  Created by Tony Thomas on 02/05/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

import Foundation

/**
    The struct represents a galaxy number its made of galaxy numerals 'GalaxyNumeral', like pish, prok etc
*/
struct GalaxyNumber {
    
    //MARK: properties
    //The raw numerals in an array, used array because it is ordered elements
    var rawValue : [GalaxyNumeral]
    
   
    //MARK: methods
    /*
       Get the equivalent roman number.
    
        - returns : a 'RomanNumber' if the conversion succeeds
     */
    func getRomanNumber()->RomanNumber?{
        
        var romanNumber : RomanNumber? = nil
        
        do{
            //Roman numbers are formed using roman numerals, so we map the galaxy numerals
            //to corresponding roman numerals
            try romanNumber = RomanNumber(numerals: rawValue.map {
                
                return $0.getRomanNumeral()
                
                })
        }
        catch Error.InvalidRomanNumber{
            
            Log.print("Invalid roman number")
            return nil
        }
        catch{
            Log.print("Unknown exception in creating RomanNumber")
            return nil
        }
        return romanNumber
    }
}

/**
 The struct represents a roman number its made of roman numerals 'RomanNumeral', like I, V , X etc
 */
struct RomanNumber {
    
    //MARK: properties
    
    //An array of roman numerals
    var rawValue : [RomanNumeral]
    
    //Pattern for condition
    //Some roman numerals can be repeated, but with a limit of 3 in a single block
    let repetitionPatternMoreThanThree = "(.)\\1{3,}"
    
    //Pattern for condition
    //Some roman numerals cannot be repeated
    var repetitionPatternMoreThanOne = "(.)\\1{1,}"
    
    //MARK: methods
    /*
        Get the equivalent roman number.This conversion checks the conditions
        and throws an error if anything fail
    
        - parameter : an array of roman numerals
    */
    init(numerals: [RomanNumeral]) throws{
        
        //Get the raw number in the form XXLV
        let rawNumber = numerals.reduce("") { (combined : String, romanNumeral:RomanNumeral) -> String in
            
             combined + romanNumeral.faceName
        }
        //Find patterns if any, which are repeating
        let result = StringParser.findInText(rawNumber, pattenOfInterest:repetitionPatternMoreThanThree)
        
        guard result == nil else{
            
            throw Error.InvalidRomanNumber
        }
        //Some roman numerals cannot be repeated, if so, this number is invalid
        for romanNumeral in numerals{
            
            if romanNumeral.canRepeate{
                continue;
            }
            else{
                //Replace the pattern to find specific repeating roman numeral eg :(.)\\1{1,} --> (M)\\1{1,}
                repetitionPatternMoreThanOne = repetitionPatternMoreThanOne.stringByReplacingOccurrencesOfString(".", withString: romanNumeral.faceName)
                
                let result = StringParser.findInText(rawNumber, pattenOfInterest:repetitionPatternMoreThanOne)
                
                guard result == nil else{
                    
                   throw Error.InvalidRomanNumber
                }
                
            }
        }
        //Not all small values can be substracted from large value
        for var i = 0; i < numerals.count-1; ++i {
           
            if  numerals[i]<numerals[i+1] &&
                
                !numerals[i].canSubstractFrom(numerals[i+1]){
                    
                    throw Error.InvalidRomanNumber
            }
        }
        rawValue = numerals
        
    }
    //MCMXLIV = 1000 + (1000 − 100) + (50 − 10) + (5 − 1) = 1944
    func getArabicNumber()throws  ->ArabicNumber {
        
        var arabicNumberSum = ArabicNumber(rawValue: 0);
 
        for var i = 0; i < rawValue.count-1; ++i {
            
            if  rawValue[i]<rawValue[i+1] {
                
                arabicNumberSum -= rawValue[i].arabicEquivalent
            }
            else{
                arabicNumberSum += rawValue[i].arabicEquivalent
            }
        }
        //add last element
        arabicNumberSum += rawValue[rawValue.count-1].arabicEquivalent
        
        return arabicNumberSum
    }
 }

/**
 The struct represents a arabic number etc 100
 */
struct ArabicNumber {
    
    //MARK: properties
    var rawValue : Double
    
    //MARK: methods
    
    init( rawValue : Double){
        
        self.rawValue = rawValue
    }
    func stringValue()->String{
    
        return String(rawValue)
    }
}

//MARK: ArabicNumber operator functions

//operator functions for the 'ArabicNumber' struct
func > (arabicNumber1:ArabicNumber, arabicNumber2:ArabicNumber)->Bool{
    
    return arabicNumber1.rawValue > arabicNumber2.rawValue
}
func < (arabicNumber1:ArabicNumber, arabicNumber2:ArabicNumber)->Bool{
    
    return arabicNumber1.rawValue < arabicNumber2.rawValue
}

//overflow error is not considering in the following operator functions
func += (inout arabicNumber1:ArabicNumber, arabicNumber2:ArabicNumber){
    
    
    arabicNumber1.rawValue += arabicNumber2.rawValue
}
func -= (inout arabicNumber1:ArabicNumber, arabicNumber2:ArabicNumber){
    
    
    arabicNumber1.rawValue -= arabicNumber2.rawValue
}

func *= (inout arabicNumber1:ArabicNumber, arabicNumber2:ArabicNumber){
    
   
    arabicNumber1.rawValue *= arabicNumber2.rawValue
}

func /= (inout arabicNumber1:ArabicNumber, arabicNumber2:ArabicNumber){
    
   
    arabicNumber1.rawValue /= arabicNumber2.rawValue
}



