//
//  PrintExtensions.swift
//  RxSwiftTraining
//
//  Created by Roman Rybachenko on 4/14/17.
//  Copyright © 2017 Roman Rybachenko. All rights reserved.
//

import Foundation


func pl(_ value: Any?, file: String = #file, lineNumber: Int = #line) {
    #if DEBUG
        let fName = fileName(from: file)
        
        let printValue: Any = value ?? "value is nil"
        print("\n~~ [\(fName): \(lineNumber)]  \(printValue)")
    #endif
}

func pf(functionName: String = #function, lineNumber: Int = #line) {
    #if DEBUG
        print("~~ [func: \(functionName): \(lineNumber)]")
    #endif
}

func pFile(file: String = #file) {
    #if DEBUG
        let fName = fileName(from: file)
        print("~~ [\(fName)]")
    #endif
}

func fileName(from path: String) -> String {
    let components = path.components(separatedBy: "/")
    guard let last = components.last else {
        return ""
    }
    
    return last
}


