import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var store = DoseStore()
    @StateObject private var storeManager = StoreManager()
    @State private var showingPaywall = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    
                    // Summary Card (Current Month) - FREE
                    VStack(spacing: 15) {
                        Text("Current Month Record".localized)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Dose Count".localized)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("\(store.currentMonthCount)" + "Count Suffix".localized)
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundStyle(Color.primary)
                            }
                            
                            Spacer()
                            
                            // Locked Feature: Average Interval for Month
                            VStack(alignment: .trailing) {
                                Text("Average Interval".localized)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                if storeManager.isPremium {
                                    if let avg = store.averageIntervalDays {
                                        Text(String(format: "%.1f", avg) + "Days Suffix".localized)
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundStyle(Color.primary)
                                    } else {
                                        Text("-- " + "Days Suffix".localized)
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundStyle(.secondary)
                                    }
                                } else {
                                    // Lock Icon
                                    HStack(spacing: 4) {
                                        Image(systemName: "lock.fill")
                                            .font(.headline)
                                        Text("Premium".localized)
                                            .font(.caption)
                                            .fontWeight(.bold)
                                    }
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 4)
                                    .onTapGesture {
                                        showingPaywall = true
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Summary Card (All Time) - PREMIUM ONLY
                    VStack(spacing: 15) {
                        HStack {
                            Text("All Time Record".localized)
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            if !storeManager.isPremium {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(.secondary)
                            } else {
                                // Graph Link for Premium
                                NavigationLink(destination: StatsView(store: store, storeManager: storeManager)) {
                                    HStack {
                                        Image(systemName: "chart.xyaxis.line")
                                        Text("Show Graph".localized)
                                    }
                                    .font(.caption)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                        if storeManager.isPremium {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Total Doses".localized)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Text("\(store.allTimeCount)" + "Count Suffix".localized)
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundStyle(Color.primary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("All Time Avg".localized)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    if let avg = store.allTimeAverageIntervalDays {
                                        Text(String(format: "%.1f", avg) + "Days Suffix".localized)
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundStyle(Color.primary)
                                    } else {
                                        Text("-- " + "Days Suffix".localized)
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        } else {
                            // Locked State Content
                            Button(action: {
                                showingPaywall = true
                            }) {
                                VStack(spacing: 8) {
                                    Text("To See Details".localized)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text("Premium Required".localized)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 1)
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    Spacer()

                    // Main Action Button
                    Button(action: {
                        store.addDose()
                    }) {
                        Text("Take Medicine".localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color.blue)
                            .cornerRadius(20)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    
                    Text("Tap to Record".localized)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()
                    
                    // Navigation to History
                    NavigationLink(destination: HistoryView(store: store, storeManager: storeManager)) {
                        HStack {
                            Image(systemName: "calendar")
                            Text("History & Edit".localized)
                        }
                        .font(.headline)
                        .padding()
                    }
                }
                .padding(.top)
            }
            .navigationTitle(Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Dose Note")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingPaywall = true
                    }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView(storeManager: storeManager, store: store)
            }
        }
    }
}

struct HistoryView: View {
    @ObservedObject var store: DoseStore
    @ObservedObject var storeManager: StoreManager
    @State private var showingPaywall = false
    @State private var selectedDateComponents: DateComponents? = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    
    // Logic to filter doses based on plan
    var displayedDoses: [Dose] {
        if storeManager.isPremium {
            return store.doses
        } else {
            // Only last 30 days
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            return store.doses.filter { $0.date >= thirtyDaysAgo }
        }
    }
    
    // Filter doses for the selected date
    var selectedDateDoses: [Dose] {
        guard let components = selectedDateComponents,
              let date = Calendar.current.date(from: components) else {
            return []
        }
        
        // This sorting order (newest first) matches standard history UI
        let filtered = displayedDoses.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
        return filtered.sorted(by: { $0.date > $1.date }) 
    }
    
    var body: some View {
        VStack {
            // Calendar View with Date Selection
            VStack {
                if !storeManager.isPremium {
                    Button(action: {
                        showingPaywall = true
                    }) {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.yellow)
                            Text("Showing Last 30 Days".localized)
                                .font(.subheadline)
                            Text("Show All History".localized)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.blue)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
                
                CalendarView(doses: displayedDoses, selectedDate: $selectedDateComponents)
                    .padding()
            }
            .padding(.bottom, 10)
            
            Divider()
            
            // List for Selected Date
            VStack(alignment: .leading) {
                if let components = selectedDateComponents,
                   let date = Calendar.current.date(from: components) {
                    
                    Text("\(date.formatted(date: .complete, time: .omitted))" + "Record of".localized)
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    if selectedDateDoses.isEmpty {
                        ContentUnavailableView("No Records Day".localized, systemImage: "calendar.badge.minus")
                    } else {
                        List {
                            ForEach(selectedDateDoses) { dose in
                                NavigationLink(destination: EditDoseView(store: store, dose: dose)) {
                                    HStack {
                                        Text(dose.dateString)
                                            .font(.body)
                                        Spacer()
                                    }
                                }
                            }
                            .onDelete { indexSet in
                                indexSet.forEach { index in
                                    let doseToDelete = selectedDateDoses[index]
                                    store.deleteDose(doseToDelete)
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                } else {
                    ContentUnavailableView("Select Date".localized, systemImage: "calendar")
                }
            }
            
            Spacer()
        }
        .navigationTitle("History View Title".localized)
        .sheet(isPresented: $showingPaywall) {
            PaywallView(storeManager: storeManager, store: store)
        }
    }
}

struct EditDoseView: View {
    @ObservedObject var store: DoseStore
    @State var dose: Dose
    @Environment(\.dismiss) var dismiss
    @State private var showingDeleteAlert = false

    var body: some View {
        Form {
            Section(header: Text("Date Time".localized)) {
                DatePicker("Dose Date".localized, selection: $dose.date)
                    .environment(\.locale, Locale.current)
            }
            
            Section {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Text("Delete Record".localized)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("Edit Record".localized)
        .toolbar {
            Button("Saving".localized) {
                store.updateDose(dose)
                dismiss()
            }
        }
        .alert("Delete Record".localized, isPresented: $showingDeleteAlert) {
            Button("Delete".localized, role: .destructive) {
                store.deleteDose(dose)
                dismiss()
            }
            Button("Cancel".localized, role: .cancel) { }
        } message: {
            Text("Delete Confirmation".localized)
        }
    }
}

#Preview {
    ContentView()
}
