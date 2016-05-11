//
//  EENumerals.swift
//  galaxy
//
//  Created by Tony Thomas on 02/05/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

import Foundation

//MARK: type GalaxyNumeral

/**
 The struct represents a galaxy numeral it has a face value like pish, prok etc and a roman equivalent
 like V, L, M etc
 */
struct GalaxyNumeral {
    
    //MARK: properties
    
    //The facename etc prok , glob
    var faceName : String
    //The roman equivalent etc V, I
    var romanEquivalent : String
   
    //MARK: methods
    
    //Initialiser
    init(galexyArabicMap : String){
        
        //the input format is like prok is V , so this pattern is predictable
        let components = galexyArabicMap.componentsSeparatedByString(" ").filter { !$0.isEmpty }
        faceName = components[0]
        romanEquivalent = components[2]
        
    }
    //Get the equivalent roman numeral
    func getRomanNumeral()->RomanNumeral{
        
        return RomanNumeral(faceName: romanEquivalent)
    }
    
    
}

//MARK: type RomanNumeral

/**
 The roman numeral it has a face value like V, L etc it has an equivalent arabic number
 like 5, 50 etc
 */
struct RomanNumeral {
    
    //MARK: properties
    
    //The facename
    var faceName : String
    //Arabic number
    var arabicEquivalent : ArabicNumber
    //Some numerals cannot be repeated
    var canRepeate : Bool
    
    //MARK: methods
    
    //Initialiser
    init(faceName:String){
        
        self.faceName = faceName;
        switch faceName{
            
        case "I":
            arabicEquivalent = ArabicNumber(rawValue:1)
             canRepeate = true
        case "V":
            arabicEquivalent = ArabicNumber(rawValue:5)
            canRepeate = false
        case "X":
            arabicEquivalent = ArabicNumber(rawValue:10);
             canRepeate = true
        case "L":
            arabicEquivalent = ArabicNumber(rawValue:50);
            canRepeate = false
        case "C":
            arabicEquivalent = ArabicNumber(rawValue:100);
             canRepeate = true
        case "D":
            arabicEquivalent = ArabicNumber(rawValue:500);
             canRepeate = false
        case "M":
            arabicEquivalent = ArabicNumber(rawValue:1000);
             canRepeate = true
        default:
            arabicEquivalent = ArabicNumber(rawValue:0);
            canRepeate = false
         }
        
    }
    //Tells weather this numeral can be substracted from another
    func canSubstractFrom(romanNumaral:RomanNumeral)->Bool{
        
        guard self.faceName != romanNumaral.faceName else{
            return false
        }
        switch self.faceName{
            
        case "I" where romanNumaral.faceName == "V" || romanNumaral.faceName == "X":
            return true
         case "X" where romanNumaral.faceName == "L" || romanNumaral.faceName == "C":
            return true
        case "C" where romanNumaral.faceName == "D" || romanNumaral.faceName == "M":
            return true
        default:
            return false;
            
        }
    }
   
}

//MARK: RomanNumeral operator functions

//Operator functions for roman numerals
func < (romanNumaral1:RomanNumeral, romanNumaral2:RomanNumeral)->Bool{
    
    return romanNumaral1.arabicEquivalent < romanNumaral2.arabicEquivalent
}
func > (romanNumaral1:RomanNumeral, romanNumaral2:RomanNumeral)->Bool{
    
    return romanNumaral1.arabicEquivalent < romanNumaral2.arabicEquivalent
}
