# How to Import Data into Ghostfolio

Ghostfolio generally does not support "live" API connections (like Plaid) for security and privacy reasons. Instead, you import data via **CSV files**.

## 1. Fidelity Import
1.  **Login** to Fidelity.com.
2.  Go to **Accounts & Trade** -> **Portfolio**.
3.  Click on the **Activity & Orders** tab.
4.  Select your timeframe (e.g., "History" or "Past 2 years").
5.  Click the **Download** (arrow icon) on the top right of the table to get a `.csv` file.

## 2. Coinbase Import
1.  **Login** to Coinbase.
2.  Go to **Activity** or **Reports**.
3.  Generate a **Transaction History** report (CSV).
4.  Download the file.

## 3. Importing into Ghostfolio
Ghostfolio has a "Generic" importer that is very powerful. If the automatic "Fidelity" or "Coinbase" preset doesn't work perfectly, use the **Generic** one.

1.  Open Ghostfolio (`http://SERVER_IP:3333`).
2.  Go to **Portfolios** -> **Activities** -> **Import**.
3.  Upload your CSV file.
4.  **Map the Columns**: Ghostfolio will ask you to match your CSV columns to its internal fields. Use this guide:

| Ghostfolio Field | Fidelity Column | Coinbase Column |
| :--- | :--- | :--- |
| **Date** | `Run Date` (or `Date`) | `Timestamp` |
| **Type** | `Action` | `Transaction Type` |
| **Symbol** | `Symbol` | `Asset` |
| **Quantity** | `Quantity` | `Quantity Transacted` |
| **Unit Price** | `Price` | `Spot Price at Transaction` |
| **Fee** | `Commission/Fees` | `Fees` |
| **Currency** | (Usually USD) | `Spot Price Currency` |

### Important Tips
*   **Symbol Mapping**: Fidelity might list a stock as `AAPL`, but Ghostfolio uses Yahoo Finance data, so it usually needs specific symbols if they are obscure. For standard US stocks, `AAPL` works fine.
*   **Cash**: Ghostfolio ignores "Cash" transactions unless you track cash as a separate asset. It focuses on the Buy/Sell of assets.
*   **Transaction Types**: You might need to map "Reinvestment" to "Buy" and "Div" to "Dividend" during the import wizard.
