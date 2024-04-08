//
//  UIDevice+Helpers.swift
//  Deeplinks
//
//  Created by Geza Dezso on 04/04/2024.
//

import UIKit

var isIPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }

var isIPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

var isTV: Bool { UIDevice.current.userInterfaceIdiom == .tv }
