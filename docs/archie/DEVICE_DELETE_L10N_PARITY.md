# 設備刪除功能多語言對照表

## 確認狀態

### ✅ 已確認對照的字串（英文和繁體中文）

| koralcore ARB Key | reef-b-app strings.xml Key | 英文 | 繁體中文 | 狀態 |
|------------------|---------------------------|------|---------|------|
| `deviceDeleteConfirmMessage` | `dialog_device_delete` | "Delete the selected device?" | "是否刪除所選設備?" | ✅ |
| `deviceDeleteConfirmPrimary` | `dialog_device_delete_led_positive` → `@string/delete` | "Delete" | "刪除" | ✅ |
| `deviceDeleteConfirmSecondary` | `dialog_device_delete_led_negative` → `@string/cancel` | "Cancel" | "取消" | ✅ |
| `deviceDeleteLedMasterTitle` | `dialog_device_delete_led_master_title` → `@string/master_setting` | "Master-Slave Settings" | "主從設定" | ✅ |
| `deviceDeleteLedMasterContent` | `dialog_device_delete_led_master_content` | "To delete the master light, please modify the master-slave settings and set other slave lights as master." | "欲刪除主燈，請先修改主從設定，將其他副燈設定為主燈" | ✅ |
| `deviceDeleteLedMasterPositive` | `dialog_device_delete_led_master_positive` → `@string/i_konw` | "I understood" | "我瞭解了" | ✅ |
| `toastDeleteDeviceSuccessful` | `toast_delete_device_successful` | "Successfully deleted device." | "刪除設備成功" | ✅ |
| `toastDeleteDeviceFailed` | `toast_delete_device_failed` | "Failed to delete device." | "刪除設備失敗" | ✅ |

### ⚠️ 需要更新的語言

以下語言的ARB文件需要添加缺失的字串，從reef-b-app對應的strings.xml中提取：

1. **阿拉伯語 (ar)**
2. **德語 (de)**
3. **西班牙語 (es)**
4. **法語 (fr)**
5. **印尼語 (id)**
6. **日語 (ja)**
7. **韓語 (ko)**
8. **葡萄牙語 (pt)**
9. **俄語 (ru)**
10. **泰語 (th)**
11. **越南語 (vi)**

## 翻譯對照表

### 阿拉伯語 (ar)
- `deviceDeleteConfirmMessage`: "هل ترغب في حذف الجهاز المحدد؟"
- `deviceDeleteConfirmPrimary`: "حذف" (from `@string/delete`)
- `deviceDeleteConfirmSecondary`: "إلغاء" (from `@string/cancel`)
- `deviceDeleteLedMasterTitle`: "إعدادات الماستر والسليف" (from `@string/master_setting`)
- `deviceDeleteLedMasterContent`: "لحذف الضوء الرئيسي، يرجى تعديل إعدادات الماستر-الرقيق وتعيين الأضواء الأخرى كأضواء رقيقة."
- `deviceDeleteLedMasterPositive`: "فهمت" (from `@string/i_konw`)
- `toastDeleteDeviceSuccessful`: "تم حذف الجهاز بنجاح."
- `toastDeleteDeviceFailed`: "فشل في حذف الجهاز."

### 德語 (de)
- `deviceDeleteConfirmMessage`: "Das ausgewählte Gerät löschen?"
- `deviceDeleteConfirmPrimary`: "Löschen" (from `@string/delete`)
- `deviceDeleteConfirmSecondary`: "Abbrechen" (from `@string/cancel`)
- `deviceDeleteLedMasterTitle`: "Master-Slave-Einstellungen" (from `@string/master_setting`)
- `deviceDeleteLedMasterContent`: "Um das Master-Licht zu löschen, ändern Sie bitte die Master-Slave-Einstellungen und setzen Sie andere Slave-Lichter als Master."
- `deviceDeleteLedMasterPositive`: "Ich habe verstanden" (from `@string/i_konw`)
- `toastDeleteDeviceSuccessful`: "Gerät erfolgreich gelöscht."
- `toastDeleteDeviceFailed`: "Löschen des Geräts fehlgeschlagen."

### 西班牙語 (es)
- `deviceDeleteConfirmMessage`: "¿Eliminar el dispositivo seleccionado?"
- `deviceDeleteConfirmPrimary`: "Eliminar" (from `@string/delete`)
- `deviceDeleteConfirmSecondary`: "Cancelar" (from `@string/cancel`)
- `deviceDeleteLedMasterTitle`: "Configuraciones Maestro-Esclavo" (from `@string/master_setting`)
- `deviceDeleteLedMasterContent`: "Para eliminar la luz maestra, modifica primero los ajustes de maestro-esclavo y establece otras luces esclavas como maestras."
- `deviceDeleteLedMasterPositive`: "Entendido" (from `@string/i_konw`)
- `toastDeleteDeviceSuccessful`: "Dispositivo eliminado exitosamente."
- `toastDeleteDeviceFailed`: "Error al eliminar el dispositivo."

### 法語 (fr)
- `deviceDeleteConfirmMessage`: "Supprimer l'appareil sélectionné ?"
- `deviceDeleteConfirmPrimary`: "Supprimer" (from `@string/delete`)
- `deviceDeleteConfirmSecondary`: "Annuler" (from `@string/cancel`)
- `deviceDeleteLedMasterTitle`: "Réglages maître-esclave" (from `@string/master_setting`)
- `deviceDeleteLedMasterContent`: "Pour supprimer la lumière principale, veuillez modifier les paramètres maître-esclave et définir d'autres lumières esclaves comme maître."
- `deviceDeleteLedMasterPositive`: "J'ai compris" (from `@string/i_konw`)
- `toastDeleteDeviceSuccessful`: "Échec de la suppression de l'appareil." (注意：reef-b-app中這個字串的successful和failed是反的)
- `toastDeleteDeviceFailed`: "Suppression de l'appareil réussie." (注意：reef-b-app中這個字串的successful和failed是反的)

### 印尼語 (id)
- `deviceDeleteConfirmMessage`: "Hapus perangkat yang dipilih?"
- `deviceDeleteConfirmPrimary`: "Hapus" (from `@string/delete`)
- `deviceDeleteConfirmSecondary`: "Batal" (from `@string/cancel`)
- `deviceDeleteLedMasterTitle`: "Pengaturan Master-Slave" (from `@string/master_setting`)
- `deviceDeleteLedMasterContent`: "Untuk menghapus lampu master, silakan modifikasi pengaturan master-slave dan tetapkan lampu budak lain sebagai lampu master."
- `deviceDeleteLedMasterPositive`: "Saya mengerti" (from `@string/i_konw`)
- `toastDeleteDeviceSuccessful`: "Berhasil menghapus perangkat."
- `toastDeleteDeviceFailed`: "Gagal menghapus perangkat."

### 日語 (ja)
- `deviceDeleteConfirmMessage`: "選択したデバイスを削除しますか？"
- `deviceDeleteConfirmPrimary`: "削除" (from `@string/delete`)
- `deviceDeleteConfirmSecondary`: "キャンセル" (from `@string/cancel`)
- `deviceDeleteLedMasterTitle`: "マスタースレーブ設定" (from `@string/master_setting`)
- `deviceDeleteLedMasterContent`: "マスターライトを削除するには、まずマスター/スレーブ設定を変更し、他のスレーブライトをマスターに設定してください。"
- `deviceDeleteLedMasterPositive`: "了解しました" (from `@string/i_konw`)
- `toastDeleteDeviceSuccessful`: "デバイスが正常に削除されました。"
- `toastDeleteDeviceFailed`: "デバイスの削除に失敗しました。"

### 韓語 (ko)
- `deviceDeleteConfirmMessage`: "선택한 장치를 삭제하시겠습니까?"
- `deviceDeleteConfirmPrimary`: "삭제" (from `@string/delete`)
- `deviceDeleteConfirmSecondary`: "취소" (from `@string/cancel`)
- `deviceDeleteLedMasterTitle`: "마스터-슬레이브 설정" (from `@string/master_setting`)
- `deviceDeleteLedMasterContent`: "마스터 라이트를 삭제하려면 먼저 마스터-슬레이브 설정을 수정하고 다른 슬레이브 라이트를 마스터로 설정하십시오."
- `deviceDeleteLedMasterPositive`: "이해했습니다" (from `@string/i_konw`)
- `toastDeleteDeviceSuccessful`: "장치가 성공적으로 삭제되었습니다."
- `toastDeleteDeviceFailed`: "장치 삭제에 실패했습니다."

### 葡萄牙語 (pt)
- `deviceDeleteConfirmMessage`: "Excluir o dispositivo selecionado?"
- `deviceDeleteConfirmPrimary`: "Excluir" (from `@string/delete`)
- `deviceDeleteConfirmSecondary`: "Cancelar" (from `@string/cancel`)
- `deviceDeleteLedMasterTitle`: "Configurações Mestre-Escravo" (from `@string/master_setting`)
- `deviceDeleteLedMasterContent`: "Para excluir a luz principal, modifique as configurações mestre-escravo e defina outras luzes escravas como luz mestra."
- `deviceDeleteLedMasterPositive`: "Entendi" (from `@string/i_konw`)
- `toastDeleteDeviceSuccessful`: "Dispositivo excluído com sucesso."
- `toastDeleteDeviceFailed`: "Falha ao excluir o dispositivo."

### 俄語 (ru)
- `deviceDeleteConfirmMessage`: "Удалить выбранное устройство?"
- `deviceDeleteConfirmPrimary`: "Удалить" (from `@string/delete`)
- `deviceDeleteConfirmSecondary`: "Отмена" (from `@string/cancel`)
- `deviceDeleteLedMasterTitle`: "Настройки Мастер-Слейв" (from `@string/master_setting`)
- `deviceDeleteLedMasterContent`: "Для удаления мастер-света, измените настройки мастер-слейв и установите другие слейвы как мастер."
- `deviceDeleteLedMasterPositive`: "Понял" (from `@string/i_konw`)
- `toastDeleteDeviceSuccessful`: "Устройство успешно удалено."
- `toastDeleteDeviceFailed`: "Не удалось удалить устройство."

### 泰語 (th)
- `deviceDeleteConfirmMessage`: "ลบอุปกรณ์ที่เลือกหรือไม่?"
- `deviceDeleteConfirmPrimary`: "ลบ" (from `@string/delete`)
- `deviceDeleteConfirmSecondary`: "ยกเลิก" (from `@string/cancel`)
- `deviceDeleteLedMasterTitle`: "การตั้งค่าเป็นท่านายและทาส" (from `@string/master_setting`)
- `deviceDeleteLedMasterContent`: "ในการลบแสงหลัก โปรดแก้ไขการตั้งค่าตัวคู่หน้าลำโพงและตั้งแสงที่เคยเป็นที่อื่นเป็นแสงหลัก"
- `deviceDeleteLedMasterPositive`: "ฉันเข้าใจแล้ว" (from `@string/i_konw`)
- `toastDeleteDeviceSuccessful`: "ลบอุปกรณ์เรียบร้อยแล้ว"
- `toastDeleteDeviceFailed`: "ไม่สามารถลบอุปกรณ์ได้"

### 越南語 (vi)
- `deviceDeleteConfirmMessage`: "Xóa thiết bị đã chọn?"
- `deviceDeleteConfirmPrimary`: "Xóa" (from `@string/delete`)
- `deviceDeleteConfirmSecondary`: "Hủy" (from `@string/cancel`)
- `deviceDeleteLedMasterTitle`: "Cài đặt Master-Slave" (from `@string/master_setting`)
- `deviceDeleteLedMasterContent`: "Để xóa đèn chính, vui lòng sửa đổi cài đặt master-slave và đặt các đèn nô lệ khác làm đèn chính."
- `deviceDeleteLedMasterPositive`: "Tôi đã hiểu" (from `@string/i_konw`)
- `toastDeleteDeviceSuccessful`: "Xóa thiết bị thành công."
- `toastDeleteDeviceFailed`: "Không thể xóa thiết bị."

## 注意事項

1. **法語 (fr) 的特殊情況**：reef-b-app的`toast_delete_device_successful`和`toast_delete_device_failed`的內容是反的，需要對照實際的reef-b-app值。
2. **所有翻譯都必須從reef-b-app的strings.xml中提取**，不能自行生成。
3. **引用字串**：`@string/delete`、`@string/cancel`、`@string/master_setting`、`@string/i_konw`需要從對應語言的strings.xml中查找實際值。

