//  Created by Revenko on 7/7/20.
//  Copyright © 202 Revenko. All rights reserved.


import SwiftUI

/// Отображается, когда пользователь готов добавить напиток
struct DrinkSelectorView: View {
    @ObservedObject var model: TrackingModel
    @Binding var isDrinkSelectorShowing: Bool
    @State private var bottomOffset: CGFloat = 200.0

    // Основная функция рендеринга для этого вида
    var body: some View {
        drinkSelector
            .onAppear(perform: {
                withAnimation(.spring()) { self.bottomOffset = 0 }
            })
    }
    
    /// Селектор / слайдер напитков
    private var drinkSelector: some View {
        ZStack {
            Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2)).onTapGesture {
                withAnimation(.spring()) { self.bottomOffset = 200 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.isDrinkSelectorShowing = false
                }
                self.model.resetSliderValue()
            }
            VStack {
                Spacer()
                ZStack {
                    RoundedCorner(radius: 30, corners: [.topLeft, .topRight])
                        .foregroundColor(Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)))
                        .shadow(color: Color(.systemGray3).opacity(0.6), radius: 5, x: 0, y: -5)
                    VStack(spacing: 30) {
                        AmountSelectorView(model: model, selectorType: .volume)
                            .padding(.leading, 30)
                            .padding(.trailing, 30)
                        doneButton
                    }
                }.frame(height: 200).offset(y: bottomOffset)
            }
        }
    }
    
    /// Кнопка "Готово" в правом верхнем углу
    private var doneButton: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.white)
            Button(action: {
                self.model.updateCurrentValue()
                withAnimation(.spring()) { self.bottomOffset = 200 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.isDrinkSelectorShowing = false
                }
            }, label: {
                Text("Готово")
                    .foregroundColor(Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)))
                    .fontWeight(.semibold)
                    .font(.system(size: 15))
            })
        } .frame(width: 75, height: 30)
    }
}
