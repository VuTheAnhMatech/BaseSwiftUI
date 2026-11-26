//
//  Notification+Ext.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 5/5/26.
//

import UIKit

extension Notification.Name {
    static let didRequestFinishIAPFlow = Notification.Name("didRequestFinishIAPFlow")
    static let didFinishAfterIntroTrigger = Notification.Name("didFinishAfterIntroTrigger")
    static let didRequestIAPPurchaseNetworkFailureAlert = Notification.Name("didRequestIAPPurchaseNetworkFailureAlert")
    static let didUpdateAppNetworkStatus = Notification.Name("didUpdateAppNetworkStatus")
    static let didLoadInterstitialSuccess = Notification.Name("load_interstitial_success")
}
