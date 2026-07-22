//
//  FormDivider.swift
//  UIComponents
//
//  Created by Michael Ellis on 7/21/26.
//

import SwiftUI

public struct FormDivider: View {
    
    public enum Config {
        case subtle
        case regular
        
        var opacity: CGFloat {
            switch self {
            case .subtle: return 0.35
            case .regular: return 1
            }
        }
    }
    
    private var config: Config = .regular
    
    public init(config: Config = .regular) {
        self.config = config
    }

    public var body: some View {
        Divider()
            .opacity(config.opacity)
            .padding(.leading, 16)
    }
}
