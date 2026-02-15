# 🎯 EA - Expert Advisor MetaTrader 5

[![MQL5](https://img.shields.io/badge/MQL5-Expert_Advisor-blue.svg)](https://www.mql5.com)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-orange.svg)](https://github.com/hafisc/profit-hunter-MT5)

Expert Advisor **modular, robust, dan production-ready** untuk MetaTrader 5 yang dibangun dengan prinsip pemrograman berorientasi objek. ProfitHunter EA mengimplementasikan strategi trend-following yang terbukti menggunakan indikator EMA dan RSI dengan manajemen risiko cerdas dan trailing stop dinamis.

## ✨ Fitur Unggulan

- 🏗️ **Arsitektur Modular** - Pemisahan fungsi yang jelas dengan kelas-kelas terpisah
- 💰 **Manajemen Uang Cerdas** - Perhitungan lot otomatis berdasarkan saldo akun
- 📊 **Strategi EMA + RSI** - Kombinasi filter trend dan konfirmasi momentum
- 🛡️ **Proteksi Risiko** - Maksimal 1 posisi aktif dengan filter spread
- 🔄 **Trailing Stop Dinamis** - Proteksi breakeven + trailing profit otomatis
- 🎯 **Siap Produksi** - Error handling komprehensif dan logging lengkap
- ⚙️ **Highly Configurable** - Parameter dapat disesuaikan melalui input setting

## 📋 Ringkasan Strategi

### Logika Trading

| Komponen | Konfigurasi |
|----------|-------------|
| **Timeframe** | H1 (1 Jam) |
| **Filter Trend** | EMA 200 |
| **Trigger Entry** | RSI 14 crossover di level 50 |
| **Spread Maksimal** | 50 poin |

### Kondisi Entry

**📈 Sinyal BELI (BUY):**
- Harga di atas EMA 200 (tren naik)
- RSI menembus di atas 50 (pemulihan pullback)
- Spread ≤ 50 poin

**📉 Sinyal JUAL (SELL):**
- Harga di bawah EMA 200 (tren turun)
- RSI menembus di bawah 50 (pembalikan momentum)
- Spread ≤ 50 poin

### Manajemen Risiko & Trading

- **Risiko per Trade:** 2% dari saldo akun (default, dapat dikonfigurasi)
- **Stop Loss Awal:** 200 poin (dapat dikonfigurasi)
- **Take Profit:** 400 poin (dapat dikonfigurasi)
- **Trailing Stop:**
  - Aktif ketika profit ≥ 200 poin
  - Memindahkan SL ke breakeven terlebih dahulu
  - Kemudian trailing harga dengan jarak 100 poin

## 🚀 Instalasi

### Metode 1: Download Langsung

1. **Clone atau download repository ini:**
   ```bash
   git clone https://github.com/hafisc/profit-hunter-MT5.git
   ```

2. **Copy file ke folder Data MT5:**
   - Buka MetaTrader 5
   - Klik `File` → `Open Data Folder`
   - Copy file ke direktori masing-masing:
     ```
     📁 MQL5/
     ├── 📁 Include/ProfitHunter/
     │   ├── Defines.mqh
     │   ├── RiskManager.mqh
     │   ├── SignalEngine.mqh
     │   └── TradeManager.mqh
     └── 📁 Experts/
         └── ProfitHunter_EA.mq5
     ```

3. **Compile EA:**
   - Buka MetaEditor (tekan F4 di MT5)
   - Navigasi ke `Experts/ProfitHunter_EA.mq5`
   - Tekan `F7` untuk compile
   - Pastikan tidak ada error di log

### Metode 2: Clone Langsung ke Folder MQL5

Navigasi ke folder MQL5 MT5 Anda dan clone langsung:
```bash
cd "C:\Users\NamaUser\AppData\Roaming\MetaQuotes\Terminal\ID_MT5_ANDA\MQL5"
git clone https://github.com/hafisc/profit-hunter-MT5.git temp
xcopy temp\Include Include\ /E /I /Y
xcopy temp\Experts Experts\ /E /I /Y
rmdir /S /Q temp
```

## ⚙️ Konfigurasi

### Parameter Input

| Parameter | Default | Deskripsi |
|-----------|---------|-----------|
| **Manajemen Risiko** |
| `InpRiskPercent` | 2.0 | Risiko per trade (% dari saldo) |
| **Parameter Strategi** |
| `InpEMAPeriod` | 200 | Periode EMA untuk filter trend |
| `InpRSIPeriod` | 14 | Periode RSI untuk sinyal entry |
| `InpRSILevel` | 50.0 | Level crossover RSI |
| **Pengaturan Trading** |
| `InpMagicNumber` | 123456 | Nomor identifikasi unik EA |
| `InpTradeComment` | "ProfitHunter" | Komentar untuk trade |
| `InpSlippage` | 10 | Slippage yang diizinkan (poin) |
| **Stop Loss & Take Profit** |
| `InpStopLoss` | 200 | Stop loss awal (poin) |
| `InpTakeProfit` | 400 | Take profit (poin) |

## 📖 Cara Penggunaan

1. **Pasang EA ke Chart:**
   - Buka chart H1 untuk simbol yang diinginkan (contoh: EURUSD)
   - Navigasi ke `Navigator` → `Expert Advisors`
   - Drag `ProfitHunter_EA` ke chart

2. **Atur Konfigurasi:**
   - Sesuaikan parameter input di dialog pengaturan EA
   - Mulai dengan setting default untuk testing awal
   - Pertimbangkan menurunkan risiko ke 1% untuk trading konservatif

3. **Aktifkan Auto Trading:**
   - Klik tombol "Auto Trading" di toolbar MT5 (atau tekan F7)
   - Pastikan ikon smiley face EA aktif di chart
   - Cek tab Expert di Terminal untuk pesan EA

4. **Monitor Performa:**
   - Review trade di Account History
   - Monitor log EA di tab Expert
   - Sesuaikan parameter berdasarkan hasil backtest

## 📁 Struktur Project

```
MQL5/
├── Include/ProfitHunter/
│   ├── Defines.mqh          # Enums, konstanta, konfigurasi
│   ├── RiskManager.mqh      # Perhitungan lot & manajemen uang
│   ├── SignalEngine.mqh     # Logika strategi EMA + RSI
│   └── TradeManager.mqh     # Eksekusi trade & trailing stop
└── Experts/
    └── ProfitHunter_EA.mq5  # File utama EA
```

### Deskripsi File

- **`Defines.mqh`** - Konfigurasi sentral dengan enums dan konstanta
- **`RiskManager.mqh`** - Menghitung ukuran lot berdasarkan persentase risiko dan saldo akun
- **`SignalEngine.mqh`** - Menghasilkan sinyal BUY/SELL menggunakan indikator EMA dan RSI
- **`TradeManager.mqh`** - Menangani eksekusi order dan manajemen trailing stop dinamis
- **`ProfitHunter_EA.mq5`** - File utama yang mengorkestrasi semua komponen

## 🔧 Kustomisasi

Desain modular memudahkan kustomisasi:

### Ubah Strategi
Edit `SignalEngine.mqh` untuk mengimplementasikan indikator atau logika berbeda:
```cpp
// Contoh: Tambahkan konfirmasi MACD
int m_macdHandle;
// ... implementasi logika MACD
```

### Modifikasi Aturan Risiko
Edit `RiskManager.mqh` untuk mengimplementasikan perhitungan posisi alternatif:
```cpp
// Contoh: Implementasi Kelly Criterion
double GetKellyLotSize(double winRate, double avgWin, double avgLoss)
{
    // ... implementasi formula Kelly
}
```

### Tambahkan Filter
Edit `SignalEngine.mqh` untuk menambahkan filter waktu atau volatilitas:
```cpp
// Contoh: Tambahkan filter jam trading
bool CheckTradingHours()
{
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    return (dt.hour >= 8 && dt.hour <= 16); // Trading jam 8 pagi - 4 sore saja
}
```

## 📊 Backtesting

Sebelum trading live, selalu lakukan backtest:

1. **Buka Strategy Tester** (Ctrl+R)
2. Pilih `ProfitHunter_EA`
3. Pilih simbol (contoh: EURUSD)
4. Set timeframe ke **H1**
5. Pilih rentang tanggal (minimal 1 tahun)
6. Gunakan mode "Every tick based on real ticks"
7. Klik **Start**

### Tips Optimasi

- Test berbagai periode EMA (150-250)
- Optimasi periode RSI (10-20)
- Sesuaikan rasio SL/TP (1:1.5 sampai 1:3)
- Test pada berbagai simbol

## ⚠️ Disclaimer

> **PENTING:** Trading valuta asing dengan margin membawa tingkat risiko yang tinggi dan mungkin tidak cocok untuk semua investor. Kinerja masa lalu tidak menjamin hasil di masa depan. Tingkat leverage yang tinggi dapat merugikan Anda.
>
> EA ini disediakan untuk tujuan edukasi. Selalu:
> - Test secara menyeluruh di akun demo terlebih dahulu
> - Gunakan manajemen risiko yang tepat (maksimal 1-2% per trade)
> - Jangan trading dengan uang yang tidak mampu Anda rugikan
> - Pahami strategi sebelum menggunakannya

## 🤝 Kontribusi

Kontribusi sangat diterima! Silakan:

- 🐛 Laporkan bug melalui [Issues](https://github.com/hafisc/profit-hunter-MT5/issues)
- 💡 Usulkan fitur baru
- 🔧 Kirim pull request
- ⭐ Beri bintang jika repository ini bermanfaat!

## 📝 Lisensi

Project ini dilisensikan di bawah MIT License - lihat file [LICENSE](LICENSE) untuk detail.

## 📧 Kontak

- **GitHub:** [@hafisc](https://github.com/hafisc)
- **Issues:** [GitHub Issues](https://github.com/hafisc/profit-hunter-MT5/issues)

## 🙏 Acknowledgments

- Dibangun dengan MQL5 Standard Library
- Terinspirasi dari strategi trading profesional
- Dikembangkan dengan best practices object-oriented programming

---

### 📈 Selamat Trading! 🚀

*Ingat: Trade terbaik adalah yang tidak Anda ambil jika kondisinya tidak sempurna.*

**Versi 1.0.0** | Terakhir Diperbarui: Februari 2026
