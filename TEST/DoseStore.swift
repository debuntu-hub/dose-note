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
        // _doses に直接代入することで didSet（save()）が init 中に発火するのを防ぐ
        let key = "doses_history"
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Dose].self, from: data) {
            _doses = Published(wrappedValue: decoded)
        }
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

    /// Calculates the average interval: (Now - FirstDose) / (Count - 1)
    private func calculatePaceIncludingNow(for targetDoses: [Dose]) -> Double? {
        // Need at least 2 doses to calculate an interval
        guard targetDoses.count >= 2 else { return nil }
        
        // Data must be sorted oldest first for time calculation
        let sortedDoses = targetDoses.sorted(by: { $0.date < $1.date })
        guard let firstDose = sortedDoses.first else { return nil }
        
        let now = Date()
        let totalDuration = max(0, now.timeIntervalSince(firstDose.date))
        
        let intervals = Double(targetDoses.count - 1)
        
        // Formula: Total duration since first dose / Number of intervals
        let averageSeconds = totalDuration / intervals
        
        return averageSeconds / (60 * 60 * 24) // Convert seconds to days
    }

    // MARK: - Graph Data
    
    nonisolated struct IntervalDataPoint: Identifiable, Sendable {
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
    
    // MARK: - Persistence
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(doses) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
}
