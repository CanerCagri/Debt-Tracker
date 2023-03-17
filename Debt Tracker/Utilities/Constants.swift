//
//  Constants.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 22.02.2023.
//

import UIKit

struct K {
    static let facebookPublicProfile = "public_profile"
    static let facebookEmail = "email"
    static let string2fFormat = "%.2f"
    static let dateFormatter02dFormat = "%02d"
    static let creditsDetailVcDateFormat = "dd.MM.yyyy"
    static let appleProviderID = "apple.com"
    static let startingLocale = "en_US"
    static let numberFormatterGroupingSeparator = "."
    static let creditsCollectionViewCellIdentifier = "CreditsCollectionViewCell"
}

struct Colors {
    static let facebookTitleColor = UIColor.white
    static let facebookBackgroundColor = UIColor(red: 88/255.0, green: 86/255.0, blue: 214/255.0, alpha: 1.0)
    static let darkModeColor = UIColor(red: 28/255, green: 30/255, blue: 33/255, alpha: 1.0)
    static let lightModeColor = UIColor.secondarySystemBackground
}

struct SFSymbols {
    static let createCreditTabSymbol = "plus.message"
    static let creditsTabSymbol = "list.bullet.circle"
    static let logoutSymbol = "power"
    static let hidePasswordSymbol = "eye.slash"
    static let showPasswordSymbol = "eye"
    static let closeSymbol = "xmark.circle.fill"
    static let emptyStateSymbol = "plus.message.fill"
    static let checkMarkSymbol = "checkmark.circle"
    static let resetSymbol = "arrow.clockwise"
    static let saveSymbol = "square.and.arrow.down"
}

enum ScreenSize {
    static let width        = UIScreen.main.bounds.size.width
    static let height       = UIScreen.main.bounds.size.height
    static let maxLength    = max(ScreenSize.width, ScreenSize.height)
    static let minLength    = min(ScreenSize.width, ScreenSize.height)
}

enum DeviceTypes {
    static let idiom                    = UIDevice.current.userInterfaceIdiom
    static let nativeScale              = UIScreen.main.nativeScale
    static let scale                    = UIScreen.main.scale
    
    static let isiPhoneSE               = idiom == .phone && ScreenSize.maxLength == 568.0
    static let isiPhone8Standard        = idiom == .phone && ScreenSize.maxLength == 667.0 && nativeScale == scale
    static let isiPhone8Zoomed          = idiom == .phone && ScreenSize.maxLength == 667.0 && nativeScale > scale
    static let isiPhone8PlusStandard    = idiom == .phone && ScreenSize.maxLength == 736.0
    static let isiPhone8PlusZoomed      = idiom == .phone && ScreenSize.maxLength == 736.0 && nativeScale < scale
    static let isiPhoneX                = idiom == .phone && ScreenSize.maxLength == 812.0
    static let isiPhoneXsMaxAndXr       = idiom == .phone && ScreenSize.maxLength == 896.0
    static let isiPad                   = idiom == .pad && ScreenSize.maxLength >= 1024.0
    
    static func isiPhoneXAspectRatio() -> Bool {
        return isiPhoneX || isiPhoneXsMaxAndXr
    }
}
