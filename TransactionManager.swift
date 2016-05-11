//
//  EETransactionManager.swift
//  galexy
//
//  Created by Tony Thomas on 02/05/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

import Foundation

//MARK: class  oEETransactionManager

/**
    This class implements the buisiness logic.
 */
class TransactionManager : ArabicConverter{
    
     //MARK: properties
    
    //The dictionary of galaxy numerals and their face value eg: glob : GalaxyNumeral
    var galaxyNumerals = [String:GalaxyNumeral] ()
    
    //Dictionary of metals and their credit per unit quantity eg Gold : 10000
    var metalCreditMap = [String:ArabicNumber]()
    
    //Query reult map, this is to display the result corresponding to each query
    var queryResultMap = [String : String]()
    
    //The input array of strngs
    var inputs = [String]()
    
    //MARK: methods
    /*
        Processes basic query and extracts the numerals and metal eg : blog proc silver then send it
        to nextstep of processing.
    
        - parameter string: input , it can be any thing that follows some basic patern
    
    */
    func addInput(string : String){
        
        inputs.append(string)
        
    }
    
    /*
        clear all states for repeated testing of input
    
    */
    func clearState(){
        
        galaxyNumerals = [String:GalaxyNumeral] ()
        metalCreditMap = [String:ArabicNumber]()
        queryResultMap = [String : String]()
        inputs = [String]()
    }
    
    /*
        Processes basic query and extracts the numerals and metal eg : blog proc silver then send it
        to nextstep of processing.
    
        - parameter callback: closure for completion notification, this faclitate a loose coupling
          with the user interface
    
    */
    func runTest(resultCallback callback :([String])->()){
        
        //The inputs are processed using regular expressions and finds diffrent patters
        //then process each type accordingly
        for input in inputs{
            
            let result = StringParser.parseInput(input)
            
            guard result != nil else{
                
                queryResultMap[input] = "I have no idea what you are talking about"
                continue
            }
            
            switch (result!){
                
            case (.TypeMap ,  let string):
                
                let galaxyNumeral = GalaxyNumeral(galexyArabicMap: string)
                
                galaxyNumerals[galaxyNumeral.faceName] = galaxyNumeral;
                
            case (.TypeCredit ,  let string):
                
                processAndStoreCreditDetails(string)
                
            case (.TypeCountMuch , let queryString):
                
                let howMuchQueryAnalyser = QueryAnalyserMuch()
                
                howMuchQueryAnalyser.processQuery(queryString, withTransactionManager: self)

            case (.TypeCountMany , let queryString):
               
                let howManyQueryAnalyser = QueryAnalyserMany()
                
                howManyQueryAnalyser.processQuery(queryString, withTransactionManager: self)
                 
            }
        }
        //result is formatted and sent to the view
        callback(queryResultMap.map({ $0.0 + "\n" + $0.1 }))
        
    }
    
    /*
        Processes a statement with credit details of metals and finds the unit price for each metal.
        The reult is kept in a dictionary , eg Silver : 150
    
        - parameter input: a statement of type "glob glob Silver is 34 Credits"
     */
    func processAndStoreCreditDetails(input : String){
        
        //input : glob glob Silver is 34 Credits
        let formattedInput = StringParser.removePatternFromText(input, pattenOfInterest:
                             "(is\\s+)|(credits\\s*)")
        
        guard formattedInput != nil else {
            
            Log.print("The credit query could not refine")
            return
        }
        /*  
            formattedInput : glob glob Silver 34
        
            the components are
            1 glob glob  ---> convert to GalaxyNumber
            2 Silver     ---> Metal
            3 34         ---> Credits in arabic
        */
        let elements = formattedInput!.componentsSeparatedByString(" ").filter { !$0.isEmpty }
        
        guard elements.count > 2 else{
            
            Log.print("The credit query did not contain galaxy numerals")
            return
        }
        let metal = elements[elements.count-2];
        let creditsForMetal = Double(elements.last!)
        
        guard creditsForMetal > 0 else {
            
            Log.print("The credit for metal is 0, so the metal is useless")
            return
        }
        
        var numerals = [GalaxyNumeral]()
        
        for index in 0...elements.count-3 {
           
            let string = elements[index]
            
            if let numeral = galaxyNumerals[string]{
                
                numerals.append(numeral)
            }
         }
        
        if let countOfMetal = arabicNumberFromGalaxyNumerals(numerals){
            
            let priceOfUnitMetal = creditsForMetal!/countOfMetal.rawValue
        
            metalCreditMap[metal] = ArabicNumber(rawValue: priceOfUnitMetal)
            
            return
        }
        
    }
    
}

