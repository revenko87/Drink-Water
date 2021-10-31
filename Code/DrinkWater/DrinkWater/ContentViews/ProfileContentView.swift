//
//  ProfileContentView.swift
//  DrinkWater
//
//  Created by Revenko on 7/7/20.
//  Copyright © 202 Revenko. All rights reserved.
import SwiftUI

/// Profile screen where user can set their daily goal and weight
struct ProfileContentView: View {
    private let impactGenerator = UIImpactFeedbackGenerator()
    @State private var username: String = ""
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @ObservedObject var model: TrackingModel
    @ObservedObject var settingsModel: SettingsModel = SettingsModel()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    // Main rendering function for this view
    var body: some View {
        VStack {
            /// User profile image
            userProfileImage
            
            /// User name/имя
            userProfileName
            
            /// Footer view with the metrics system switch and sliders/Нижний колонтитул с переключателем системы показателей и ползунками
            VStack {
                metricsSystemSwitch
                
                /// Изменить селекторы на основе системы показателей
                selectors
            }
            .edgesIgnoringSafeArea(.bottom)
        }.sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: self.$inputImage).edgesIgnoringSafeArea(.bottom)
        }.onAppear(perform: {
            if let savedAvatar = UserDefaults.standard.data(forKey: "avatar") {
                self.inputImage = UIImage(data: savedAvatar)
            }
        })
    }
    
    /// Селекторы / ползунки выбора напитка и веса
    private var selectors: some View {
        ZStack {
            RoundedCorner(radius: 30, corners: [.topLeft, .topRight])
                .foregroundColor(Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)))
                .shadow(color: Color(.systemGray3).opacity(0.6), radius: 5, x: 0, y: -5)
            VStack(spacing: 30) {
                AmountSelectorView(model: settingsModel, selectorType: .volume)
                    .padding(.leading, 30)
                    .padding(.trailing, 30)
                AmountSelectorView(model: settingsModel, selectorType: .weight)
                    .padding(.leading, 30)
                    .padding(.trailing, 30)
            }.padding(.top, -20)
        }
        .frame(height: 270)
    }
    
    /// Кнопка "Готово" в правом верхнем углу
    private var doneButton: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color(#colorLiteral(red: 0, green: 0.5724389757, blue: 0.9686274529, alpha: 1)))
            Button(action: {
                self.model.userAvatar = self.inputImage
                self.model.fetchSettingsData()
                self.presentationMode.wrappedValue.dismiss()
                self.impactGenerator.impactOccurred()
            }, label: {
                Text("Done")
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .font(.system(size: 15))
            })
        }
        .frame(width: 75, height: 30)
    }
    
    /// картинка профайла польщователя
    private var userProfileImage: some View {
        VStack {
            HStack {
                Spacer()
                doneButton
            }.padding().padding(.top, 25)
            Image(uiImage: inputImage ?? UIImage(named: "placeholder")!)
                .resizable()
                .aspectRatio(contentMode: ContentMode.fill)
                .frame(maxWidth: 180, maxHeight: 180)
                .clipShape(Circle())
                .opacity(inputImage != nil ? 1.0 : 0.6)
                .padding(.bottom, 20)
                .onTapGesture {
                    self.showingImagePicker = true
            }
            Spacer()
        }
    }
    
    /// профайл пользователя
    private var userProfileName: some View {
        VStack {
            Divider().padding(.bottom, 10)
            HStack(alignment: .top) {
                Text("Имя").fontWeight(.medium)
                    .foregroundColor(Color(.systemGray))
                    .font(.system(size: 18))
                TextField(settingsModel.name, text: $username.onChange({ (name) in
                    self.settingsModel.didChangeUserName(name)
                })).multilineTextAlignment(.trailing)
            }
            .padding(.leading, 30)
            .padding(.trailing, 30)
        }
    }
    
    /// Переключатель системы показателей
    private var metricsSystemSwitch: some View {
        VStack {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color(.systemGray5))
                Button(action: {
                    self.settingsModel.changeMetricSystem()
                    self.impactGenerator.impactOccurred()
                }, label: {
                    Text(settingsModel.metricSystem.text).foregroundColor(.black)
                })
            }
            .frame(width: 130, height: 30)
            .padding(.bottom, 12)
            Spacer()
        }
    }
}

// MARK: - Canvas Preview
struct ProfileContentView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileContentView(model: TrackingModel())
    }
}
