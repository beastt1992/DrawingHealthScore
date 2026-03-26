[中文版](README_ZH.md) | **English**

---

# DrawingHealthScore.lsp — DWG Health Diagnostic Tool

**One command. Scan your drawing. Get a score out of 100 — and fix it in one click.**

---

## The Problem

When you receive a drawing from a consultant, or before you submit your own — do you actually know how clean it is?

```
Receive drawing from contractor
→ Messy layers, unpurged blocks, objects on Layer 0
→ File keeps getting larger, slower, unstable
→ No idea what's wrong or what to fix first
→ Run PURGE once but not sure if it did anything
```

AutoCAD's built-in AUDIT and PURGE are single-point fixes. Nobody has ever put a score on the whole thing. You can't answer the question: *how healthy is this drawing?*

---

## The Solution

Type `DHS`. A diagnostic dashboard pops up:

- **Overall score 0–100** — know the health of a drawing instantly
- **8 individual checks** — see exactly what's wrong and how bad it is
- **Check the fixes you want, click Run Fix Now** — runs silently in the background
- **Auto re-scans after fixing** — shows how many MB were saved

```
>> Scanning drawing data... Done.

┌─────────────────────────────────────┐
│  OVERALL SCORE: 64 / 100            │
│  Status: FAIR (Needs attention)     │
├─────────────────────────────────────┤
│  [GOOD] Unused layers: 3            │
│  [FAIL] Unpurged blocks: 28         │
│  [WARN] Layer 0 objects: 34         │
│  [GOOD] Text styles: 2 used         │
│  [GOOD] Anonymous blocks: 12        │
│  [WARN] Short layer names: 4        │
│  [GOOD] Xref issues: None           │
│  [WARN] File weight: 18.4 MB        │
├─────────────────────────────────────┤
│  Auto-Fix Settings                  │
│  ☑ Deep PURGE                       │
│  ☑ AUDIT                            │
│  ☑ Auto-Save                        │
│  [ Run Fix Now ]  [ Close ]         │
└─────────────────────────────────────┘

>> Space Saved: 6.2 MB !!
>> OVERALL SCORE: 81 / 100  (was 64)
```

---

## Installation

1. Download `DrawingHealthScore.lsp`
2. In AutoCAD, type `APPLOAD`
3. Load the file
4. Type `DHS` to run

**Tip:** Add it to AutoCAD's Startup Suite for automatic loading every session.

---

## How to Use

Type `DHS`. The dashboard opens automatically after scanning.

The window shows:

- **Top:** Overall score and status
- **Middle:** 8 diagnostic results with [GOOD] / [WARN] / [FAIL] labels
- **Bottom:** Fix options with checkboxes — click **Run Fix Now** to execute

After fixing, the tool re-scans automatically and shows before/after comparison.

---

## Commands

| Command | Description |
|---------|-------------|
| `DHS` | Scan drawing and open dashboard |
| `DHSFIX` | Same as DHS |
| `DHSF` | Same as DHS |

---

## Score Breakdown (8 checks, 10 points each)

| Check | Penalty Threshold |
|-------|-------------------|
| Unused layers | Deduct after 5 |
| Unpurged blocks | Deduct after 5 |
| Layer 0 objects | Deduct after 10 |
| Text styles | Deduct after 3 styles |
| Anonymous blocks | Deduct after 20 |
| Short layer names | Deduct after 3 |
| Xref status | Any unresolved xref = deduction |
| File weight | Based on KB-per-object ratio |

---

## Fix Options

| Option | Details |
|--------|---------|
| Deep PURGE | Runs `vla-purgeall` 3 times — more thorough than the PURGE command |
| AUDIT | Fixes drawing database errors silently in background |
| Auto-Save | Saves after fixing so MB saved can be calculated |

---

## Compatibility

| AutoCAD Version | Status |
|----------------|--------|
| 2014 and above | ✅ Supported |
| Below 2014 | Not tested |

Also works with BricsCAD, GstarCAD, and other AutoLISP-compatible CAD platforms.

---

## Version History

| Version | Notes |
|---------|-------|
| v4.2 | Unified dashboard — diagnostics + fix options in one window, MB savings display |
| v3.0 | Dynamic DCL generation, independent fix checkboxes |
| v1.0 | Command-line output version |

---

## Support This Project

If DrawingHealthScore helped you catch a problem or trim down a bloated file, consider buying me a coffee ☕

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/beastt1992)

---

## License

MIT License — Free to use, modify, and distribute.

---

**Made for architects who want to know: how healthy is this drawing?**
