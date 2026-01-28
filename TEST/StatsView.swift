import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var store: DoseStore
    @ObservedObject var storeManager: StoreManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Interval Trend".localized)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Trend Desc".localized)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top)

                if store.intervalHistory.isEmpty {
                    ContentUnavailableView("Not Enough Data".localized, 
                        systemImage: "chart.xyaxis.line", 
                        description: Text("Not Enough Data Desc".localized))
                } else {
                    // Chart
                    VStack {
                        Chart {
                            ForEach(store.intervalHistory) { point in
                                LineMark(
                                    x: .value("Date", point.date),
                                    y: .value("Interval", point.intervalDays)
                                )
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(Color.blue.gradient)
                                .symbol(by: .value("Date", point.date))
                                
                                PointMark(
                                    x: .value("Date", point.date),
                                    y: .value("Interval", point.intervalDays)
                                )
                                .foregroundStyle(.blue)
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        .frame(height: 300)
                        .padding()
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                
                // Insights (Optional text)
                if let last = store.intervalHistory.last {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent Trend".localized)
                            .font(.headline)
                        
                        Text("Interval Msg Part 1".localized + String(format: "%.1f", last.intervalDays) + "Interval Msg Part 2".localized)
                            .font(.body)
                        
                        if let avg = store.allTimeAverageIntervalDays {
                            Text("Avg Msg Part 1".localized + String(format: "%.1f", avg) + "Avg Msg Part 2".localized)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .navigationTitle("Stats Title".localized)
    }
}
