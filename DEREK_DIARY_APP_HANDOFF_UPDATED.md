# Derek's Diary App — Handoff Documentation

**For continuation in new Claude chat**

---

## PROJECT OVERVIEW

**Application Name:** Derek's Diary App (Derek Notepad)

**Purpose:** Family communication and care coordination platform. Enables family members and care home staff to post updates, notes, and observations in a shared, real-time diary. Named after Derek (a family care case).

**Users:** Family members + care home staff (named participants)

**Current Status:** Stable v5 production (Firebase-backed)

**Deployment:** Firebase Hosting + Netlify (live)

**Last Verified:** v5 stable with corrected name-highlighting logic across all three pages

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

### Three-File System (v5 Stable)

All three files share the **same Firebase Realtime Database** and must be kept in sync.

#### 1. **index.html** (Main entry point — Family Diary)

- **MD5 (stable v5):** `e9d610392e577d0dad3821c588454b67`
- **Purpose:** Primary diary view for family members (Matthew, Rebecca, Katharine, Jemima, Harry, Oscar)
- **Key Features:**
  - Post creation form (author dropdown/memory, timestamp, message text)
  - Real-time entry list with author filtering
  - Name highlighting for quick visual scanning
  - Timestamp formatting (created, modified)
  - Admin access behind PIN 1234 (cog icon)
  - Author name persisted in browser localStorage
- **Firebase Listener:** Fetches all entries on load + listens to new child additions
- **Special Functions:** Admin panel for configuring alert keywords and settings

#### 2. **kingsland.html** (Care facility view)

- **MD5 (stable v5):** `b2f18a521c134342c982d2970706d23d`
- **Purpose:** Alternative dashboard for care home staff (Keira, Colleagues)
- **Key Features:**
  - Same diary data (same Firebase database as index.html)
  - Optimized UI/UX for care facility staff workflows
  - Name highlighting (synchronized with index.html)
  - Quick-access buttons for common update types
  - Real-time sync with family diary entries
- **Firebase Listener:** Identical to index.html (shared database)
- **Differences from index.html:** Layout and button grouping only; data is identical

#### 3. **alerts.html** (Alerts & Summary Dashboard)

- **MD5 (stable v5):** `cc93b83d30bb9154ff9948f7e77d88e4` → **Updated to v5.1** (see RECENT UPDATES below)
- **Purpose:** Alert/summary dashboard for Derek and read-only stakeholders
- **Key Features:**
  - Filtered view for entries containing configurable keyword triggers
  - Green-highlighted entries matching alert keywords
  - Timestamp and author metadata for each entry
  - Configurable alert keywords (admin-controlled via alert admin page)
  - ✓ **Toggle for undated entries** (default: ON) — admin-controlled in settings cog
- **Firebase Listener:** Fetches entries, filters by keyword presence and tagDate
- **Access Control:** Read-only (Derek and other read-only users)

**v5.1 Additions (June 2026):**
- New config variable: `showUndatedCards = true` (default ON for all users)
- New admin control: "Undated entries" toggle in admin panel (behind PIN 1234)
- Preference saved to `localStorage` key `fn_show_undated` ('0' = OFF, '1' = ON)
- UI label for undated entries: Changed "DAY FUTURE" → "NOTES"
- Date/time line: Hidden (completely blank) for entries without `tagDate` field
- Filter logic: `getAlertEvents()` modified to include/exclude undated entries based on toggle state
- New functions: `updateUndatedToggleUI()` and `toggleShowUndated()`

### Rollback Backups Location

- **Stable copies:** `/home/claude/*_stable_v5.html`
  - `/home/claude/index_stable_v5.html`
  - `/home/claude/kingsland_stable_v5.html`
  - `/home/claude/alerts_stable_v5.html`
- **Always copy these before making edits** — use as emergency rollback source
- **Usage:** If a deployment fails or causes bugs, copy stable version back and redeploy

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
  }
}
```

**Node explanation:**
- **messages:** Active entries (displayed to all users)
- **deleted:** Soft-deleted entries (hidden from UI but data retained)
- **expired:** Entries marked as archived/expired (for filtering in alerts.html)

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

## FIREBASE SECURITY RULES (CURRENTLY LIVE)

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
    }
  }
}
```

### ⚠️ SECURITY ADVISORY

- **Read access:** Completely open (anyone with the database URL can read all entries)
- **Write access:** Completely open (anyone with the database URL can add/modify/delete entries)
- **Authentication:** None required (no Firebase Authentication active)
- **User validation:** Client-side only (users type their name; no backend verification)

**Design choice:** This is intentional for a small family/care app. Derek's Diary is not exposed on public search engines or shared URLs. However, understand that:
  - If the database URL (`https://m-r-d-notepad-default-rtdb.europe-west1.firebasedatabase.app`) is exposed, anyone could modify data
  - No audit trail of who actually wrote what (only the name they claimed in the UI)
  - Admin PIN (1234) is hardcoded in HTML, so technically anyone with the source code can access admin functions
  - Consider adding stricter rules if this app scales beyond the current trusted family/care home circle

**If you need better security in future:**
- Implement Firebase Authentication (email/password, Google Sign-In, or custom)
- Restrict write access to authenticated users only: `.write": "auth != null"`
- Add user ID tracking for audit trails
- Move admin PIN to a secure backend or authentication system
- Consider encryption for sensitive entries

### Current Authentication Method

- No Firebase Authentication active
- Users choose their name in the app to add items
- App remembers the last name they chose (stored in browser localStorage)
- **Family members** use `index.html` (expected users: Matthew, Rebecca, Katharine, Jemima, Harry, Oscar)
- **Care home staff** use `kingsland.html` (expected users: Keira, Colleagues)
- **Derek and read-only stakeholders** use `alerts.html` (read-only view with keyword filtering)

---

## DEPLOYMENT

### Primary: Netlify

**Status:** Active
**Site URL:** `https://derek-notepad.netlify.app/`
**Deploy Method:** Drag HTML files to Netlify web interface (Settings → Deploy)

**Deploy Steps (Single File):**
1. Navigate to https://app.netlify.com/sites/derek-notepad/files
2. Drag updated HTML file into file browser
3. Netlify auto-deploys (usually within seconds)
4. Verify at https://derek-notepad.netlify.app/ (hard refresh: Ctrl+Shift+R)

**Deploy Steps (v5.1 Update — Multiple Files):**
1. Download `derek-notepad-for-netlify-upload.zip` from outputs
2. Extract to get: index.html, kingsland.html, alerts.html
3. Navigate to https://app.netlify.com/sites/derek-notepad/files
4. Drag each HTML file individually into browser (or batch upload all three):
   - index.html (unchanged from v5)
   - kingsland.html (unchanged from v5)
   - alerts.html (NEW: v5.1 with undated entries toggle)
5. Confirm all files uploaded (green checkmarks)
6. Hard-refresh live site (Ctrl+Shift+R)
7. Test new feature:
   - Open `https://derek-notepad.netlify.app/alerts.html`
   - Click ⚙ settings cog → enter PIN 1234
   - Scroll down → "Undated entries" toggle (default: ON)
   - Toggle ON/OFF → undated entries show/hide
   - Refresh → toggle state persists in localStorage

### Secondary: Firebase Hosting

**Status:** Active (backup, less frequently used)
**Deploy Command:** `firebase deploy`
**Live URL:** `https://m-r-d-notepad.web.app` (may be aliased or redirected)

**Deploy Checklist:**
1. Save rollback backup of all three HTML files to `/mnt/user-data/outputs/`
2. Assess change complexity and risk (see CHANGE MANAGEMENT PROTOCOL)
3. Report proposed changes and request confirmation
4. On approval: either drag to Netlify (primary) or run `firebase deploy` (secondary)
5. Verify live site loads at `https://derek-notepad.netlify.app/`
6. Test real-time sync: post entry from one page, refresh another, confirm it appears

---

## LOCAL DEVELOPMENT & TESTING

### Current Setup

- **Testing environment:** Live Firebase database (`https://m-r-d-notepad-default-rtdb.europe-west1.firebasedatabase.app`)
- **Local files:** Browser-only (no Node.js build step, no Firebase emulator currently)
- **Testing method:** Edit HTML locally, open in browser, test against live database
- **Risk:** All test entries go into live data (family and staff will see test posts)

### Current Testing Best Practices (Until Staging Exists)

1. Test new features on local HTML first (open in browser, test form submission, check browser console for errors)
2. Use clearly marked test data (e.g., author: "TEST - Matthew", message: "TEST ENTRY - ignore")
3. **Delete test entries immediately** after verifying functionality (don't leave test clutter in live data)
4. **Never test destructive features** (delete, modify past entries, soft-delete) against live without explicit family approval
5. **Alert family in advance** if testing will add visible entries to live app
6. Use browser dev tools (F12 → Console) to verify Firebase sync and catch errors before deploying

### Future Infrastructure Plan: Staging Database

**Status:** Planned (backlog)
**Goal:** Separate Firebase project for safe testing before production deployment
**Benefits:**
- Test new features without affecting family's live data
- Verify real-time sync and multi-page consistency without live family entries
- Safer testing of destructive operations (deletes, bulk changes)

**When Implemented:** Will require:
1. New Firebase project created (`m-r-d-notepad-staging` or similar)
2. Updated HTML files with config toggle (dev/staging/production environments)
3. Separate firebaseConfig for staging database
4. Updated deployment script to target correct database (staging vs. production)
5. Optional: Firebase emulator for local testing without any network calls

**Current blocker:** Not urgent because current risk is acceptable (small trusted group), but should be prioritized if app usage scales or data sensitivity increases.

---

## KNOWN ISSUES & RECENT WORK

### Recent Updates (v5.1 — June 2026)

- **Undated Entries Toggle (alerts.html):** ✓ COMPLETED
  - Added admin control in settings cog to show/hide entries without dates
  - Default: ON (entries without dates visible by default)
  - Preference persisted in localStorage
  - UI label: "NOTES" for undated entry section (instead of "DAY FUTURE")
  - Date/time line hidden completely for undated entries (no "invalid date" display)
  - New functions: `updateUndatedToggleUI()`, `toggleShowUndated()`
  - Modified: `getAlertEvents()` filter logic, `initToggle()` initialization
  - Files affected: `alerts.html` only
  - Status: Tested and ready for Netlify deployment

### Earlier Bugfixes (v5)

- **Name Highlighting Logic:** Corrected highlighting algorithm across all three files to ensure consistent author name rendering
  - Files affected: `index.html`, `kingsland.html`, `alerts.html`
  - Pattern: Regex-based matching of author names in message text
  - Status: Verified and stable

### Open Issues

- None currently identified

### Pending Features

- **Alert Admin Page:** Add configurable keyword list behind cog icon in alerts.html
  - Users should be able to add/remove words that trigger green highlighting
  - Storage: Save to Firebase config node (e.g., `config/alertKeywords`)
  - Status: Designed, backlog

---

## CHANGE MANAGEMENT PROTOCOL

**All changes follow this discipline:**

### 1. Save Rollback
- Before any edit, copy current HTML files to `/mnt/user-data/outputs/` with version suffix
- Example: `index_pre-edit-20260621.html`
- Keep the three stable v5 MD5 files as reference (`index_stable_v5.html`, etc.)

### 2. Assess Complexity & Risk

**Low risk:** One-line bug fix, CSS tweak, typo correction
- **Example:** Change button color, fix typo in UI label
- **Testing:** Manual browser test
- **Deployment:** Can go to Netlify immediately after confirmation

**Medium risk:** New feature, modification to form/input, change to alert logic
- **Example:** Add configurable keywords, new filter option
- **Testing:** Test on all three pages, verify real-time sync still works
- **Deployment:** Test against staging database first (when available); otherwise test thoroughly against live before deploying

**High risk:** Change to Firebase listeners, data structure modification, authentication logic, multi-file sync
- **Example:** Change database node structure, modify listener logic, add new data field
- **Testing:** Thorough testing against staging; create test data; verify backwards compatibility
- **Deployment:** Requires extra confirmation; consider rollback plan

### 3. Report & Request Confirmation

Describe in plain English:
- What the change is and why
- Which files are affected (index.html, kingsland.html, alerts.html, or multiple)
- Risk level (Low / Medium / High)
- Testing approach
- Expected outcome

Wait for explicit approval before proceeding.

### 4. Deploy Carefully

- **For Netlify (primary):** Drag updated HTML file to https://derek-notepad.netlify.app/
- **For Firebase:** Run `firebase deploy` from command line
- If multiple files are updated: deploy all three files together to ensure consistency
- Verify live site loads and real-time sync is working across all three pages

### 5. Verify & Document

- Load live URL and test the new feature
- Post a test entry, refresh other pages, confirm it appears
- Check browser console (F12) for errors
- If all working: celebrate ✓
- If broken: execute rollback (copy stable_v5.html back and redeploy)
- Document what changed, why, and outcome in this handoff for the next chat

---

## FAMILY MEMBERS & AUTHORIZED USERS

**Named participants with access:**

- **Family members** (index.html): Matthew, Rebecca, Katharine, Jemima, Harry, Oscar
- **Care home staff** (kingsland.html): Keira, Colleagues
- **Derek and read-only stakeholders** (alerts.html): Derek, others (read-only only)

**User management:**

- No passwords or formal authentication
- Users type their name in the UI; app remembers via browser localStorage
- Admin access: Hardcoded PIN 1234 (behind cog icon in index.html and alerts.html)
- No new user onboarding process; any named user can access if they know the app URL

---

## IMPORTANT NOTES FOR NEXT CHAT

1. **Always request confirmation before deploying** — this is production data for a real family and care home.
2. **Test locally first** in browser before deploying (check console for errors).
3. **Keep the three files in sync** — any shared logic (Firebase listeners, name highlighting, keyword lists) must be identical.
4. **Backup before every edit** — copy stable HTML files to `/mnt/user-data/outputs/` with date suffix.
5. **Document changes** in a new section of this handoff when you're done, so the next chat knows what was updated.
6. **Be aware of security limitations** — open Firebase rules + hardcoded PIN means trust-based access control only.
7. **Testing against live:** Remember that all test entries go into the live family diary. Use obviously marked "TEST" entries and delete them immediately.

---

## ENVIRONMENT & TOOLING

**Firebase CLI Version:** Latest (verify with `firebase --version` before deploying)
**Node.js Version:** Not required (browser-only development, no build step)
**Local Development Setup:** Browser-only (edit HTML locally, test in browser, no emulator currently)

**Deploy credentials stored:** Firebase CLI authenticated via `firebase login` (credentials in local machine keychain/config)

**Recommended tools:**
- Any text editor (VS Code, Sublime, etc.)
- Modern web browser with dev tools (Chrome, Firefox, Safari)
- Browser console (F12) for debugging Firebase errors and real-time sync issues

---

## NEXT STEPS FOR NEW CHAT

1. Paste this entire document into the new chat at the start
2. State what you want to work on next (examples):
   - "Add configurable alert keywords admin page"
   - "Implement staging Firebase database"
   - "Fix timestamp timezone issue"
   - "Add undated card toggle"
3. Claude will:
   - Verify this handoff document and ask clarifying questions if needed
   - Propose the change with risk assessment
   - Request confirmation before making edits
   - Deploy only after you approve
   - Update this handoff with changes at end of session

---

## v5.1 TECHNICAL IMPLEMENTATION DETAILS

### Undated Entries Toggle (alerts.html)

**Configuration Variable:**
```javascript
var showUndatedCards = true; // default ON for all new users
```

**LocalStorage Key:** `fn_show_undated`
- Value: '0' (OFF) or '1' (ON)
- Default: true (ON) if key not found

**Modified Functions:**

1. **`getAlertEvents()`** — Filter logic
   - Added check: if entry has no `tagDate`, evaluate toggle state
   - If `showUndatedCards = false`: skip undated entries
   - If `showUndatedCards = true`: include undated entries in results
   - Sort order: Dated entries first (chronological), then undated entries (ZZZZ placeholder)

2. **`initToggle()`** — Initialization
   - Added: Load `fn_show_undated` from localStorage
   - Default to true if not found (backwards compatible)
   - Call `updateUndatedToggleUI()` to render initial state

3. **`updateUndatedToggleUI()`** — New function
   - Updates button element (`#undated-toggle-btn`) styling (ON/OFF state)
   - Updates label element (`#undated-toggle-label`) text
   - Matches existing toggle styling (gold when ON, gray when OFF)

4. **`toggleShowUndated()`** — New function
   - Toggle boolean state: `showUndatedCards = !showUndatedCards`
   - Save preference to localStorage
   - Call `updateUndatedToggleUI()` to reflect change
   - Call `clearAlertTimers()` and `scheduleAlerts()` to refresh alert display

**HTML Admin Control:**
```html
<div class="card">
  <div class="section-title">Undated entries</div>
  <div class="toggle-row">
    <button id="undated-toggle-btn" onclick="toggleShowUndated()">ON</button>
    <span id="undated-toggle-label">Show entries without dates: ON</span>
  </div>
  <div style="font-size:12px;color:rgba(255,255,255,0.5);margin-top:8px;">Entries missing a date are shown by default</div>
</div>
```

**UI Rendering Changes (showAlert function):**
- Section header: `dayLabels[m.tagDate] || 'NOTES'` (was: `'DAY ' + ... 'FUTURE'`)
- Date/time line: Conditionally rendered only if `m.tagDate` exists
  - If entry has tagDate: show formatted date + time
  - If entry has no tagDate: render nothing (completely blank)

**Testing Checklist:**
- ✓ Toggle appears in admin panel (behind PIN 1234)
- ✓ Default: ON for new users
- ✓ Toggle ON: undated entries visible
- ✓ Toggle OFF: undated entries hidden
- ✓ Close browser → reopen → toggle state persists
- ✓ No "invalid date" message shown for undated entries
- ✓ Section header shows "NOTES" for undated entries
- ✓ Date/time display completely blank for undated entries

---

**Document Version:** 2.1 (Updated with v5.1 Undated Toggle Feature)
**Last Updated:** 21 June 2026
**Prepared by:** Matthew Swindells (with v5.1 updates)
**For:** Derek's Diary App — Family care coordination platform
**Status:** Ready for Claude Code deployment and new chat handoff

## CHANGELOG (v2.0 → v2.1)

- **alerts.html updated to v5.1:** Implemented undated entries toggle feature
  - Default: ON (undated entries visible)
  - Admin control in settings cog (PIN 1234)
  - Preference saved to localStorage (`fn_show_undated`)
  - UI: "NOTES" label for undated section, no date/time display for undated entries
  - New functions: `updateUndatedToggleUI()`, `toggleShowUndated()`
  - Modified: `getAlertEvents()`, `initToggle()`
- Deployment package created: `derek-notepad-for-netlify-upload.zip` (all three HTML files)
- Updated deployment instructions with Netlify upload steps for v5.1

