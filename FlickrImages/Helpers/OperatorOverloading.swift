//
//  OperatorOverloading.swift
//  FlickrImages
//
//  Created by Sandeep Kumar on 05/07/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

protocol OptionalType { init() }

//MARK:- EXTENSIONS
extension String: OptionalType {}
extension Int: OptionalType {}
extension Double: OptionalType {}
extension Bool: OptionalType {}
extension Float: OptionalType {}
extension CGFloat: OptionalType {}
extension CGRect: OptionalType {}
extension UIImage: OptionalType {}
extension IndexPath: OptionalType {}
extension Int64: OptionalType {}

prefix operator /

// provides shortcut to upwrap optional variables with their default value.
prefix func /<T: OptionalType>( value: T?) -> T {
  guard let validValue = value else { return T() }
  return validValue
}
