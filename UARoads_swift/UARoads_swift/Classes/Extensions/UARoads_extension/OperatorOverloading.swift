//
//  OperatorOverloading.swift
//
//  Created by Victor Amelin on 4/3/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit

public protocol Number {
    static func +(l: Self, r: Self) -> Self
    static func -(l: Self, r: Self) -> Self
    static func /(l: Self, r: Self) -> Self
    static func *(l: Self, r: Self) -> Self
}

extension Double: Number {}
extension Float: Number {}
extension Int: Number {}
extension UInt: Number {}
extension CGFloat: Number {}

//Array
public func +<T: Number>(_ left: [T], _ right: [T]) -> [T] {
    var res = [T]()
    assert(left.count == right.count, "Arrays of the same length only.")
    for (key, _) in left.enumerated() {
        res.append(left[key] + right[key])
    }
    return res
}

public func -<T: Number>(_ left: [T], _ right: [T]) -> [T] {
    var res = [T]()
    assert(left.count == right.count, "Arrays of the same length only.")
    for (key, _) in left.enumerated() {
        res.append(left[key] - right[key])
    }
    return res
}

public func *<T: Number>(_ left: [T], _ right: [T]) -> [T] {
    var res = [T]()
    assert(left.count == right.count, "Arrays of the same length only.")
    for (key, _) in left.enumerated() {
        res.append(left[key] * right[key])
    }
    return res
}

public func /<T: Number>(_ left: [T], _ right: [T]) -> [T] {
    var res = [T]()
    assert(left.count == right.count, "Arrays of the same length only.")
    for (key, _) in left.enumerated() {
        res.append(left[key] / right[key])
    }
    return res
}

public func +=<T: Number>(_ left: inout [T], _ right: [T]) {
    left = left + right
}

public func -=<T: Number>(_ left: inout [T], _ right: [T]) {
    left = left - right
}

public func *=<T: Number>(_ left: inout [T], _ right: [T]) {
    left = left * right
}

public func /=<T: Number>(_ left: inout [T], _ right: [T]) {
    left = left / right
}

//CGPoint
public func +(_ left: CGPoint, _ right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func -(_ left: CGPoint, _ right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

public func *(_ left: CGPoint, _ right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

public func /(_ left: CGPoint, _ right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x / right.x, y: left.y / right.y)
}

public func +=(left : inout CGPoint, right: CGPoint) {
    left = left + right
}

public func -=(left : inout CGPoint, right: CGPoint) {
    left = left - right
}

public func *=(left : inout CGPoint, right: CGPoint) {
    left = left * right
}

public func /=(left : inout CGPoint, right: CGPoint) {
    left = left / right
}

//CGRect
public func +(_ left: CGRect, _ right: CGRect) -> CGRect {
    return CGRect(x: left.origin.x + right.origin.x,
                  y: left.origin.y + right.origin.y,
                  width: left.size.width + right.size.width,
                  height: left.size.height + right.size.height)
}

public func -(_ left: CGRect, _ right: CGRect) -> CGRect {
    return CGRect(x: left.origin.x - right.origin.x,
                  y: left.origin.y - right.origin.y,
                  width: left.size.width - right.size.width,
                  height: left.size.height - right.size.height)
}

public func *(_ left: CGRect, _ right: CGRect) -> CGRect {
    return CGRect(x: left.origin.x * right.origin.x,
                  y: left.origin.y * right.origin.y,
                  width: left.size.width * right.size.width,
                  height: left.size.height * right.size.height)
}

public func /(_ left: CGRect, _ right: CGRect) -> CGRect {
    return CGRect(x: left.origin.x / right.origin.x,
                  y: left.origin.y / right.origin.y,
                  width: left.size.width / right.size.width,
                  height: left.size.height / right.size.height)
}

public func +=(left : inout CGRect, right: CGRect) {
    left = left + right
}

public func -=(left : inout CGRect, right: CGRect) {
    left = left - right
}

public func *=(left : inout CGRect, right: CGRect) {
    left = left * right
}

public func /=(left : inout CGRect, right: CGRect) {
    left = left / right
}

//CGSize
public func +(_ left: CGSize, _ right: CGSize) -> CGSize {
    return CGSize(width: left.width + right.width, height: left.height + right.height)
}

public func -(_ left: CGSize, _ right: CGSize) -> CGSize {
    return CGSize(width: left.width - right.width, height: left.height - right.height)
}

public func *(_ left: CGSize, _ right: CGSize) -> CGSize {
    return CGSize(width: left.width * right.width, height: left.height * right.height)
}

public func /(_ left: CGSize, _ right: CGSize) -> CGSize {
    return CGSize(width: left.width / right.width, height: left.height / right.height)
}

public func +=(left : inout CGSize, right: CGSize) {
    left = left + right
}

public func -=(left : inout CGSize, right: CGSize) {
    left = left - right
}

public func *=(left : inout CGSize, right: CGSize) {
    left = left * right
}

public func /=(left : inout CGSize, right: CGSize) {
    left = left / right
}







