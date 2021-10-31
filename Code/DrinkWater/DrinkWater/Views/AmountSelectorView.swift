//
//  AmountSelectorView.swift
//  DrinkWater
//
//  Created by Apps4World on 7/6/20.
//  Copyright © 2020 Apps4World. All rights reserved.
//

import SwiftUI

/// Slider selector type
enum AmountSelectorType: String {
    case volume
    case weight
}

/// Custom slider for weight and volume
struct AmountSelectorView: View {
    
    @State var xOffset: CGFloat = 0
    @State var sliderValue: Double = 0.0
    @State var didChangeDefaultValue: Bool = false
    @ObservedObject var model: SettingsModel
    
    /// Type of selector
    var selectorType: AmountSelectorType = .volume
    
    // Main rendering function for this view
    var body: some View {
        VStack(spacing: 8) {
            selectorValueTitleText
            GeometryReader { reader in
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(height: 30)
                        .foregroundColor(.secondary)
                    Circle()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.white)
                        .offset(x: self.didChangeDefaultValue ? self.xOffset : -((reader.size.width/2) - 16))
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    self.didChangeDefaultValue = true
                                    let location = value.location.x - 11
                                    let sliderEndValue = (reader.size.width/2) - 16
                                    self.xOffset = abs(location) > sliderEndValue ? (location > 0 ? sliderEndValue : -sliderEndValue) : location
                                    let position = (sliderEndValue * 2) - (sliderEndValue - location)
                                    let updatedValue = position.map(from: 0...(reader.size.width - 32), to: self.model.sliderRange(type: self.selectorType))
                                    if updatedValue > self.model.sliderRange(type: self.selectorType).upperBound {
                                        self.sliderValue = Double(self.model.sliderRange(type: self.selectorType).upperBound)
                                    } else if updatedValue < self.model.sliderRange(type: self.selectorType).lowerBound {
                                        self.sliderValue = Double(self.model.sliderRange(type: self.selectorType).lowerBound)
                                    } else {
                                        self.sliderValue = Double(updatedValue)
                                    }
                                    
                                    /// Save user changes
                                    if self.selectorType == .volume {
                                        self.model.didChangeIntakeGoal(self.sliderValue, offset: self.xOffset)
                                    } else {
                                        self.model.didChangeWeight(self.sliderValue, offset: self.xOffset)
                                    }
                            }
                    )
                }
            }.frame(height: 35)
            
            /// Recommended water based on weight
            if selectorType == .weight {
                Text("Рекомендовано выпить: \(model.recommendedWater)")
                    .foregroundColor(.white)
            }
        }.onAppear(perform: {
            self.sliderValue = self.model.sliderSavedValue(type: self.selectorType)
            if let offset = self.model.sliderSavedOffset(type: self.selectorType) {
                self.xOffset = offset
                self.didChangeDefaultValue = true
            }
        })
    }
    
    /// The title and value for a selector/slider
    private var selectorValueTitleText: some View {
        HStack {
            Text(model.sliderText(type: selectorType).title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Spacer()
            Text(String(format: "%.f %@", self.model.sliderSavedValue(type: self.selectorType), model.sliderText(type: selectorType).type))
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Canvas Preview
struct AmountSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        AmountSelectorView(model: SettingsModel())
    }
}
