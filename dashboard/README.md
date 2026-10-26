# AFCON Fan Control Room

This Vite browser dashboard manages the same PostgreSQL records that the Flutter app reads through the AFCON Fan API.

## Run on Windows

Start the API from `backend` first. Then open another PowerShell window and run:

```powershell
cd C:\Users\WIN-PC\Desktop\AFCON\Afcon_app\dashboard
npm.cmd install
npm.cmd run dev
```

Open `http://localhost:5173`. On first visit, register the dashboard owner account. Registration closes after this account is created. On later visits, sign in and open the gear icon to set the backend URL.

- API URL: `http://localhost:8080/api/v1`

The dashboard stores the API URL in local browser storage and keeps the signed-in session token in browser session storage until the tab session ends. The API's `ALLOWED_ORIGINS` must include the dashboard origin (`http://localhost:5173`).

Create competitions and teams before dependent records such as standings, fixtures, players, line-ups and match events. Use the record UUID displayed in each table for foreign key fields. Draft records stay hidden from the app until published. Verify information sources, schedules and media rights before publishing.
