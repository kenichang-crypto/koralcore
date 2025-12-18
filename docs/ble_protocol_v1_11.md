# BLE Protocol V1.11 — System / Device Layer (REEF B)

來源：
- REEFB_APP_BLE_通訊協議-指令表_V1.11-251217.pdf

本文件僅整理「機台層（System / Device）」相關 BLE 指令，
不包含 LED / Doser 業務控制與排程。

---

## 1. 裝置基本資訊（Device Info）

### Read Device Info
- 目的：取得裝置基本識別資訊
- 使用時機：Connect 後、Initialize 階段

| 欄位 | 說明 |
|---|---|
| device_name | 裝置名稱 |
| product_id | 產品 ID（用於功能判斷，如 4K） |
| serial_number | SN |
| hw_version | 硬體版本 |

---

## 2. 韌體資訊（Firmware）

### Read Firmware Version
- 目的：取得目前韌體版本
- 使用時機：Initialize 階段

| 欄位 | 說明 |
|---|---|
| firmware_version | 韌體版本字串 |

---

## 3. 能力查詢（Capability）

### Read Capability
- 目的：確認裝置支援哪些功能
- 使用時機：Initialize 階段

說明：
- Capability 為裝置可支援功能的集合
- 不代表使用者設定狀態
- 由 Product ID + Firmware 決定

---

## 4. 時間同步（Time Sync）

### Sync Time
- 目的：同步裝置內部時間
- 使用時機：Initialize 階段

說明：
- App 主動送出目前時間
- 裝置回傳成功 / 失敗

---

## 5. 系統控制（System Control）

### Reboot Device
- 目的：重新啟動裝置
- 使用時機：
  - 韌體更新後
  - 使用者手動觸發

### Reset Device
- 目的：恢復出廠設定
- 使用時機：
  - 使用者主動操作
- 備註：
  - 是否支援依產品而定

---

## 6. 初始化建議順序（Initialize Order）

建議在 Connect 後依序呼叫：

1. Read Device Info
2. Read Firmware Version
3. Read Capability
4. Sync Time
5. Device Ready

---

## 7. 注意事項

- 本文件僅定義「指令用途與時機」
- 實際封包格式與 Byte 定義以原始 PDF 為準
- 所有指令由 Application UseCase 觸發
