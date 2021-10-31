//  Created by Revenko on 7/7/20.
//  Copyright © 202 Revenko. All rights reserved.
//

//

import SwiftUI

/// Тип переключателя слайдера
enum AmountSelectorType: String {
    case volume
    case weight
}

/// Пользовательский слайдер для веса и объема
struct AmountSelectorView: View {
    
    @State var xOffset: CGFloat = 0
    @State var sliderValue: Double = 0.0
    @State var didChangeDefaultValue: Bool = false
    @ObservedObject var model: SettingsModel
    
    /// Тип селектора
    var selectorType: AmountSelectorType = .volume
    
    // Основная функция рендеринга для этого вида
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
                                    
                                    /// Сохранить изменения пользователя
                                    if self.selectorType == .volume {
                                        self.model.didChangeIntakeGoal(self.sliderValue, offset: self.xOffset)
                                    } else {
                                        self.model.didChangeWeight(self.sliderValue, offset: self.xOffset)
                                    }
                            }
                    )
                }
            }.frame(height: 35)
            
            /// Рекомендуемая вода в зависимости от веса
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
    
    /// Название и значение для селектора / слайдера.
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

