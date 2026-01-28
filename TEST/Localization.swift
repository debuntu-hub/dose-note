import Foundation

enum Language {
    case japanese
    case english
    
    static var current: Language {
        // CFBundleLocalizationsが未設定の場合、Locale.currentがenになることがあるため
        // ユーザーの優先言語設定（preferredLanguages）を確認する
        let preferred = Locale.preferredLanguages.first ?? "en"
        return preferred.hasPrefix("ja") ? .japanese : .english
    }
}

struct L10n {
    static func get(_ key: String) -> String {
        let lang = Language.current
        return translations[key]?[lang] ?? key
    }
    
    private static let translations: [String: [Language: String]] = [
        // ContentView
        "Current Month Record": [.japanese: "今月の記録", .english: "This Month"],
        "Dose Count": [.japanese: "服用回数", .english: "Total Doses"],
        "Count Suffix": [.japanese: "回", .english: ""], // 英語では数字のみでOKとするか、timesをつける
        "Average Interval": [.japanese: "平均間隔", .english: "Avg Interval"],
        "Days Suffix": [.japanese: "日", .english: "d"],
        "Premium": [.japanese: "Premium", .english: "Premium"],
        "All Time Record": [.japanese: "全期間の記録", .english: "All Time"],
        "Total Doses": [.japanese: "総服用回数", .english: "Total Doses"],
        "All Time Avg": [.japanese: "全期間平均", .english: "All Time Avg"],
        "Show Graph": [.japanese: "グラフを表示", .english: "View Graph"],
        "To See Details": [.japanese: "詳しく見るには", .english: "Unlock Details"],
        "Premium Required": [.japanese: "プレミアムプランが必要です", .english: "Premium Required"],
        "Take Medicine": [.japanese: "頭痛薬を飲んだ", .english: "Record Dose"],
        "Tap to Record": [.japanese: "タップして記録します", .english: "Tap to record now"],
        "History & Edit": [.japanese: "履歴を確認・編集", .english: "History & Edit"],
        "History View Title": [.japanese: "履歴と編集", .english: "History"],
        "Showing Last 30 Days": [.japanese: "過去30日分を表示中", .english: "Last 30 Days Shown"],
        "Show All History": [.japanese: "全履歴を表示", .english: "Show All"],
        "Record of": [.japanese: " の記録", .english: "'s Record"], // Date string + this
        "No Records Day": [.japanese: "この日の記録はありません", .english: "No records for this day"],
        "Select Date": [.japanese: "日付を選択してください", .english: "Select a date"],
        "Saving": [.japanese: "保存", .english: "Save"],
        "Edit Record": [.japanese: "記録の編集", .english: "Edit Record"],
        "Date Time": [.japanese: "日時", .english: "Date & Time"],
        "Dose Date": [.japanese: "服用日時", .english: "Time Taken"],

        // PaywallView
        "Premium Plan": [.japanese: "プレミアムプラン", .english: "Premium Plan"],
        "Premium Desc": [.japanese: "あなたの健康管理を\nもっと詳しく、便利に。", .english: "Manage your health\nsmarter and easier."],
        "History Access": [.japanese: "履歴閲覧", .english: "History Access"],
        "Recent 30 Days": [.japanese: "直近30日", .english: "Last 30 Days"],
        "Unlimited": [.japanese: "無制限", .english: "Unlimited"],
        "Avg Interval Display": [.japanese: "平均間隔の表示", .english: "Avg Interval Stats"],
        "All Time Stats": [.japanese: "全期間の統計", .english: "All Time Statistics"],
        "Ad Free": [.japanese: "広告", .english: "Ad Free"],
        "None": [.japanese: "なし", .english: "None"],
        "Included": [.japanese: "○", .english: "✓"],
        "Not Included": [.japanese: "×", .english: "✕"],
        "Loading Plan": [.japanese: "プラン情報を読み込み中...", .english: "Loading plans..."],
        "Disclaimer Title": [.japanese: "【重要】免責事項", .english: "Disclaimer"],
        "Disclaimer Text": [.japanese: "本アプリは服用履歴を記録・管理するためのツールです。医療行為、診断、治療を目的としたものではありません。", .english: "This app is for recording medication history only. It is not intended for medical advice, diagnosis, or treatment."],
        "Auto Renew Title": [.japanese: "自動更新に関する情報", .english: "Auto-Renewal Info"],
        "Auto Renew Text": [.japanese: "サブスクリプションは、有効期限の24時間前までにキャンセルされない限り自動的に更新されます。", .english: "Subscription automatically renews unless cancelled at least 24 hours before current period ends."],
        "Terms": [.japanese: "利用規約", .english: "Terms of Use"],
        "Privacy": [.japanese: "プライバシーポリシー", .english: "Privacy Policy"],
        "Manage Sub": [.japanese: "サブスクリプションの管理・解約", .english: "Manage Subscription"],
        "Restore": [.japanese: "購入の復元", .english: "Restore Purchase"],
        "Close": [.japanese: "閉じる", .english: "Close"],
        
        // StatsView
        "Interval Trend": [.japanese: "服用間隔の推移", .english: "Interval Trend"],
        "Trend Desc": [.japanese: "前回からの経過日数の変化", .english: "Changes in days between doses"],
        "Not Enough Data": [.japanese: "データが不足しています", .english: "Not Enough Data"],
        "Not Enough Data Desc": [.japanese: "グラフを表示するには、2回以上の服用記録が必要です。", .english: "At least 2 records needed to show graph."],
        "Recent Trend": [.japanese: "直近の傾向", .english: "Recent Trend"],
        "Interval Msg Part 1": [.japanese: "前回の服用から ", .english: "It's been "],
        "Interval Msg Part 2": [.japanese: " 日空きました。", .english: " days since last dose."],
        "Avg Msg Part 1": [.japanese: "全期間の平均ペースは ", .english: "All-time average pace is "],
        "Avg Msg Part 2": [.japanese: " 日です。", .english: " days."],
        "Stats Title": [.japanese: "統計分析", .english: "Statistics"],
        
        // EditView
        "Delete Record": [.japanese: "記録を削除", .english: "Delete Record"],
        "Delete Confirmation": [.japanese: "本当に削除しますか？", .english: "Are you sure?"],
        "Delete": [.japanese: "削除", .english: "Delete"],
        "Cancel": [.japanese: "キャンセル", .english: "Cancel"],
    ]
}

extension String {
    var localized: String {
        L10n.get(self)
    }
}
