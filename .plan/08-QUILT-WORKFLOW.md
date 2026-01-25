# PATCH WORKFLOW WITH QUILT

## Overview

Helium uses `quilt` for patch management. This document explains how quilt works and how to use it for Lithium development.

---

## What is Quilt?

Quilt manages a stack of patches as a "series". Patches are applied in order and can be pushed, popped, refreshed, and edited.

### Key Concepts

| Concept | Description |
|---------|-------------|
| Series | Ordered list of patches in `patches/series` file |
| Stack | Currently applied patches |
| Top | Most recently applied patch |
| Push | Apply next patch in series |
| Pop | Remove top patch from stack |
| Refresh | Update patch with current changes |

---

## Directory Structure

```
patches/
├── series              # List of patches in order
├── ungoogled-chromium/
│   └── *.patch
├── helium/
│   └── core/*.patch
└── lithium/            # Your patches (at the end)
    └── core/*.patch
```

---

## Helium's `he` Command

The `dev.sh` script provides the `he` command wrapper:

| Command | Description |
|---------|-------------|
| `he merge` | Combine helium-chromium/patches/series + patches/series → patches/series.merged |
| `he push` | Apply all patches: `quilt push -a --refresh` |
| `he pop` | Remove all patches: `quilt pop -a` |
| `he validate` | Dry-run to check patches apply |

### Typical Workflow

```bash
# 1. Initialize environment
source dev.sh

# 2. Merge series files
he merge

# 3. Apply all patches
he push

# 4. Build
./build.sh arm64
```

---

## Creating New Patches

### Method 1: From Scratch

```bash
# 1. Apply all existing patches
source dev.sh
he merge
he push

# 2. Create new patch
quilt new lithium/core/my-feature.patch

# 3. Add files to patch
quilt add build/src/path/to/file.cc

# 4. Edit the file
vim build/src/path/to/file.cc

# 5. Save changes to patch
quilt refresh

# 6. Pop and verify
quilt pop
quilt push
```

### Method 2: Copy and Modify

```bash
# 1. Copy existing patch
cp patches/helium/core/example.patch patches/lithium/core/my-feature.patch

# 2. Edit the patch file directly
vim patches/lithium/core/my-feature.patch

# 3. Add to series (at end)
echo "lithium/core/my-feature.patch" >> patches/series

# 4. Test
quilt push -a
```

---

## Editing Existing Patches

```bash
# 1. Apply patches up to the one you want to edit
quilt push lithium/core/my-feature.patch

# 2. Edit files
vim build/src/path/to/file.cc

# 3. Update patch
quilt refresh

# 4. Continue applying remaining patches
quilt push -a
```

---

## Fixing Patch Conflicts

When `quilt push` fails:

### Step 1: See the Error

```bash
$ quilt push
Applying patch lithium/core/my-feature.patch
patching file chrome/browser/about_flags.cc
Hunk #1 FAILED at 1234.
1 out of 1 hunk FAILED -- rejects in file chrome/browser/about_flags.cc
Patch lithium/core/my-feature.patch does not apply (enforce with -f)
```

### Step 2: Force Apply and See Rejections

```bash
$ quilt push -f
Applying patch lithium/core/my-feature.patch
patching file chrome/browser/about_flags.cc
Hunk #1 FAILED at 1234.
1 out of 1 hunk FAILED -- saving rejects to file chrome/browser/about_flags.cc.rej
Applied patch lithium/core/my-feature.patch (forced; needs refresh)
```

### Step 3: View Rejection File

```bash
$ cat build/src/chrome/browser/about_flags.cc.rej
--- chrome/browser/about_flags.cc
+++ chrome/browser/about_flags.cc
@@ -1234,6 +1234,7 @@
 context that no longer matches
-old line that doesn't exist
+new line we wanted to add
```

### Step 4: Fix Manually

```bash
# Edit the actual file to make intended changes
vim build/src/chrome/browser/about_flags.cc
```

### Step 5: Refresh Patch

```bash
$ quilt refresh
Refreshed patch lithium/core/my-feature.patch
```

### Step 6: Clean Up and Continue

```bash
$ rm build/src/chrome/browser/about_flags.cc.rej
$ quilt push -a
```

---

## Quilt Environment Variables

Set in `devutils/set_quilt_vars.sh`:

```bash
export QUILT_PATCHES="patches"
export QUILT_SERIES="series.merged"
export QUILT_PC=".pc"
export QUILT_REFRESH_ARGS="-p ab --no-timestamps --no-index --sort"
export QUILT_DIFF_OPTS="--show-c-function"
```

---

## Common Operations

### Check Current State

```bash
# See which patches are applied
quilt applied

# See which patches are not yet applied
quilt unapplied

# See current top patch
quilt top
```

### View Patch Contents

```bash
# Show diff of a patch
quilt diff -P lithium/core/my-feature.patch

# Show files in a patch
quilt files lithium/core/my-feature.patch
```

### Rename/Move Patch

```bash
# 1. Pop the patch
quilt pop lithium/core/old-name.patch

# 2. Rename file
mv patches/lithium/core/old-name.patch patches/lithium/core/new-name.patch

# 3. Update series file
# (edit patches/series to change old-name.patch to new-name.patch)

# 4. Push again
quilt push
```

### Delete Patch

```bash
# 1. Pop if applied
quilt pop lithium/core/to-delete.patch

# 2. Remove from series
# (edit patches/series to remove the line)

# 3. Delete file
rm patches/lithium/core/to-delete.patch
```

---

## Patch Format

Patches use unified diff format with `-p1` strip level:

```patch
# Header (optional but helpful)
Description of what this patch does

--- a/path/to/file.cc
+++ b/path/to/file.cc
@@ -123,6 +123,7 @@ void SomeFunction() {
   // context line (unchanged)
   // another context line
-  // line being removed
+  // line being added
   // more context
 }
```

### Format Rules

1. Paths start with `a/` and `b/`
2. Line numbers in `@@ -old,count +new,count @@`
3. Context lines (unchanged) have no prefix
4. Removed lines start with `-`
5. Added lines start with `+`
6. End file with newline

---

## Tips

1. **Always test after refresh:** `quilt pop && quilt push`
2. **Backup before major changes:** `cp -r patches patches.backup`
3. **Keep patches small:** One logical change per patch
4. **Use descriptive names:** `enable-gemini-nano.patch` not `fix.patch`
5. **Comment in patches:** Add header explaining purpose
