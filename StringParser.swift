//
//  EEStringParser.swift
//  galexy
//
//  Created by Tony Thomas on 02/05/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

import Foundation

/**
    Enumeration for different regular expressions, that can appear in input
 */
enum InputTypePatten : String{
    
    //glob is I
    case TypeMap = "^*([a-z]+) *is *([I|V|X|L|C|D|M])$*"
    
    //glob glob Silver is 34 Credits
    case TypeCredit = "((?:[a-z]*+ )+)([A-Z]\\w+) *is *(\\d+) *([A-Z]\\w+)$*"
    
    //how much is pish tegj glob glob ?
    case TypeCountMuch = "^*how much is ((?:\\w+[^0-9] )+)\\?$*"
    
    //how many Credits is glob prok Iron ?
    case TypeCountMany = "^*how many *([a-zA-Z]\\w+) *is *((?:\\w*+ )+)([A-Z]\\w+) \\?$*"
    
}

/**
    String parser class which have type methods to parse test input
 */
class StringParser{
    
    /*
        Get the equivalent roman number.This conversion checks the conditions
        and throws an error if anything fail
    
        - input : input string can be anly thing like tegj is L
        - returns : an optional tuple with the type of query and the query
    */
    class func parseInput(input : String)->(InputTypePatten, String)?{
        
        let inputPatterns = [InputTypePatten.TypeMap , InputTypePatten.TypeCredit, InputTypePatten.TypeCountMuch, InputTypePatten.TypeCountMany]
        
        //Check the input string against each pattern in the 'InputType' and returns the first find
        for inputPattern in inputPatterns{
            
            let extractedInput = findInText(input, pattenOfInterest: inputPattern.rawValue)?.first
            
            if extractedInput != nil{
                
                return (inputPattern, extractedInput!)
            }
        }
        Log.print("Unresolved input : \(input)")
        return nil;
    }
    
    /*
        The regular expression checker
    
        - text : input string can be anly thing like tegj is L
        - pattern : regular expression pattern to find
    */
    class func findInText(text :String, pattenOfInterest pattern:String) ->([String]?){
        
        do{
            
            let regex = try NSRegularExpression(pattern: pattern, options: [.CaseInsensitive])
            
            let matches = regex.matchesInString(text, options: [], range:  NSMakeRange(0, text.characters.count))
            
            guard matches.count > 0 else{
              
                return nil
            }
            
            let nsString = text as NSString
            let itemList = matches.map { nsString.substringWithRange($0.range)}
            
            return itemList
        }
        catch{
            
            Log.print("Error initialising regular expression")
        }
        
        return nil
    }
    
    /*
        Checks and remove some patterns from a text
    
        - text : input string can be anly thing like tegj is L
        - pattern : regular expression pattern to remove
    */
    class func removePatternFromText(text :String, pattenOfInterest pattern:String) ->String?{
        
        do{
            
            let regex = try NSRegularExpression(pattern: pattern, options: [.CaseInsensitive])
            
            let modString = regex.stringByReplacingMatchesInString(text, options: [], range:
                NSMakeRange(0, text.characters.count), withTemplate: "")
            
            return modString
        }
        catch{
            
            Log.print("Error initialising regular expression")
        }
        
        return nil
    }
    
}
