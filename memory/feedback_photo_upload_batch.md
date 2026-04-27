---
name: Upload photos in batch not individually
description: Select all 3 photos in a single file upload action instead of uploading one by one
type: feedback
---

## Rule

When uploading profile photos during IPCF, select all 3 photos in a single file upload action. Do NOT upload them one by one.

**Why:** Uploading one by one is very slow. Batch upload is faster and matches how a real user would interact.

**How to apply:**
- Use the file upload tool with all 3 file paths at once
- Single `browser_file_upload` call with array of 3 paths

**Validated:** 2026-03-25
