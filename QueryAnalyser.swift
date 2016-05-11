//
//  EEQueryAnalyser.swift
//  galexy
//
//  Created by Tony Thomas on 04/05/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

import Foundation

//MARK: protocol QueryAnalyser

/**
    QueryAnalyser protocol to be implemented by all query analyser types
*/
protocol QueryAnalyser : ArabicConverter{
    
    /*
        Processes basic query and extracts the numerals and metal eg : blog proc silver then send it
        to nextstep of processing.
    
        - parameter manager: 'EETransactionManager' manages state and is injected here
        - parameter query: the original query "how many Credits is glob prok Iron ?"
    
    */
    func processQuery(query : String , withTransactionManager manager :TransactionManager)
    
}


//MARK: extension QueryAnalyser

/**
    'QueryAnalyser' extension methods, implemented for all type conforming to 'QueryAnalyser' protocol
 */
extension QueryAnalyser{
    

    
    /*
        Galaxy numerals are generated from refined query, a refined query look like "blog proc tegj" 
        sprit into galaxy numeral face values like "blog". Then check this face value against 
        existing galaxy face valuegalexy numeral map.It the compile a list of galaxy numerals 
        corresponing to galaxy face values present in the refined query
    
        - parameter manager: 'EETransactionManager' manages state and is injected here
        - parameter query: refined query "glob prok Iron"
        - returns : An 'ArabicNumber' if the conversion is success else nil
    */
    func arabicNumberFromRefinedQuery(query : String, transactionManager manager :TransactionManager)->ArabicNumber?{
        
        let elements = query.componentsSeparatedByString(" ").filter { !$0.isEmpty }
        
        var numerals = [GalaxyNumeral]()
        
        for index in 0...elements.count-1{
            
            let string = elements[index]
            
            if let numeral = manager.galaxyNumerals[string]{
                
                numerals.append(numeral)
            }
        }
        //If there is a diffrence, that means there is a galaxy numeral which does not exist comes
        //along with a set of known galaxy numerals
        guard numerals.count == elements.count else{
             
            return nil
        }
        return arabicNumberFromGalaxyNumerals(numerals)
    }
    
}

//MARK: protocol ArabicConverter

/**
    ArabicConverter protocol to be implemented by types which needs that specific conversion
 */
protocol ArabicConverter{
    
    /*
        Arabic number is calculated from galaxy numerals
    
        - parameter numerals: an array of 'GalaxyNumeral's
        - returns : An 'ArabicNumber' if the conversion is success else nil
    */
    func arabicNumberFromGalaxyNumerals(numerals :[GalaxyNumeral])->ArabicNumber?
}

//MARK: extension ArabicConverter

/**
    Provides a default implementationd for ArabicConverter protocol 
 */
extension ArabicConverter{
    

    func arabicNumberFromGalaxyNumerals(numerals :[GalaxyNumeral])->ArabicNumber?{
        
        let galaxyNumber = GalaxyNumber(rawValue: numerals)
        
        let arabicNumber : ArabicNumber?
        
        do{
            
            arabicNumber = try galaxyNumber.getRomanNumber()?.getArabicNumber()
        }
        catch{
            
            return nil
        }
        return arabicNumber
        
    }
    
}

//MARK: class QueryAnalyserMany

/**
    This class analyses a query of type "How many credits is blog proc silver ?" and store the results
 */
class QueryAnalyserMany : QueryAnalyser{
    

    //MARK: methods
    
    //QueryAnalyser method implementation
    func processQuery(query : String , withTransactionManager manager :TransactionManager){
        
        let pattern = "(how\\s+)|(many\\s+)|(is\\s+)|(credits\\s+)|([?])"
        //Remove patterns how, many, is, credits, ? etc
        if let formattedInput = StringParser.removePatternFromText(query, pattenOfInterest: pattern){
           
            handleHowMany(formattedInput, originalQuery: query,transactionManager : manager)
        }
    }
    
    /*
        Finds the answer for the query like "how many Credits is glob prok Iron ?"
        
        - parameter refinedQuery: string without words like " how many Credits is"
        - parameter query: the original query "how many Credits is glob prok Iron ?"
        - parameter manager: the 'EETransactionManager'
    */
    
    func handleHowMany(refinedQuery : String , originalQuery query :String ,transactionManager manager :TransactionManager){
      
        //Remove metal from list
        var components = refinedQuery.componentsSeparatedByString(" ").filter { !$0.isEmpty }
      
        let metal = components.removeLast()
        
        let numerals = components.reduce("", combine: { (sum, string : String) -> String in
            
            sum + " " + string
        })
        //MetalCreditMap has the unit price for every metal
        if var arabicNumber = arabicNumberFromRefinedQuery(numerals, transactionManager: manager){
            
            if let unitPrice = manager.metalCreditMap[metal]{
                
                arabicNumber *= unitPrice
            }
            //Answer is here
            manager.queryResultMap[query] = refinedQuery +  " is " + arabicNumber.stringValue() + " Credits"
        }
        else{
            
            manager.queryResultMap[query] = "I have no idea what you are talking about"
        }
    }

}

//MARK: class QueryAnalyserMuch

/**
    This class analyses a query of type "How much is glob proc tegj ?" and store the results
 */
class QueryAnalyserMuch : QueryAnalyser{
    
   
    //MARK: methods
    
    func processQuery(query : String , withTransactionManager manager :TransactionManager){
        
        let pattern = "(how\\s+)|(much\\s+)|(is\\s+)|([?])"
        
        if let formattedInput = StringParser.removePatternFromText(query, pattenOfInterest: pattern){
            
            handleHowMuch(formattedInput, originalQuery: query, transactionManager: manager)
            
        }
    }
    /*
        Finds the answer for the query like "how much is pish tegj glob glob ?"
    
        - parameter refinedQuery: string without words like "how much is"
        - parameter query: the original query "how much is pish tegj glob glob ?"
        - parameter manager: the 'EETransactionManager'
    */
    func handleHowMuch(refinedQuery : String , originalQuery query :String , transactionManager :TransactionManager){
        
        
        if let arabicNumber = arabicNumberFromRefinedQuery(refinedQuery, transactionManager: transactionManager){
            
            //Answer is here
            transactionManager.queryResultMap[query] = refinedQuery + " is " + arabicNumber.stringValue()
        }
        else{
            
            transactionManager.queryResultMap[query] = "I have no idea what you are talking about"
           
        }
    }

}
