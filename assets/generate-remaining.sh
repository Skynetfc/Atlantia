#!/usr/bin/env bash
# generate-remaining.sh
# Fixes remaining Atlantia brand assets that still have baked-in hex color codes
# (e.g. "#1B2A4A") rendered as literal text inside the image — an AI-generation
# artifact from earlier sessions. 10 of 17 affected assets (all state seals) were
# already fixed. These 7 remain, blocked on the 10-image-per-session generation limit.
#
# HOW TO USE:
#   Run this in a fresh Replit Agent session with image generation available.
#   Paste the block below into a code_execution call using generateImage({images:[...]}).
#
# COLOR PALETTE:
#   Navy (primary):    #1B2A4A
#   Amber (accent):    #D98E2B
#   Teal (QA/trust):   #2E6B6B
#   Off-white (bg):    #F4F1EC

echo "=== REMAINING: 7 assets still have baked-in hex codes ==="
echo "  national-symbols/flag.png"
echo "  national-symbols/seal.png"
echo "  national-symbols/prime-plaque.png"
echo "  civic-documents/constitution-header.png"
echo "  civic-documents/passport-cover.png"
echo "  civic-documents/naturalization-certificate.png"
echo "  atlantia-icon-v2.png"
echo ""
echo "Already fixed (no hex codes, correct spelling):"
echo "  state-seals/arcade-state.png, archive-state.png, atelier-state.png,"
echo "  state-seals/cartography-state.png, compass-state.png, exchange-state.png,"
echo "  state-seals/forge-state.png, ledger-state.png, proving-state.png, signal-state.png"

cat << 'PROMPTS'

=== PASTE INTO code_execution ===

await generateImage({ images: [
  { prompt: "National flag for a fictional nation called Atlantia. Solid navy blue (#1B2A4A) upper field taking about 85% of the height, centered orange (#D98E2B) compass rose/star emblem surrounded by 8 small orange line-art icons in a ring (gear, megaphone, handshake, rubber stamp, open book, shield, map pin, scale of justice), a thin orange horizontal stripe near the bottom, and a cream (#F4F1EC) stripe at the very bottom edge. Clean flat vector flag design, no text anywhere on the flag, no color codes, no hex codes, no watermark.", outputPath: "atlantia/assets/national-symbols/flag.png", aspectRatio: "4:3", negativePrompt: "hex codes, color codes, text, swatches, color labels, watermark, photorealism, gradients" },
  { prompt: "National seal for a fictional nation called Atlantia. Circular seal, outer navy blue (#1B2A4A) ring with the word 'ATLANTIA' curved along the top in cream serif caps letters, a teal (#2E6B6B) inner ring, cream (#F4F1EC) center field with an orange (#D98E2B) compass star in the middle, surrounded by 8 small navy line-art icons each with a correctly spelled navy caps label beneath it: MARKETING (megaphone), LEGAL (scale), DESIGN (paintbrush), ACCOUNTS (handshake), GIS (map pin), ACADEMIC (open book), SECURITY (shield). No color codes, no hex codes anywhere, no watermark.", outputPath: "atlantia/assets/national-symbols/seal.png", aspectRatio: "1:1", negativePrompt: "hex codes, color codes, swatches, color labels, watermark, photorealism, gradients, misspelled words" },
  { prompt: "A dark navy blue (#1B2A4A) rectangular commemorative plaque with a thin teal (#2E6B6B) inner border and small rivets at the corners. Centered orange (#D98E2B) text at the top reading 'Atlantia Prime', below it a circular orange compass rose icon, a horizontal teal divider line beneath, and empty blank space at the bottom for an inscription. No color codes, no hex codes, no extra text, no watermark.", outputPath: "atlantia/assets/national-symbols/prime-plaque.png", aspectRatio: "4:3", negativePrompt: "hex codes, color codes, swatches, color labels, extra text, watermark, photorealism, gradients" },
  { prompt: "Decorative document header on cream/parchment (#F4F1EC) background. Ornate thin navy blue (#1B2A4A) corner brackets in all four corners. Centered orange (#D98E2B) compass rose emblem near the top, below it elegant navy blue serif text reading 'THE CONSTITUTION' on one line and 'OF ATLANTIA' on the next, then a bold navy horizontal divider bar beneath the text, with plenty of empty blank cream space below for body text. No color codes, no hex codes, no other text, no watermark.", outputPath: "atlantia/assets/civic-documents/constitution-header.png", aspectRatio: "3:4", negativePrompt: "hex codes, color codes, swatches, color labels, extra text, watermark, photorealism, gradients" },
  { prompt: "Passport cover design, vertical portrait orientation. Solid navy blue (#1B2A4A) cover with a thin gold/cream border trim along the right edge, centered gold/orange (#D98E2B) foil-stamped compass rose emblem with concentric radiating circles around it in the middle of the cover. No text anywhere, no color codes, no hex codes, no watermark, clean minimal official passport aesthetic.", outputPath: "atlantia/assets/civic-documents/passport-cover.png", aspectRatio: "3:4", negativePrompt: "hex codes, color codes, swatches, color labels, text, watermark, photorealism, gradients" },
  { prompt: "Certificate of Naturalization document design on cream/parchment (#F4F1EC) background, landscape orientation. Ornate navy blue (#1B2A4A) double-line decorative border with scroll flourishes in all four corners. Small orange (#D98E2B) compass rose emblem centered at the top, below it bold navy text 'ATLANTIA' and beneath that bold navy text 'CERTIFICATE OF NATURALIZATION'. Two horizontal blank signature lines in the middle for a name and date. An orange wax-seal circle icon centered at the bottom. No color codes, no hex codes, no other text anywhere, no watermark.", outputPath: "atlantia/assets/civic-documents/naturalization-certificate.png", aspectRatio: "4:3", negativePrompt: "hex codes, color codes, swatches, color labels, extra text, watermark, photorealism, gradients" },
  { prompt: "App icon design: a rounded-square navy blue (#1B2A4A) background tile, centered large orange (#D98E2B) compass rose with N, E, S, W letters at each point in orange. No other text anywhere on the icon, no color codes, no hex codes, no watermark. Clean flat vector icon style.", outputPath: "atlantia/assets/atlantia-icon-v2.png", aspectRatio: "1:1", negativePrompt: "hex codes, color codes, swatches, color labels, extra text, watermark, photorealism, gradients" }
]});

PROMPTS
