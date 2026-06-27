# Derek's Diary App — Handoff Documentation (v5.2)

**For continuation in new Claude chat**

---

## PROJECT OVERVIEW

**Application Name:** Derek's Diary App (Derek Notepad)

**Purpose:** Family communication and care coordination platform. Enables family members and care home staff to post updates, notes, and observations in a shared, real-time diary. Named after Derek (a family care case).

**Users:** Family members + care home staff (named participants)

**Current Status:** Stable v5.2 production (Firebase-backed)

**Deployment:** Firebase Hosting + Netlify (live)

**Last Verified:** v5.2 stable with configurable alert keywords admin panel fully tested

---

## TECH STACK

### Frontend

- **Language:** HTML5 + Vanilla JavaScript (ES6+)
- **Styling:** CSS3 (inline or embedded)
- **Architecture:** Three-file modular design sharing one Firebase database
- **State Management:** Real-time Firebase Realtime Database listeners
- **No build step required** — direct browser execution

### Backend

- **Database:** Firebase Realtime Database (JSON structure, Europe-West region)
- **Hosting:** Firebase Hosting + Netlify (both active)
- **Authentication:** No Firebase Authentication; client-side name selection only
- **Real-time Sync:** Firebase Realtime Database listeners with `.on('value')` and `.on('child_added')`

### Deployment Pipeline

- **Primary:** Netlify (drag-to-deploy HTML files to web interface)
- **Secondary:** Firebase CLI (`firebase deploy`) for testing/backup
- **Version Control:** Local file backups with rollback copies

---

## FILES & ARCHITECTURE

### Three-File System (v5.2 Stable)

All three files share the **same Firebase Realtime Database** and must be kept in sync.

#### 1. **index.html** (Main entry point — Family Diary)

- **Size:** ~498 KB
- **Purpose:** Primary diary view for family members (Matthew, Rebecca, Katharine, Jemima, Harry, Oscar)
- **Key Features:**
  - Post creation form (author dropdown/memory, timestamp, message text)
  - Real-time entry list with author filtering
  - **NEW:** Configurable name/keyword highlighting (admin-controlled)
  - Timestamp formatting (created, modified)
  - Admin access behind PIN 1234 (cog icon)
  - **NEW v5.2:** Alert Keywords Manager in admin panel
  - Author name persisted in browser localStorage
- **Firebase Listeners:** 
  - `messages` — all entries on load + listens to new child additions
  - `config/alertKeywords` — syncs alert keywords globally
- **Special Functions:** 
  - Admin panel for keywords management
  - Pin-based access control

#### 2. **kingsland.html** (Care facility view)

- **Size:** ~227 KB
- **Purpose:** Alternative dashboard for care home staff (Keira, Colleagues)
- **Key Features:**
  - Same diary data (same Firebase database as index.html)
  - Optimized UI/UX for care facility staff workflows
  - **UPDATED v5.2:** Dynamic keyword highlighting (synced from Firebase)
  - Quick-access buttons for common update types
  - Real-time sync with family diary entries
- **Firebase Listeners:** 
  - `messages` — identical to index.html
  - `config/alertKeywords` — reads keywords from global config
- **Differences from index.html:** Layout and button grouping only; data and keywords are identical

#### 3. **alerts.html** (Alerts & Summary Dashboard)

- **Size:** ~208 KB
- **Purpose:** Alert/summary dashboard for Derek and read-only stakeholders
- **Key Features:**
  - Filtered view for entries containing configurable keyword triggers
  - Green-highlighted entries matching alert keywords
  - Timestamp and author metadata for each entry
  - **UPDATED v5.2:** Dynamic keywords (no longer hardcoded)
  - ✓ **Toggle for undated entries** (v5.1 feature) — admin-controlled
  - Full-screen alert notifications for today/tomorrow events
- **Firebase Listeners:** 
  - `messages` — fetches entries for filtering
  - `config/alertKeywords` — loads keywords for highlighting
- **Access Control:** Read-only (Derek and other read-only users)

### Default Keywords (v5.2)

```
Matthew, Rebecca, Katharine, Jemima, Oscar, Harry, Phil, Angelina, Plot 22
```

These are now stored in Firebase at `config/alertKeywords` and can be customized via the admin panel in index.html.

---

## RECENT UPDATES (v5.2)

### ✅ Configurable Alert Keywords Admin Panel

**What Changed:**
- Hardcoded keywords array replaced with dynamic Firebase-backed system
- New admin interface in index.html settings cog (behind PIN 1234)
- Users can add/remove keywords that trigger green highlighting
- Keywords synced globally across all three files in real-time

**How to Use:**
1. Click ⚙ settings cog (index.html only)
2. Enter PIN: **1234**
3. Click "🎨 Alert Keywords"
4. View current keywords
5. Add new keyword with text input
6. Delete keywords with delete button
7. Click "💾 Save" to persist to Firebase

**Firebase Changes:**
- New config node: `config/alertKeywords` (array of strings)
- Security rules updated to allow read/write on `config` node
- Real-time listeners load keywords on app startup and react to changes

**Files Modified:**
- index.html: Admin UI, keyword manager functions, Firebase listener
- kingsland.html: Keywords listener, updated highlightNames()
- alerts.html: Keywords listener, updated highlightNames()

**Bug Fixes in v5.2:**
- Line break bug in alerts.html fixed (removed double `esc()` call)
- Modal not opening fixed (updated openModal() to reference correct elements)
- Keywords save now has proper error handling and confirmation

---

## FIREBASE CONFIGURATION

### Firebase Project Details

- **Project Name:** `m-r-d-notepad`
- **Region:** Europe-West 1
- **Database URL:** `https://m-r-d-notepad-default-rtdb.europe-west1.firebasedatabase.app`

### Database Structure (JSON)

```json
{
  "messages": {
    "[ENTRY-ID]": {
      "author": "Name of poster",
      "timestamp": 1718920800000,
      "message": "Entry text",
      "modified": 1718921000000
    }
  },
  "deleted": {
    "[DELETED-ENTRY-ID]": {
      "timestamp": 1718920800000
    }
  },
  "expired": {
    "[EXPIRED-ENTRY-ID]": {
      "timestamp": 1718920800000
    }
  },
  "config": {
    "alertKeywords": ["Matthew", "Rebecca", "Katharine", "Jemima", "Oscar", "Harry", "Phil", "Angelina", "Plot 22"]
  }
}
```

**Node explanation:**
- **messages:** Active entries (displayed to all users)
- **deleted:** Soft-deleted entries (hidden from UI but data retained)
- **expired:** Entries marked as archived/expired (for filtering in alerts.html)
- **config:** Configuration data (NEW in v5.2)
  - **alertKeywords:** Array of words/phrases that trigger green highlighting

### Firebase Security Rules (UPDATED v5.2)

```json
{
  "rules": {
    "messages": {
      ".read": true,
      ".write": true
    },
    "deleted": {
      ".read": true,
      ".write": true
    },
    "expired": {
      ".read": true,
      ".write": true
    },
    "config": {
      ".read": true,
      ".write": true
    }
  }
}
```

**NEW in v5.2:** `config` node added to allow reading/writing alert keywords.

### Firebase Credentials (KEEP SECURE)

```javascript
const firebaseConfig = {
  apiKey: "AIzaSyAxoyvPSNdJuh0fQBra_PJf-mNITrDzvdg",
  authDomain: "m-r-d-notepad.firebaseapp.com",
  databaseURL: "https://m-r-d-notepad-default-rtdb.europe-west1.firebasedatabase.app",
  projectId: "m-r-d-notepad",
  storageBucket: "m-r-d-notepad.firebasestorage.app",
  messagingSenderId: "239673638225",
  appId: "1:239673638225:web:602d8bc6d5f2d5b8df6770",
  measurementId: "G-B19N4TZZJP"
};
```

**Location in HTML:** Each of the three files includes this config in the `<script>` tag at the top, passed to `initializeApp(firebaseConfig)`

---

### ⚠️ SECURITY ADVISORY

- **Read access:** Completely open (anyone with the database URL can read all entries)
- **Write access:** Completely open (anyone with the database URL can add/modify/delete entries)
- **Authentication:** None required (no Firebase Authentication active)
- **User validation:** Client-side only (users type their name; no backend verification)
- **Admin PIN:** Hardcoded (1234) in HTML, so technically anyone with the source code can access admin functions

**Design choice:** This is intentional for a small family/care app. Derek's Diary is not exposed on public search engines or shared URLs. However, understand that:
  - If the database URL is exposed, anyone could modify data
  - No audit trail of who actually wrote what (only the name they claimed in the UI)
  - Consider adding stricter rules if this app scales beyond the current trusted family/care home circle

**If you need better security in future:**
- Implement Firebase Authentication (email/password, Google Sign-In, or custom)
- Restrict write access to authenticated users only: `.write": "auth != null"`
- Add user ID tracking for audit trails
- Move admin PIN to a secure backend or authentication system
- Consider encryption for sensitive entries

---

## DEPLOYMENT

### Primary: Netlify

**Status:** Active
**Site URL:** `https://derek-notepad.netlify.app/`
**Deploy Method:** Drag HTML files to Netlify web interface (Settings → Deploy)

**Deploy Steps (v5.2):**
1. Download `derek-notepad-v52-final.zip`
2. Extract to get: index.html, kingsland.html, alerts.html
3. Navigate to https://app.netlify.com/sites/derek-notepad/files
4. Drag each HTML file individually into browser (or batch upload all three):
   - index.html
   - kingsland.html
   - alerts.html
5. Confirm all files uploaded (green checkmarks)
6. Hard-refresh live site (Ctrl+Shift+R)
7. Test admin keywords panel:
   - Open index.html
   - Click ⚙ settings cog
   - Enter PIN 1234
   - Click "🎨 Alert Keywords"
   - Add test keyword, save, verify highlighting works

### Secondary: Firebase Hosting

**Status:** Active (backup, less frequently used)
**Deploy Command:** `firebase deploy`
**Live URL:** `https://m-r-d-notepad.web.app` (may be aliased or redirected)

---

## LOCAL DEVELOPMENT & TESTING

### Current Setup

- **Testing environment:** Live Firebase database
- **Local files:** Browser-only (no Node.js build step, no Firebase emulator currently)
- **Testing method:** Edit HTML locally, open in browser, test against live database
- **Risk:** All test entries go into live data (family and staff will see test posts)

### Current Testing Best Practices

1. Test new features on local HTML first
2. Use clearly marked test data (e.g., author: "TEST - Matthew")
3. **Delete test entries immediately** after verifying functionality
4. **Never test destructive features** without explicit family approval
5. **Alert family in advance** if testing will add visible entries to live app
6. Use browser dev tools (F12 → Console) to verify Firebase sync and catch errors

### Firebase Security Rules Update Needed

**⚠️ IMPORTANT:** If deploying v5.2 for the first time, you MUST update Firebase security rules to include the `config` node. Without this, keywords won't save.

**Steps:**
1. Go to https://console.firebase.google.com
2. Select project: **m-r-d-notepad**
3. Navigate to **Realtime Database** → **Rules** tab
4. Replace entire content with the updated rules above
5. Click **Publish**

---

## KNOWN ISSUES & RECENT WORK

### Recent Bugfixes (v5.2)

✅ **Line Break Display Bug (alerts.html)**
- **Issue:** `<br>` text displayed literally instead of as line breaks
- **Root Cause:** Double-escaping in `showAlert()` function
- **Fix:** Removed redundant `esc()` call; changed `highlightNames(esc(m.text))` to `highlightNames(m.text)`
- **Status:** Fixed and tested

✅ **Settings Cog Not Opening**
- **Issue:** Clicking ⚙ settings cog did nothing
- **Root Cause:** openModal() function referenced old `modal-extra` element that no longer existed
- **Fix:** Updated openModal() to reference correct `modal-admin-menu` and `modal-keywords` elements
- **Status:** Fixed and tested

✅ **Keywords Not Saving**
- **Issue:** Keywords added in admin panel disappeared after page refresh
- **Root Cause:** Firebase security rules didn't include `config` node; writes were silently rejected
- **Fix:** Updated Firebase security rules to allow read/write on `config` node; added error handling to saveKeywords()
- **Status:** Fixed; users must update Firebase rules (see above)

### Earlier Bugfixes (v5.1)

- **Undated Entries Toggle:** Implemented admin control to show/hide entries without dates

### Earlier Bugfixes (v5)

- **Name Highlighting Logic:** Corrected highlighting algorithm across all three files

### Open Issues

- None currently identified

### Pending Features

- **Staging Database:** Separate Firebase project for safe testing before production
- **Keyword Categories:** Group keywords by type (names, events, alerts, etc.)
- **Case-Sensitive Toggle:** Option for case-sensitive keyword matching
- **Partial Match Option:** Allow partial word matches (currently whole-word only)
- **Export/Import Keywords:** Backup and restore keyword lists as JSON

---

## CHANGE MANAGEMENT PROTOCOL

**All changes follow this discipline:**

### 1. Save Rollback
- Before any edit, copy current HTML files to local backup directory with version suffix
- Keep the stable v5.2 files as reference
- Example: `index_pre-edit-[feature]-[date].html`

### 2. Assess Complexity & Risk

**Low risk:** One-line bug fix, CSS tweak, typo correction
- **Testing:** Manual browser test
- **Deployment:** Can go to Netlify immediately after confirmation

**Medium risk:** New feature, modification to form/input, change to alert logic
- **Testing:** Test on all three pages, verify real-time sync still works
- **Deployment:** Test thoroughly against live before deploying

**High risk:** Change to Firebase listeners, data structure modification, authentication logic
- **Testing:** Thorough testing against staging; create test data; verify backwards compatibility
- **Deployment:** Requires extra confirmation; consider rollback plan

### 3. Report & Request Confirmation

Describe in plain English:
- What the change is and why
- Which files are affected
- Risk level (Low / Medium / High)
- Testing approach
- Expected outcome

Wait for explicit approval before proceeding.

### 4. Deploy Carefully

- **For Netlify:** Drag updated HTML file
- **For Firebase:** Run `firebase deploy` from command line
- If multiple files updated: deploy all three together to ensure consistency
- Verify live site loads and real-time sync is working

### 5. Verify & Document

- Load live URL and test the new feature
- Post a test entry, refresh other pages, confirm it appears
- Check browser console (F12) for errors
- If all working: celebrate ✓
- If broken: execute rollback immediately
- Document what changed in this handoff for next chat

---

## FAMILY MEMBERS & AUTHORIZED USERS

**Named participants with access:**

- **Family members** (index.html): Matthew, Rebecca, Katharine, Jemima, Harry, Oscar
- **Care home staff** (kingsland.html): Keira, Colleagues
- **Derek and read-only stakeholders** (alerts.html): Derek, others (read-only only)

**User management:**

- No passwords or formal authentication
- Users type their name in the UI; app remembers via browser localStorage
- Admin access: Hardcoded PIN 1234 (behind cog icon in index.html)
- No new user onboarding process; any named user can access if they know the app URL

---

## IMPORTANT NOTES FOR NEXT CHAT

1. **Always request confirmation before deploying** — this is production data for a real family and care home.
2. **Test locally first** in browser before deploying (check console for errors).
3. **Keep the three files in sync** — any shared logic must be identical.
4. **Backup before every edit** — copy current files with date suffix before modifying.
5. **Document changes** in a new section of this handoff when you're done.
6. **Be aware of security limitations** — open Firebase rules + hardcoded PIN means trust-based access control only.
7. **Firebase rules are critical** — the `config` node MUST have read/write access for keywords to work.

---

## ENVIRONMENT & TOOLING

**Firebase CLI Version:** Latest (verify with `firebase --version` before deploying)
**Node.js Version:** Not required (browser-only development, no build step)
**Local Development Setup:** Browser-only (edit HTML locally, test in browser)

**Deploy credentials stored:** Firebase CLI authenticated via `firebase login` (credentials in local machine keychain/config)

**Recommended tools:**
- Any text editor (VS Code, Sublime, etc.)
- Modern web browser with dev tools (Chrome, Firefox, Safari)
- Browser console (F12) for debugging Firebase errors and real-time sync issues

---

## NEXT STEPS FOR NEW CHAT

1. Paste this entire document into the new chat at the start
2. State what you want to work on next (examples):
   - "Add keyword categories/groups"
   - "Implement case-sensitive keyword toggle"
   - "Set up staging Firebase database"
   - "Add export/import for keywords"
3. Claude will:
   - Verify this handoff document
   - Propose the change with risk assessment
   - Request confirmation before making edits
   - Deploy only after you approve
   - Update this handoff with changes at end of session

---

**Document Version:** 3.0 (Updated with v5.2 Configurable Keywords Admin Panel)

**Last Updated:** June 25, 2026

**Prepared by:** Claude Code with Matthew Swindells

**For:** Derek's Diary App — Family care coordination platform

**Status:** v5.2 Production Ready
