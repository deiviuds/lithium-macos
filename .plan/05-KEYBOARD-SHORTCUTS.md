# KEYBOARD SHORTCUTS SPECIFICATION

## Overview

Modify macOS keyboard shortcuts to match browser standards:
- **Cmd+D** → Focus address bar (instead of bookmark)
- **Cmd+Shift+D** → Add bookmark (moved from Cmd+D)

---

## Current Helium Shortcuts

From `helium/core/keyboard-shortcuts.patch`:

| Shortcut | Action | Command ID |
|----------|--------|------------|
| Cmd+D | Add Bookmark | `IDC_BOOKMARK_PAGE` |
| Cmd+Shift+C | Copy URL | Custom addition |
| Cmd+Shift+E | Inspect Element | Custom addition |

---

## Desired Lithium Shortcuts

| Shortcut | Action | Command ID |
|----------|--------|------------|
| Cmd+D | Focus Address Bar | `IDC_FOCUS_LOCATION` |
| Cmd+Shift+D | Add Bookmark | `IDC_BOOKMARK_PAGE` |
| Cmd+Shift+C | Copy URL | Keep from Helium |
| Cmd+Shift+E | Inspect Element | Keep from Helium |

---

## Files to Modify

### 1. Global Keyboard Shortcuts (macOS)

**File:** `chrome/browser/global_keyboard_shortcuts_mac.mm`

```cpp
// Current Helium (approximate structure):
{true,  false, false, false, kVK_ANSI_D, IDC_BOOKMARK_PAGE},

// Lithium change:
// Cmd+D focuses address bar
{true,  false, false, false, kVK_ANSI_D, IDC_FOCUS_LOCATION},
// Cmd+Shift+D adds bookmark
{true,  true,  false, false, kVK_ANSI_D, IDC_BOOKMARK_PAGE},
```

**Key mapping:**
- `{cmd, shift, ctrl, alt, keycode, command}`
- `true, false, false, false` = Cmd only
- `true, true, false, false` = Cmd+Shift

### 2. Cocoa Accelerators

**File:** `chrome/browser/ui/cocoa/accelerators_cocoa.mm`

May need similar updates to ensure consistency.

---

## Command IDs Reference

| Command ID | Action |
|------------|--------|
| `IDC_FOCUS_LOCATION` | Focus the address bar |
| `IDC_BOOKMARK_PAGE` | Add current page to bookmarks |
| `IDC_BOOKMARK_ALL_TABS` | Bookmark all open tabs |
| `IDC_COPY` | Copy selected content |
| `IDC_DEV_TOOLS_INSPECT` | Open DevTools inspect mode |

---

## Implementation Approach

### Option A: Override Helium's keyboard-shortcuts.patch

Create `lithium/core/keyboard-shortcuts.patch` that:
1. Applies AFTER Helium's patch
2. Modifies the specific Cmd+D binding
3. Adds new Cmd+Shift+D binding

### Option B: Replace Helium's patch entirely

Create complete replacement patch that includes:
- All of Helium's shortcut additions (Cmd+Shift+C, Cmd+Shift+E)
- Modified Cmd+D behavior
- New Cmd+Shift+D binding

**Decision:** Option A (override) is cleaner and more maintainable.

---

## Patch Content

```patch
# lithium/macos/keyboard-shortcuts.patch
# Modifies Cmd+D to focus address bar, adds Cmd+Shift+D for bookmark

--- a/chrome/browser/global_keyboard_shortcuts_mac.mm
+++ b/chrome/browser/global_keyboard_shortcuts_mac.mm
@@ [line numbers will vary]
-      {true,  false, false, false, kVK_ANSI_D,            IDC_BOOKMARK_PAGE},
+      // Lithium: Cmd+D focuses address bar (browser standard)
+      {true,  false, false, false, kVK_ANSI_D,            IDC_FOCUS_LOCATION},
+      // Lithium: Cmd+Shift+D adds bookmark (moved from Cmd+D)
+      {true,  true,  false, false, kVK_ANSI_D,            IDC_BOOKMARK_PAGE},
```

---

## Testing

After applying patches:

1. Launch browser
2. Press Cmd+D → Address bar should focus
3. Press Cmd+Shift+D → Bookmark dialog should open
4. Verify Cmd+Shift+C (copy URL) still works
5. Verify Cmd+Shift+E (inspect element) still works
