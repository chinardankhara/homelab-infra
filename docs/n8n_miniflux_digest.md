# How to Create a Daily RSS Digest with n8n and Miniflux

This guide walks you through creating an automated workflow in n8n that fetches RSS articles from last 24 hours from your Miniflux instance and emails them to you daily at 8:00 AM.

## Prerequisites
- **Miniflux API Key**: You need to generate one in Miniflux.
- **SMTP Credentials**: You need an email account (like Gmail with an App Password) to send emails from n8n.

---

## Step 1: Generate Miniflux API Key
1. Open Miniflux (`http://SERVER_IP:8081`) and log in.
2. Go to **Settings** -> **API Keys**.
3. Click **Create a new API key**.
4. Description: `n8n automation`.
5. **Copy the API Key** deeply (you won't be able to see it again).

---

## Step 2: Create the n8n Workflow

1. Open n8n (`http://SERVER_IP:5678`) and create a **New Workflow**.

### Node 1: Schedule Trigger
- **Add Node**: Search for **Schedule**.
- **Settings**:
  - **Trigger Interval**: `Days`
  - **Time**: `08:00`
  - **Mode**: `Every Day`

### Node 2: Calculate Timestamp (24 Hours Ago)
We need to tell Miniflux to only give us entries after a certain time.
- **Add Node**: Search for **Date & Time**.
- **Action**: `Format a date`
- **Settings**:
  - **Date**: `{{ $now.minus(1, 'days') }}` (Switch to Expression mode)
  - **To Format**: `X` (Unix Timestamp in seconds)
  - **Property Name**: `timestamp_24h_ago`

### Node 3: Fetch Data from Miniflux
- **Add Node**: Search for **HTTP Request**.
- **Settings**:
  - **Method**: `GET`
  - **URL**: `http://SERVER_IP:8081/v1/entries`
    - *Note: Using the server IP allows n8n to reach Miniflux.*
  - **Authentication**: `Generic Credential Type` -> `Header Auth`
    - Create a new Credential:
      - **Name**: `Miniflux API`
      - **Header Name**: `X-Auth-Token`
      - **Value**: `<PASTE_YOUR_MINIFLUX_API_KEY>`
  - **Query Parameters**:
    - `after`: `{{ $('Date & Time').item.json.timestamp_24h_ago }}` (Drag and drop from previous node)
    - `limit`: `100` (Optional, increase if you read a lot)
    - `direction`: `desc`

### Node 4: Format Email Content
- **Add Node**: Search for **Code**.
- **Language**: `JavaScript`
- **Code**:
  ```javascript
  // Get input items (the articles)
  const items = $input.all();
  
  if (items.length === 0) {
      return [{ json: { html: "No new articles today!" } }];
  }

  let html = "<h1>Daily RSS Digest</h1><ul>";
  
  for (const item of items) {
      const title = item.json.title;
      const url = item.json.url;
      const feed = item.json.feed.title;
      html += `<li><strong>[${feed}]</strong> <a href="${url}">${title}</a></li>`;
  }
  
  html += "</ul>";
  
  return [{ json: { html: html } }];
  ```

### Node 5: Send Email
- **Add Node**: Search for **Email** (or **Gmail** / **SendGrid** depending on your provider).
- **Settings (using Standard Email node)**:
  - **From Email**: `your-email@gmail.com`
  - **To Email**: `your-email@gmail.com`
  - **Subject**: `Daily RSS Digest - {{ $now.toFormat('yyyy-MM-dd') }}`
  - **HTML**: Toggle ON.
  - **Body**: `{{ $('Code').item.json.html }}`
  - **SMTP Credentials**:
    - *Host*: `smtp.gmail.com` (for Gmail)
    - *Port*: `465` (SSL) or `587` (TLS)
    - *User*: Your email
    - *Password*: Your App Password

---

## Step 3: Test and Activate
1. Click **Execute Workflow** to test it (it might fail sending email if credentials aren't set, but check the *Output* of the Code node to see if it generated the HTML list correctly).
2. Once working, toggle **Active** to top right.
