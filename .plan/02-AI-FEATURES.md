# AI FEATURES TECHNICAL SPECIFICATION

## Overview

Chrome's Built-in AI features use on-device models (primarily Gemini Nano) to provide AI capabilities without sending data to the cloud. These features are controlled by:

1. **Build Flags** - Compile-time switches in GN files
2. **Chrome Flags** - Runtime flags visible in chrome://flags
3. **Component Downloads** - Model files downloaded via Chrome's component updater

---

## Feature Dependencies

### Gemini Nano (Base Model)

| Aspect | Details |
|--------|---------|
| Build Flag | `use_on_device_model_service=true` |
| Chrome Flag | `optimization-guide-on-device-model` |
| Component | OptimizationGuidePredictionModels |
| Model Size | ~1-2GB |
| Storage | `~/Library/Application Support/[Browser]/OptimizationGuidePredictionModels/` |

### Prompt API

| Aspect | Details |
|--------|---------|
| Chrome Flag | `prompt-api-for-gemini-nano` |
| Additional Flag | `prompt-api-for-gemini-nano-multimodal-input` |
| Depends On | Gemini Nano model |
| API Access | `window.ai.languageModel` (proposed) |

### Summarizer API

| Aspect | Details |
|--------|---------|
| Chrome Flag | `summarization-api-for-gemini-nano` |
| Depends On | Gemini Nano model |
| API Access | `window.ai.summarizer` |

### Writer API

| Aspect | Details |
|--------|---------|
| Chrome Flag | `writer-api-for-gemini-nano` |
| Depends On | Gemini Nano model |
| API Access | `window.ai.writer` |

### Rewriter API

| Aspect | Details |
|--------|---------|
| Chrome Flag | `rewriter-api-for-gemini-nano` |
| Depends On | Gemini Nano model |
| API Access | `window.ai.rewriter` |

### Proofreader API

| Aspect | Details |
|--------|---------|
| Chrome Flag | `proofreader-api-for-gemini-nano` |
| Depends On | Gemini Nano model |
| API Access | `window.ai.proofreader` |

---

## Excluded Features (Not Implementing)

### Language Detector API

| Aspect | Details |
|--------|---------|
| Build Flag | `enable_screen_ai_service=true` |
| Chrome Flag | `language-detection-api` |
| Why Excluded | Requires ScreenAI service restoration (~90 lines of code across multiple files) |
| Complexity | High - involves component installer, sandbox setup, mojo bindings |

### Translator API

| Aspect | Details |
|--------|---------|
| Chrome Flag | `translation-api` |
| Additional Flag | `translation-api-streaming-by-sentence` |
| Why Excluded | User chose to keep translation disabled |

---

## What Helium Disables (And We Must Re-enable)

### 1. On-Device Model Service (Build Time)

**File:** `ungoogled-chromium/fix-building-with-prunned-binaries.patch`

```cpp
// Line 1268-1269 in patch
-  use_on_device_model_service = is_win || is_mac || is_linux || is_ios || is_cbx
+  use_on_device_model_service = false
```

**Our Fix:** Create patch to set `use_on_device_model_service = true`

### 2. AI Flags Hidden (Runtime)

**File:** `helium/core/exclude-irrelevant-flags.patch`

Adds these to `kExcludedFlags` (hides from chrome://flags):

```cpp
// AI-related flags we need to REMOVE from exclusion:
"prompt-api-for-gemini-nano",
"prompt-api-for-gemini-nano-multimodal-input", 
"summarization-api-for-gemini-nano",
"writer-api-for-gemini-nano",
"rewriter-api-for-gemini-nano",
"proofreader-api-for-gemini-nano",
"optimization-guide-on-device-model",

// These stay excluded (translation disabled by user choice):
"translation-api",
"translation-api-streaming-by-sentence",
"language-detection-api",
```

**Our Fix:** Create patch that removes AI flags from kExcludedFlags

### 3. AI Component Downloads Blocked

**File:** `helium/core/component-updates.patch`

```cpp
static constexpr auto kAllowedComponents =
  base::MakeFixedFlatSet<std::string_view>(
    base::sorted_unique,
      {
        "hfnkpimlhhgieaddgfemjhofmfblmnib", // CRLSet only
      }
  );
```

**Our Fix:** Create patch adding OptimizationGuidePredictionModels component ID

---

## Model Delivery Flow

```
1. User enables AI flag in chrome://flags
2. Browser checks update.googleapis.com for OptimizationGuide component
3. Component updater downloads model (~1-2GB)
4. Model stored in user profile directory
5. on_device_model_service loads model at runtime
6. JavaScript APIs become available to web pages
```

### Helium's Component URL Proxy

Helium routes component updates through its own servers:

```cpp
// In component-updates.patch
return {helium::GetComponentUpdateURL(GetProfilePrefs())};
// Points to Helium's servers, not Google's
```

For AI to work, Helium services must allow the OptimizationGuide component OR we bypass the proxy for this specific component.

---

## Offline Availability

| Feature | Works Offline? | Requirements |
|---------|---------------|--------------|
| Gemini Nano | Yes | Model must be downloaded first |
| Prompt API | Yes | Uses local Gemini Nano |
| Summarizer API | Yes | Uses local Gemini Nano |
| Writer API | Yes | Uses local Gemini Nano |
| Rewriter API | Yes | Uses local Gemini Nano |
| Proofreader API | Yes | Uses local Gemini Nano |

**First Run:** Requires internet to download model (~1-2GB)
**After Download:** Fully offline capable

---

## API Key Requirements

| Feature | API Key Needed? |
|---------|----------------|
| Gemini Nano | No |
| Prompt API | No |
| Summarizer API | No |
| Writer API | No |
| Rewriter API | No |
| Proofreader API | No |

**All enabled AI features are fully on-device and require NO API keys.**

---

## Flags to Unhide (kExcludedFlags Removal)

Create a patch that removes these entries from `kExcludedFlags` in `chrome/browser/about_flags.cc`:

```cpp
// REMOVE from kExcludedFlags (make visible):
"prompt-api-for-gemini-nano",
"prompt-api-for-gemini-nano-multimodal-input",
"summarization-api-for-gemini-nano", 
"writer-api-for-gemini-nano",
"rewriter-api-for-gemini-nano",
"proofreader-api-for-gemini-nano",
"optimization-guide-on-device-model",

// KEEP in kExcludedFlags (stay hidden - privacy):
"translation-api",
"translation-api-streaming-by-sentence",
"language-detection-api",
// ... all other Helium exclusions for privacy
```

---

## Component Allowlist Modification

Modify the allowlist in `component-updates.patch` to include AI models:

```cpp
static constexpr auto kAllowedComponents =
  base::MakeFixedFlatSet<std::string_view>(
    base::sorted_unique,
      {
        "hfnkpimlhhgieaddgfemjhofmfblmnib", // CRLSet
        "lmelglejhemejginpboagddgdfbepgmp", // OptimizationGuidePredictionModels
      }
  );
```

---

## Build Flag Change Required

In `fix-building-with-prunned-binaries.patch`, change:

```cpp
// FROM:
use_on_device_model_service = false

// TO:
use_on_device_model_service = is_win || is_mac || is_linux
```

This single change enables the entire on-device AI infrastructure.
