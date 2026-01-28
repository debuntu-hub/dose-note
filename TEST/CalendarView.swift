import SwiftUI
import UIKit

struct CalendarView: UIViewRepresentable {
    let doses: [Dose]
    @Binding var selectedDate: DateComponents?

    func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        view.calendar = Calendar(identifier: .gregorian)
        view.locale = Locale.current // Use system locale
        view.fontDesign = .rounded
        view.availableDateRange = DateInterval(start: Date.distantPast, end: Date.distantFuture)
        view.delegate = context.coordinator
        
        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        selection.selectedDate = selectedDate
        view.selectionBehavior = selection
        
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        return view
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        // Reload decorations
        let uniqueDates = Set(doses.map {
            Calendar.current.dateComponents([.year, .month, .day], from: $0.date)
        })
        uiView.reloadDecorations(forDateComponents: Array(uniqueDates), animated: true)
        
        // Update selection if changed externally
        if let selection = uiView.selectionBehavior as? UICalendarSelectionSingleDate {
            selection.setSelected(selectedDate, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: CalendarView

        init(parent: CalendarView) {
            self.parent = parent
        }

        // Decoration
        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            let count = parent.doses.filter { dose in
                let doseComponents = Calendar.current.dateComponents([.year, .month, .day], from: dose.date)
                return doseComponents.year == dateComponents.year &&
                       doseComponents.month == dateComponents.month &&
                       doseComponents.day == dateComponents.day
            }.count

            if count > 0 {
                return .image(UIImage(systemName: "pill.fill"), color: .systemBlue, size: .medium)
            }
            return nil
        }
        
        // Selection
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            parent.selectedDate = dateComponents
        }
    }
}
