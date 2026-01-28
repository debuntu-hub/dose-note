import Foundation
import SwiftUI
import Combine

final class DoseStore: ObservableObject {
    @Published var doses: [Dose] = [] {
        didSet {
            save()
        }
    }
    
    private let calendar = Calendar.current
    private let storageKey = "doses_history"
    
    init() {
        load()
    }
    
    // MARK: - Actions
    
    func addDose() {
        let newDose = Dose(id: UUID(), date: Date())
        doses.insert(newDose, at: 0)
    }
    
    // IndexSet based delete (for main list if needed, but risky with filtered views)
    func deleteDose(at offsets: IndexSet) {
        doses.remove(atOffsets: offsets)
    }

    // ID based delete (safer for filtered lists)
    func deleteDose(_ dose: Dose) {
        if let index = doses.firstIndex(where: { $0.id == dose.id }) {
            doses.remove(at: index)
        }
    }

    func updateDose(_ updatedDose: Dose) {
        if let index = doses.firstIndex(where: { $0.id == updatedDose.id }) {
            doses[index] = updatedDose
            doses.sort(by: { $0.date > $1.date }) // Keep latest first
        }
    }
    
    // MARK: - Statistics Logic
    
    // Filter doses for the current month
    private var currentMonthDoses: [Dose] {
        let now = Date()
        return doses.filter {
            calendar.isDate($0.date, equalTo: now, toGranularity: .month) &&
            calendar.isDate($0.date, equalTo: now, toGranularity: .year)
        }
    }
    
    // F03: Monthly Count
    var currentMonthCount: Int {
        currentMonthDoses.count
    }
    
    // F04: Average Interval (Days) - Updated to include time until NOW
    var averageIntervalDays: Double? {
        calculatePaceIncludingNow(for: currentMonthDoses)
    }

    // All Time Count
    var allTimeCount: Int {
        doses.count
    }

    // All Time Average Interval (Days) - Updated to include time until NOW
    var allTimeAverageIntervalDays: Double? {
        calculatePaceIncludingNow(for: doses)
    }

    /// Calculates the average pace: (Now - FirstDose) / Count
    private func calculatePaceIncludingNow(for targetDoses: [Dose]) -> Double? {
        guard !targetDoses.isEmpty else { return nil }
        
        // Data must be sorted oldest first for time calculation
        let sortedDoses = targetDoses.sorted(by: { $0.date < $1.date })
        guard let firstDose = sortedDoses.first else { return nil }
        
        let now = Date()
        let totalDuration = max(0, now.timeIntervalSince(firstDose.date))
        
        let count = Double(targetDoses.count)
        
        // Formula: Total duration since first dose / Number of doses
        let averageSeconds = totalDuration / count
        
        return averageSeconds / (60 * 60 * 24) // Convert seconds to days
    }

    // MARK: - Graph Data
    
    struct IntervalDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let intervalDays: Double
    }
    
    var intervalHistory: [IntervalDataPoint] {
        let sortedDoses = doses.sorted(by: { $0.date < $1.date })
        guard sortedDoses.count >= 2 else { return [] }
        
        var points: [IntervalDataPoint] = []
        
        for i in 1..<sortedDoses.count {
            let current = sortedDoses[i]
            let previous = sortedDoses[i-1]
            let interval = current.date.timeIntervalSince(previous.date)
            let days = interval / (60 * 60 * 24)
            
            points.append(IntervalDataPoint(date: current.date, intervalDays: days))
        }
        
        return points
    }
    
    // MARK: - Debug
    
#if DEBUG
    func createDummyData() {
        var dummyDoses: [Dose] = []
        let calendar = Calendar.current
        let now = Date()
        
        // Generate past 3 months of data
        for dayOffset in 0..<90 {
            // Randomly decide to skip days (simulate irregular intake)
            if Int.random(in: 0...2) == 0 {
                continue
            }
            
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) {
                // Random time during the day
                let hour = Int.random(in: 8...22)
                let minute = Int.random(in: 0...59)
                
                if let doseDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) {
                    dummyDoses.append(Dose(id: UUID(), date: doseDate))
                }
            }
        }
        
        // Replace current data with dummy data sorted descending
        self.doses = dummyDoses.sorted(by: { $0.date > $1.date })
    }
    
    func clearData() {
        self.doses = []
    }
#endif
    
    // MARK: - Persistence
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(doses) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Dose].self, from: data) {
            doses = decoded
        }
    }
}
