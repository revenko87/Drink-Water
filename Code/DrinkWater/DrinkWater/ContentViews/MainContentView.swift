//
//  MainContentView.swift
//  DrinkWater
//
//  Created by Apps4World on 7/6/20.
//  Copyright © 2020 Apps4World. All rights reserved.
//

import SwiftUI

/// Main screen that user will see
struct MainContentView: View {
    
    @State private var inputImage: UIImage?
    @State private var isSettingsShowing: Bool = false
    @State private var isDrinkSelectorShowing: Bool = false
    @ObservedObject private var model: TrackingModel = TrackingModel()
    
    // Main rendering function for this view
    var body: some View {
        ZStack {
            ScrollView {
                /// Header view with the title and profile icon
                headerView

                /// Progress section
                progressSection
                
                Divider()
                
                /// History and Empty view
                if model.todayRecords.count == 0 {
                    EmptyStateView()
                } else {
                    HStack {
                        Text("История").font(.system(size: 30)).bold()
                        Spacer()
                    }.padding().padding(.bottom, -30)
                    
                    ForEach(model.todayRecords) { record in
                        HStack {
                            Text(record.formattedTime)
                            Rectangle().frame(height: 2).foregroundColor(.accentColor).cornerRadius(1)
                            Text(record.formattedVolume).fontWeight(.medium).font(.system(size: 20))
                        }.padding()
                    }
                }
            }
            
            /// Add drink plus button
            addDrinkButton
            
            /// Show drink selector
            if isDrinkSelectorShowing {
                DrinkSelectorView(model: model, isDrinkSelectorShowing: $isDrinkSelectorShowing)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear(perform: {
            self.model.setupPushNotifications()
            if let savedAvatar = UserDefaults.standard.data(forKey: "avatar") {
                self.inputImage = UIImage(data: savedAvatar)
            }
        }).sheet(isPresented: $isSettingsShowing) {
            ProfileContentView(model: self.model)
        }
    }
    
    /// Main header view with the title and profile icon on the right
    private var headerView: some View {
        VStack {
            HStack {
                Text("Привет, \(model.name)").font(.headline)
                Spacer()
            }.padding(.bottom, -20)
            HStack {
                Text("Сегодня").font(.largeTitle).fontWeight(.bold)
                Spacer()
                Image(uiImage: model.userAvatar ?? inputImage ?? UIImage(named: "placeholder")!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .opacity(inputImage != nil || model.userAvatar != nil ? 1.0 : 0.6)
                    .clipShape(Circle())
                    .onTapGesture {
                        self.isSettingsShowing = true
                }
            }
        }.padding()
    }
    
    /// Add drink record button
    private var addDrinkButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    self.isDrinkSelectorShowing = true
                }, label: {
                    ZStack {
                        Circle().foregroundColor(.orange).frame(width: 60, height: 60)
                        Rectangle().frame(width: 4, height: 25)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                        Rectangle().frame(width: 25, height: 4)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                }).shadow(color: Color(.secondaryLabel).opacity(0.4), radius: 10, x: 0, y: 0)
            }
        }.padding()
    }
    
    /// Progress section
    private var progressSection: some View {
        VStack {
            ZStack {
                HStack {
                    Spacer()
                    Image("bubble")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 180)
                    Spacer()
                }
                HStack(alignment: .bottom, spacing: 0) {
                    Text("\(model.percentage)").font(.largeTitle).foregroundColor(.white)
                    Text("%").fontWeight(.medium).foregroundColor(.white).padding(.bottom, 5)
                }
            }.frame(minHeight: 120)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Нужно выпить")
                        .fontWeight(.regular)
                        .font(.system(size: 20))
                        .foregroundColor(Color(.systemGray2))
                    Text("\(Int(model.dailyGoal)) \(model.metricSystem.volumeText)")
                        .fontWeight(.regular)
                        .font(.system(size: 25))
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Прогресс")
                        .fontWeight(.regular)
                        .font(.system(size: 20))
                        .foregroundColor(Color(.systemGray2))
                    Text("\(model.currentProgress) \(model.metricSystem.volumeText)")
                        .fontWeight(.regular)
                        .font(.system(size: 25))
                }
            }.padding()
        }
    }
}

// MARK: - Canvas Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
    }
}
