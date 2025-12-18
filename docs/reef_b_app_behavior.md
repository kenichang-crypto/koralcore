# REEF B App — Device Lifecycle Behavior

本文件描述 reef-b-app 中實際存在的「機台層行為」，
作為 koralCore Device / System UseCase 的依據。

---

## 1. Scan Devices

- App 啟動或進入裝置頁
- 開始 BLE Scan
- 顯示：
  - Device Name
  - RSSI
- 尚未建立連線

---

## 2. Add Device

- 使用者點選掃描到的裝置
- App 將裝置加入本地清單
- 尚未初始化裝置內容

---

## 3. Connect Device

- App 主動建立 BLE 連線
- UI 顯示 Connecting
- 成功後進入 Initialize 階段

---

## 4. Initialize Device（關鍵階段）

連線成功後，App 依序執行：

1. Read Device Info
2. Read Firmware Version
3. Read Product ID
4. Read Capability
5. Sync Time

初始化完成後：
- 裝置狀態切換為 Ready
- 依 Capability 開放功能頁面

---

## 5. Device Ready

- 裝置已可操作
- LED / Doser 頁面才會開放
- Capability 為判斷依據

---

## 6. Disconnect / Reconnect

- BLE 斷線：
  - UI 顯示 Disconnected
- App 可嘗試自動重連
- 重連成功後：
  - 不一定重跑完整 Initialize
  - 視情況重新 Sync

---

## 7. Switch Current Device

- 使用者切換操作中的裝置
- App 切換 currentDevice
- UI 重新載入對應資料

---

## 8. Remove Device

- 使用者刪除裝置
- App 清除本地記錄
- BLE 連線關閉
