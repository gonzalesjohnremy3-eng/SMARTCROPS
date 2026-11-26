# Free overlay prompts (ChatGPT / Gemini free tier)

Generate, download, and save to `assets/images/overlays/` using the filenames below. No `belt` account or credits required.

Export settings: JPEG quality 80 or WebP, long edge ≤1600px. Heroes are 16:9; detail surfaces are 4:3. Prefers calm compositions with clear negative space for text — the app adds its own Forest gradient scrim.

Append this suffix to every prompt:

> Photorealistic, soft natural light, muted natural colour grade, gentle depth of field, no people, no text, no logos, no watermark.

| File | Prompt |
| --- | --- |
| `onboarding.webp` | Wide cinematic photograph of a Philippine rice field at dawn, soft mist over terraced paddies, distant mountains, pale-green and deep-forest tones, warm low sunlight, generous calm empty sky in the upper half for text. 16:9. |
| `home.webp` | Photograph of healthy young rice seedlings in a muddy paddy after light rain, visible water droplets, soft overcast daylight, deep green and muted blue-grey palette, gentle background bokeh, clear negative space in the lower third. 16:9. |
| `scan.webp` | Macro photograph of a single rice leaf with subtle early leaf-spot discoloration, early-morning soft light, very shallow depth of field, dark natural green background, sharp focus on the leaf centre. 16:9. |
| `crop_detail.webp` | Photograph of a healthy pechay plant in a small Philippine backyard garden, loose soil, morning light, green and earth tones, clean simple composition with room for a caption. 4:3. |
| `product.webp` | Clean product-style photograph of a simple farm-input bottle and a small tin on a wooden farm table, soft natural daylight, muted green backdrop, minimal uncluttered composition with no readable labels. 4:3. |
| `pro.webp` | Premium cinematic photograph of a lush Philippine farm at golden hour, layered rice terraces and soft haze, deep green with warm highlights, calm and aspirational, generous negative space in the lower third for text. 16:9. |

Alternative with zero generation: keep the current procedural gradient + Forest scrim (`OverlayHero` already does this); no external images needed. A third free option is freely licensed photos from Wikimedia Commons, but each needs its license and author recorded in `PROJECT_KNOWLEDGE/ASSETS.md`.

After the files are in `assets/images/overlays/`, tell me and I'll wire them in and run the tests.
