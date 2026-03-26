**中文版** | [English](README.md)

---

# DrawingHealthScore.lsp — DWG 圖面健康診斷工具

**一個指令，掃描整張圖，給你 0–100 分 + 一鍵修復。**

---

## 問題

每次接到外來圖或交圖前，你有辦法快速知道這張圖有多亂嗎？

```
接到協力廠商的圖
→ 圖層亂、Block 沒清、Layer 0 上有東西
→ 圖檔越來越肥、傳輸慢、當機
→ 不知道哪裡有問題、也不知道優先修哪個
→ PURGE 跑一下但也不確定有沒有效
```

AutoCAD 內建的 AUDIT / PURGE 只能單點修復，沒有人做過「整體評分」這一層。你無法回答：「這張圖到底有多健康？」

---

## 解法

輸入 `DHS`，掃描整張圖，彈出診斷視窗：

- **整體分數 0–100**，一眼看出圖面健康狀況
- **8 項逐一評分**，知道哪裡有問題、嚴重程度如何
- **勾選修復項目，按一下 Run Fix Now**，背景自動執行
- **修復後自動重新評分**，顯示節省了多少 MB

![DHS Dialog](docs/DHS.png)

---

## 安裝

1. 下載 `DrawingHealthScore.lsp`
2. 在 AutoCAD 輸入 `APPLOAD`
3. 載入檔案
4. 輸入 `DHS` 執行

**小技巧：** 加入 AutoCAD Startup Suite，每次開啟自動載入。

---

## 使用方式

輸入 `DHS`，診斷視窗自動彈出。

掃描完成後視窗顯示：

- **頂部：** 整體分數與狀態
- **中間：** 8 項診斷結果，含 [GOOD] / [WARN] / [FAIL] 標籤
- **底部：** 修復選項勾選，按 **Run Fix Now** 執行

修復完成後自動重新掃描，顯示前後對比與節省空間。

---

## 指令

| 指令 | 說明 |
|------|------|
| `DHS` | 掃描圖面，開啟診斷視窗 |
| `DHSFIX` | 同 DHS |
| `DHSF` | 同 DHS |

---

## 評分項目（共 8 項，每項 10 分）

| 項目 | 警告門檻 | 扣分門檻 |
|------|---------|---------|
| Unused layers | > 10 個 | > 30 個 |
| Unpurged blocks | > 20 個 | > 50 個 |
| Layer 0 objects | > 總物件 1% | > 總物件 5% |
| Text styles | > 5 種 | > 10 種 |
| Anonymous blocks | > 200 個 | > 500 個 |
| Short layer names | > 10 個 | > 20 個 |
| Xref status | — | 有未解析即扣 |
| File weight | > 3 KB/物件 | > 6 KB/物件 |

---

## 修復功能

| 選項 | 說明 |
|------|------|
| Purge unused BLOCKS | `-PURGE B` 執行 3 次，深度清除巢狀 Block |
| Purge unused LAYERS | `-PURGE LA` 執行 3 次，保留模板圖層時取消勾選 |
| AUDIT | 背景靜默修復圖檔資料庫錯誤 |
| Auto-Save | 存檔前將 `ISAVEPERCENT` 設為 0，強制完整寫入，最大化節省空間 |

**設定會記憶**：每次開啟 Dashboard，上次的勾選狀態會保留。

---

## 相容性

| 版本 | 狀態 |
|------|------|
| AutoCAD 2014+ | ✅ 支援 |
| 2014 以下 | 未測試 |

也適用於 BricsCAD、GstarCAD 等支援 AutoLISP 的 CAD 平台。

---

## 版本紀錄

| 版本 | 說明 |
|------|------|
| v5.1 | 絕對路徑修正確保檔案大小正確讀取、`ISAVEPERCENT=0` 最大化節省空間、PURGE 分 Block / Layer 兩個選項、設定記憶 |
| v4.2 | 單一 Dashboard 視窗整合診斷 + 修復，MB 節省顯示 |
| v3.0 | DCL 動態生成，修復選項獨立 checkbox |
| v1.0 | 命令列輸出版本 |

---

## 支持這個專案

如果 DrawingHealthScore 幫你發現了問題或省下了空間，歡迎請我喝杯咖啡 ☕

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/beastt1992)

---

## 授權

MIT License — 免費使用、修改、散佈。

---

**獻給所有想知道「這張圖到底有多亂」的建築師。**
