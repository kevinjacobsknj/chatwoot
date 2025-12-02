# Chatwoot Branding Cleanup Report

## FILES TO DELETE

### 1. Chatwoot-Branded Images
```
./app/javascript/dashboard/assets/images/chatwoot_bot.png
./public/assets/images/chatwoot_bot.png
```

### 2. SVG Logos (Keeping PNG Only)
```
public/brand-assets/logo.svg
public/brand-assets/logo_dark.svg
public/brand-assets/logo_thumbnail.svg
```

### 3. Enterprise Directory (ENTIRE)
```
./enterprise/  (entire directory and all contents)
./spec/enterprise/  (enterprise specs)
```

## FILES TO KEEP & REPLACE WITH WILLO PNGS

### Core Brand Assets (public/brand-assets/)
- ✓ logo.png (replace with willoblk.png)
- ✓ logo_dark.png (replace with white version)
- ✓ logo_thumbnail.png (replace with Vector_2295.png - black W)
- ✓ logo_thumbnail_dark.png (replace with Vector_2294.png - white W)
- ✓ favicon.png (replace with Vector_2295.png resized)

### Favicon Files (public/)
All need to be regenerated from Willo logo:
- favicon-16x16.png
- favicon-32x32.png
- favicon-96x96.png
- favicon-512x512.png
- favicon-badge-16x16.png
- favicon-badge-32x32.png

### Apple/Mobile Icons (public/)
- apple-icon.png
- apple-icon-57x57.png
- apple-icon-60x60.png
- apple-icon-72x72.png
- apple-icon-76x76.png
- apple-icon-114x114.png
- apple-icon-120x120.png
- apple-icon-144x144.png
- apple-icon-152x152.png
- apple-icon-180x180.png
- apple-icon-precomposed.png
- apple-touch-icon.png
- apple-touch-icon-precomposed.png

### Android Icons (public/)
- android-icon-36x36.png
- android-icon-48x48.png
- android-icon-72x72.png
- android-icon-96x96.png
- android-icon-144x144.png
- android-icon-192x192.png

### Microsoft Icons (public/)
- ms-icon-70x70.png
- ms-icon-144x144.png
- ms-icon-150x150.png
- ms-icon-310x310.png

## CODE REFERENCES TO UPDATE

### Found in Code
1. `spec/mailboxes/reply_mailbox_spec.rb:627`
   - Reference to cloudfront.net Chatwoot brand SVG
   - Line: `[C](https://d33wubrfki0l68.cloudfront.net/...brand-73f58c...svg)`
   - Action: Remove or update test

2. Test files with mock URLs (chatwoot-assets.local)
   - These are fine - just mock URLs for tests
   - No action needed

## NEXT STEPS

1. **Get Willo Logo Files**
   - Need you to place 5 PNG files somewhere I can access them
   - Suggested: Create `/Users/kebing/chatwoot/willo-logos/` directory

2. **Delete Enterprise Directory**
   - Remove `./enterprise/`
   - Remove `./spec/enterprise/`
   - Remove enterprise references from code

3. **Delete Chatwoot Images**
   - Delete chatwoot_bot.png (2 locations)
   - Delete SVG logos

4. **Generate Favicon Sizes**
   - Use ImageMagick to generate all sizes from your Willo W icon
   - Sizes: 16x16, 32x32, 57x57, 60x60, 72x72, 76x76, 96x96, 114x114, 120x120, 144x144, 152x152, 180x180, 192x192, 512x512

5. **Update Code References**
   - Update spec/mailboxes/reply_mailbox_spec.rb
   - Search for any other hardcoded image paths

6. **Final Verification**
   - Search for "chatwoot" in image filenames
   - Search for external Chatwoot image URLs
   - Verify all images are Willo-branded

## READY TO EXECUTE

Waiting for:
1. Your 5 PNG logo files to be placed in accessible directory
2. Confirmation to proceed with enterprise directory deletion

Once ready, I'll:
1. Delete enterprise/ directory
2. Delete Chatwoot images
3. Generate all favicon sizes from your Willo logos
4. Replace all brand assets
5. Clean up code references
6. Commit clean Willo-only codebase
