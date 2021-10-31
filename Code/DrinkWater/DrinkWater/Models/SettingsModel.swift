//
//  SettingsModel.swift
//  DrinkWater
//
//  Created by Apps4World on 7/7/20.
//  Copyright © 2020 Apps4World. All rights reserved.
//

import UIKit

/// Метрическая система, используемая приложением для США и других стран.
enum MetricSystem: String {
    case us, eu
    
    /// Текст для метрической системы
    var text: String {
        if self == .us {
            return "Фунтов | Унций"
        }
        return "кг | мл"
    }
    
    /// Объемная метрика
    var volumeText: String {
        self == .us ? "Унций" : "мл"
    }
    
    ///Коэффициент конверсии для метрической системы
    /// 1 унция = 29,57 мл и 1 фунт = 0,45 кг
    static func rate(type: AmountSelectorType) -> CGFloat {
        return type == .volume ? 29.57 : 0.45
    }
    
    /// Соотношение веса и рекомендуемой суточной нормы потребления воды
    var weightWaterRatio: Double {
        self == .us ? 0.75 : 30.33 /// 0,75 унции на 1 фунт веса И 30,33 мл на 1 кг
    }
}

/// пуш уведомления
enum PushNotification: String, CaseIterable {
    case morning = "Good morning! Get some water and have a nice day!"
    case noon = "Hey, don't forget to stay hydrated"
    case evening = "Check-in and see your progress"
    
    /// Час дня установлен в 24-часовом формате
    var time: DateComponents {
        var components = DateComponents()
        switch self {
        case .morning:
            components.hour = 9
        case .noon:
            components.hour = 13
        case .evening:
            components.hour = 17
        }
        return components
    }
}

/// Основная модель для пользовательских настроек
class SettingsModel: ObservableObject {
    @Published var metricSystem: MetricSystem = .us
    @Published var userAvatar: UIImage?
    
    /// Инициализатор по умолчанию
    init() { fetchSettingsData() }
    
    func fetchSettingsData() {
        if let savedMetricSystem = UserDefaults.standard.string(forKey: "metricSystem") {
            metricSystem = MetricSystem(rawValue: savedMetricSystem) ?? .us
        }
        name = UserDefaults.standard.string(forKey: "name") ?? "Guest"
        recommendedWater = "\(Int(sliderSavedValue(type: .weight) * metricSystem.weightWaterRatio)) \(metricSystem == .us ? "Унций" : "мл")"
    }
    
    /// Детали в зависимости от типа селектора
    func sliderText(type: AmountSelectorType) -> (title: String, type: String) {
        switch type {
        case .volume:
            return ("Необходимо выпить", metricSystem == .us ? "Унций" : "мл")
        case .weight:
            return ("Ваш вес:", metricSystem == .us ? "Фунтов" : "кг")
        }
    }
    
    /// Диапазон ползунка в зависимости от типа селектора
    func sliderRange(type: AmountSelectorType) -> ClosedRange<CGFloat> {
        switch type {
        case .volume:
            return metricSystem == .us ? 34...380 : 20...10000
        case .weight:
            return metricSystem == .us ? 50...400 : 30...150
        }
    }
    
    /// Сохраненное значение ползунка
    func sliderSavedValue(type: AmountSelectorType) -> Double {
        let value = UserDefaults.standard.double(forKey: "\(type.rawValue)_\(metricSystem.rawValue)")
        return value == 0.0 ? Double(sliderRange(type: type).lowerBound) : value
    }
    
    func sliderSavedOffset(type: AmountSelectorType) -> CGFloat? {
        UserDefaults.standard.object(forKey: "offset_\(type.rawValue)") as? CGFloat
    }
    
    /// юзер имя
    var name: String = UserDefaults.standard.string(forKey: "name") ?? "Guest"
    
    /// Recommended water based on weight
    var recommendedWater: String = ""
        
    // MARK: - User's actions
    func changeMetricSystem() {
        metricSystem = metricSystem != .us ? .us : .eu
        UserDefaults.standard.set(metricSystem.rawValue, forKey: "metricSystem")
        UserDefaults.standard.synchronize()
        recommendedWater = "\(Int(sliderSavedValue(type: .weight) * metricSystem.weightWaterRatio)) \(metricSystem.volumeText)"
    }
    
    func didChangeUserName(_ name: String) {
        UserDefaults.standard.set(name, forKey: "name")
        UserDefaults.standard.synchronize()
    }
    
    func didChangeIntakeGoal(_ value: Double, offset: CGFloat) {
        saveChangedValue(type: .volume, value: value, offset: offset)
    }
    
    func didChangeWeight(_ value: Double, offset: CGFloat) {
        saveChangedValue(type: .weight, value: value, offset: offset)
        recommendedWater = "\(Int(sliderSavedValue(type: .weight) * metricSystem.weightWaterRatio)) \(metricSystem.volumeText)"
    }
    
    func setupPushNotifications() {
        requestPushNotificationsPermissions()
    }
    
    private func requestPushNotificationsPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if !granted || error != nil {
                /// User declined push notification permissions
            } else { self.schedulePushNotifications() }
        }
    }
    
    private func schedulePushNotifications() {
        if UserDefaults.standard.bool(forKey: "didSetupPushNotifications") { return }
        PushNotification.allCases.forEach { (push) in
            let content = UNMutableNotificationContent()
            content.title = push.rawValue
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(dateMatching: push.time, repeats: true)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let errorMessage = error?.localizedDescription {
                    print("NOTIFICATION ERROR: \(errorMessage)")
                } else {
                    UserDefaults.standard.set(true, forKey: "didSetupPushNotifications")
                    UserDefaults.standard.synchronize()
                }
            }
        }
    }
    
    private func saveChangedValue(type: AmountSelectorType, value: Double, offset: CGFloat) {
        if metricSystem == .us {
            UserDefaults.standard.set(value * Double(MetricSystem.rate(type: type)),
                                      forKey: "\(type.rawValue)_\(MetricSystem.eu.rawValue)")
        } else {
            UserDefaults.standard.set(value / Double(MetricSystem.rate(type: type)),
                                      forKey: "\(type.rawValue)_\(MetricSystem.us.rawValue)")
        }
        UserDefaults.standard.set(value, forKey: "\(type)_\(metricSystem.rawValue)")
        UserDefaults.standard.set(offset, forKey: "offset_\(type.rawValue)")
        UserDefaults.standard.synchronize()
    }
}
