//
//  TrackingModel.swift
//  DrinkWater
//
//  Created by Apps4World on 7/7/20.
//  Copyright © 2020 Apps4World. All rights reserved.
//

import UIKit

/// Drink record
struct DrinkRecord: Identifiable {
    var id: String = UUID().uuidString
    var timestamp: TimeInterval
    var recordVolume: Int
    var metricSystem: MetricSystem
    //привет сафир
    /// Для отображения в разделе истории
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.locale =  Locale(identifier: "ru_RU")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date(timeIntervalSince1970: timestamp))
    }
    
    var formattedVolume: String {
        "\(recordVolume) \(metricSystem == .us ? "Унций" : "мл")"
    }
}

/// Основная модель для отслеживания прогресса
class TrackingModel: SettingsModel {

    /// Текущий прогресс на сегодня
    @Published var currentProgress: Int = 0
    private var sliderValue: Double = 0
    
    /// Ключ сохраненных данных
    private var savedDataKey: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM, dd"
        return dateFormatter.string(from: Date())
    }
    
    /// Сохраненная метрическая система / тип
    var dailyGoal: Double = 0.0
    
    /// сегодняшняя дата
    var todayRecords: [DrinkRecord] {
        if let data = UserDefaults.standard.value(forKey: savedDataKey) as? [String: Int] {
            var items = [DrinkRecord]()
            data.forEach { (interval, record) in
                if interval.contains(metricSystem.rawValue) {
                    items.append(DrinkRecord(timestamp: TimeInterval(interval.split(separator: "_").first!)!,
                                             recordVolume: record, metricSystem: metricSystem))
                }
            }
            return items.sorted(by: { $0.timestamp > $1.timestamp })
        }
        return []
    }
    
    /// Процентное значение
    var percentage: Int {
        (currentProgress * 100) / Int(dailyGoal)
    }
    
    /// Получить данные сохраненных настроек
    override func fetchSettingsData() {
        super.fetchSettingsData()
        dailyGoal = UserDefaults.standard.double(forKey: "\(AmountSelectorType.volume.rawValue)_\(metricSystem.rawValue)")
        if dailyGoal == 0.0 { dailyGoal = Double(sliderRange(type: .volume).lowerBound) }
        currentProgress = todayRecords.compactMap({ $0.recordVolume }).reduce(0, +)
    }
    
    override func sliderText(type: AmountSelectorType) -> (title: String, type: String) {
        ("Сколько сейчас вы выпили?", metricSystem == .us ? "Унций" : "мл")
    }
    
    override func sliderSavedValue(type: AmountSelectorType) -> Double {
        sliderValue == 0 ? Double(sliderRange(type: type).lowerBound) : Double(sliderValue)
    }
    
    override func sliderSavedOffset(type: AmountSelectorType) -> CGFloat? {
        nil
    }
    
    private func addProgress() {
        sliderValue = sliderSavedValue(type: .volume)
        var data = [String: Int]()
        if metricSystem == .us {
            data["\(Date().timeIntervalSince1970)_\(MetricSystem.eu.rawValue)"] = Int(sliderValue) * Int(MetricSystem.rate(type: .volume))
        } else {
            data["\(Date().timeIntervalSince1970)_\(MetricSystem.us.rawValue)"] = Int(sliderValue) / Int(MetricSystem.rate(type: .volume))
        }
        data["\(Date().timeIntervalSince1970)_\(metricSystem.rawValue)"] = Int(sliderValue)
        if let savedData = UserDefaults.standard.value(forKey: savedDataKey) as? [String: Int] {
            savedData.forEach({ data[$0.key] = $0.value })
        }
        UserDefaults.standard.set(data, forKey: savedDataKey)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - User's action
    func updateCurrentValue() {
        addProgress()
        currentProgress += Int(sliderValue)
        resetSliderValue()
    }
    
    func resetSliderValue() {
        sliderValue = 0
    }
    
    override func didChangeIntakeGoal(_ value: Double, offset: CGFloat) {
        sliderValue = value
    }
}
