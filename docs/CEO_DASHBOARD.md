# 📊 CEO DASHBOARD
**最終更新**: 2026年2月9日

---

## 🚦 クイックステータス

| プロジェクト | フェーズ | 状態 |
|---|---|---|
| **Dose Note** | RELEASE | ❌ 審査リジェクト（IAP未提出） |
| **TapKey** | RELEASE | ✅ App Store審査提出済み |
| **会社OS** | OPS | 銀行API連携完了 |

---

## ⚠️ 今すぐ判断・実行すべきこと (Action Required)

### 1. 【判断】本番API利用方針：個人口座での利用可否
- [ ] **判断待ち**
- **課題**: 個人口座でGMOあおぞら銀行APIが使えるか不明。
- **Action**: カスタマーセンター（0120-0180-39）に電話確認。
  - OKなら → 本番申請
  - NGなら → Sunabarで継続開発（推奨） or 開業検討

### 2. 🚨【Dose Note】審査リジェクト対応（Guideline 2.1 - IAP未提出）
- **リジェクト日**: 2026年2月8日
- **原因**: アプリ内課金（サブスクリプション）が審査に提出されていない
- **レビューデバイス**: iPad Air 11-inch (M3) / iPhone 17 Pro Max

**対応手順（CEO作業 - App Store Connect）**:
- [ ] ① サブスクリプション画面を開き、Monthly / Yearly の設定を確認
- [ ] ② 各IAPに **App Reviewスクリーンショット**（Paywall画面）を添付
- [ ] ③ 各IAPのステータスが「送信準備完了」であることを確認
- [ ] ④ 新しいバイナリをアーカイブしてアップロード
- [ ] ⑤ IAPを含めて審査に再提出

> ⚠️ コード変更は不要。App Store Connect上でのIAP提出設定の問題。

### 3. 【TapKey】ストア申請準備
- [x] App Store Connect でアプリ登録
- [x] NSFaceIDUsageDescription追加（TCCクラッシュ修正）✅
- [x] 再アーカイブ・TestFlight動作確認 ✅
- [x] スクリーンショット撮影・アップロード ✅
- [x] メタデータ入力（タイトル・説明文・キーワード）✅
- [x] 審査提出（2026年2月8日）✅

---

## 🚀 進行中のプロジェクト詳細

### 【TapKey】パスワードマネージャー
- **仕様書**: [TapKey/docs/](../TapKey/docs/)
- **進捗**: v1.0 App Store審査提出済み (2026-02-08)
- **サポートページ**: https://debuntu-hub.github.io/tapkey-app/

**次のステップ**:
1. 審査結果待ち
2. 承認後リリース
3. ※ CSVインポート、AutoFillはv2.0へ

---

## 🎉 最近の完了事項 (Archive)

- **2026-02-09**: Dose Note 審査リジェクト（Guideline 2.1: IAP未提出）→ 再提出対応中
- **2026-02-08**: TapKey v1.0 App Store審査提出
- **2026-02-08**: TapKey プライバシーポリシー・サポートページ公開（GitHub Pages）
- **2026-02-08**: TapKey 生体認証デフォルトOFF・ACL動的切替実装
- **2026-02-08**: Dose Note 審査再提出・TapKey App Store Connect登録
- **2026-02-08**: Dose Note 再アーカイブ・TestFlight動作確認完了
- **2026-02-07**: 会社OS Phase 6完了（銀行API連携・MCP実装）
- **2026-02-07**: TapKey UIリデザイン・StoreKit実装完了
- **2026-02-01**: Dose Note 初回審査提出

---

## 💰 キャッシュフロー管理 (FCF)

**📊 今月のFCF**: (集計前)
→ [FCF_REPORT.md](./FCF_REPORT.md)

**月次ルーチン**:
1. App Store Connect売上確認
2. `data/fcf_input.csv` 追記
3. Copilotに「今月のFCFレビュー」を指示

---

## 🧩 経営判断基準 (Metrics)

### 投資基準
- [ ] 3ヶ月連続プラスFCF
- [ ] 平均FCF ≥ 10,000円
- **配分**: 留保50% / 外注30% / 広告20%

### 撤退・停止基準
- [ ] 3ヶ月連続マイナスFCF
- [ ] 施策2回失敗

### Exit (売却) 基準
- [ ] 6ヶ月連続プラスFCF
- [ ] 運用関与 月5時間以下
→ [EXIT_DUE_DILIGENCE.md](./EXIT_DUE_DILIGENCE.md)

---

## 🎯 事業コンパス
*「自分が使うもの、使いたくなるものを開発して他の人にも役に立つ」*

### 今期の焦点
**リリースと収益化の開始**
- Dose Note: IAP提出修正 → 再審査 → 最初の100円
- TapKey: 審査結果待ち → リリース

---

## 📝 参照リンク
- [PRD.md](./PRD.md) / [SRS.md](./SRS.md) / [DECISIONS.md](./DECISIONS.md)
- [FINANCIAL_MANAGEMENT.md](./FINANCIAL_MANAGEMENT.md) (資金管理詳細)
- [MONETIZATION_SPEC.md](./MONETIZATION_SPEC.md) (収益化仕様)
