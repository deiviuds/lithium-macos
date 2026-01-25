# AI-ASSISTED PATCH FIXING GUIDE

## Overview

When patches fail to apply after upstream Helium updates, use this guide to leverage AI for generating corrected patches.

---

## When Patches Fail

After running `he push` or `quilt push`, you may see:

```
Applying patch lithium/core/restore-ai-flags.patch
patching file chrome/browser/about_flags.cc
Hunk #1 FAILED at 13832.
1 out of 1 hunk FAILED -- saving rejects to file chrome/browser/about_flags.cc.rej
Patch lithium/core/restore-ai-flags.patch does not apply (enforce with -f)
```

---

## Step 1: Gather Information

### Get the Failing Patch Content

```bash
cat patches/lithium/core/restore-ai-flags.patch
```

### Get the Quilt Error

```bash
quilt push 2>&1 | tee /tmp/quilt-error.txt
```

### Get the Rejection File

```bash
cat build/src/chrome/browser/about_flags.cc.rej
```

### Get Current Source Context

```bash
# Find the area that should be patched
grep -n -C 20 "kExcludedFlags" build/src/chrome/browser/about_flags.cc | head -60
```

---

## Step 2: AI Prompt Template

Copy and paste this template to your AI assistant:

```
I'm maintaining a Chromium fork called Lithium Browser (based on Helium). 
A patch failed to apply after syncing with upstream.

## Failing Patch

```patch
[PASTE FULL PATCH CONTENT HERE]
```

## Error Message

```
[PASTE QUILT/GIT ERROR HERE]
```

## Rejection Details

```
[PASTE .rej FILE CONTENT HERE]
```

## Current Source Code (around the affected area)

```cpp
[PASTE ~40 LINES OF CURRENT SOURCE CODE]
```

## Original Intent

[DESCRIBE WHAT THE PATCH IS SUPPOSED TO DO]

For example: "This patch should remove certain flags from the kExcludedFlags 
set so they appear in chrome://flags"

## Request

Please provide:
1. Analysis of why the patch failed
2. A corrected unified diff (-p1 format) that achieves the same goal
3. Any notes about potential future maintenance issues

The corrected patch should:
- Match the current source code structure
- Preserve the original intent
- Follow Chromium coding style
- Use proper unified diff format with a/ and b/ prefixes
```

---

## Step 3: Apply the Fix

### Save the Corrected Patch

```bash
# Backup original
cp patches/lithium/core/restore-ai-flags.patch patches/lithium/core/restore-ai-flags.patch.bak

# Write corrected patch
cat > patches/lithium/core/restore-ai-flags.patch << 'EOF'
[PASTE AI-PROVIDED CORRECTED PATCH HERE]
EOF
```

### Test the Fix

```bash
# Remove any partially applied patches
quilt pop -a

# Try applying again
quilt push -a

# If successful, remove backup
rm patches/lithium/core/restore-ai-flags.patch.bak
```

---

## Step 4: Commit the Fix

```bash
git add patches/lithium/core/restore-ai-flags.patch
git commit -m "Fix restore-ai-flags.patch for Chromium XXX update"
```

---

## Common Failure Patterns

### Pattern 1: Line Number Offset

**Symptom:** Hunk fails at different line number
**Cause:** Code above the patched area was added/removed
**Fix:** Update the @@ line numbers in the patch

```patch
# Original
@@ -13832,10 +13832,8 @@

# After code added above
@@ -13850,10 +13850,8 @@
```

### Pattern 2: Context Mismatch

**Symptom:** Context lines don't match
**Cause:** Surrounding code changed slightly
**Fix:** Update context lines to match current source

```patch
# Original context
   some_old_function_call();
-  excluded_flag_here
+  // flag removed

# New context needed
   some_new_function_call();  // Function was renamed
-  excluded_flag_here
+  // flag removed
```

### Pattern 3: Target Code Moved

**Symptom:** Entire hunk fails, target code not at expected location
**Cause:** File was restructured or code moved to different file
**Fix:** Find new location and rewrite patch

```bash
# Search for the code
grep -rn "kExcludedFlags" build/src/chrome/

# May find it in a different file now
```

### Pattern 4: Target Code Removed

**Symptom:** Code we're trying to modify no longer exists
**Cause:** Upstream removed the feature entirely
**Fix:** May need to remove the patch or rewrite for new approach

---

## Prevention Tips

1. **Keep patches minimal:** Small, focused patches are easier to fix
2. **Add context:** Include more context lines (3+) for resilience
3. **Document intent:** Comments help when rewriting patches
4. **Test frequently:** Sync with upstream weekly to catch issues early
5. **Version pin:** Note which Chromium version the patch was written for

---

## Example AI Session

### User Input

```
I'm maintaining a Chromium fork. This patch failed:

--- a/chrome/browser/about_flags.cc
+++ b/chrome/browser/about_flags.cc
@@ -13832,10 +13832,8 @@
 constexpr auto kExcludedFlags = base::MakeFixedFlatSet<std::string_view>({
   "some-flag",
-  "prompt-api-for-gemini-nano",
   "other-flag",
 });

Error: Hunk #1 FAILED at 13832

Current source shows kExcludedFlags is now at line 14102 and "some-flag" 
was renamed to "some-new-flag".

Intent: Remove "prompt-api-for-gemini-nano" from exclusion list.
```

### AI Response

```
The patch failed because:
1. Line offset changed (13832 → 14102)
2. Context changed ("some-flag" → "some-new-flag")

Corrected patch:

--- a/chrome/browser/about_flags.cc
+++ b/chrome/browser/about_flags.cc
@@ -14102,10 +14102,8 @@
 constexpr auto kExcludedFlags = base::MakeFixedFlatSet<std::string_view>({
   "some-new-flag",
-  "prompt-api-for-gemini-nano",
   "other-flag",
 });

Future maintenance: The kExcludedFlags set may continue to change. 
Consider adding a comment near your removal to mark it as intentional.
```

---

## Automation Script (Optional)

Create `fix-patch.sh`:

```bash
#!/bin/bash
# Usage: ./fix-patch.sh patches/lithium/core/failing.patch

PATCH=$1

echo "=== Patch Content ==="
cat "$PATCH"

echo ""
echo "=== Rejection Files ==="
find build/src -name "*.rej" -exec cat {} \;

echo ""
echo "=== Copy above to AI assistant ==="
echo "Then save corrected patch and run: quilt push -a"
```
