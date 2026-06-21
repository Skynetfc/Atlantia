#!/usr/bin/env bash
# generate-remaining.sh
# Generates all remaining Atlantia brand assets that were not produced in the initial session
# due to the 10-image-per-session generation limit.
#
# HOW TO USE:
#   Run this in a fresh Replit Agent session with image generation available.
#   Each generateImage call is limited to 10 images; this script lists all remaining
#   prompts organized into batches of 10. Copy each batch's prompt block into a
#   code_execution call using generateImage({images:[...]}).
#
# COLOR PALETTE (from prompt7.md):
#   Navy (primary):    #1B2A4A
#   Amber (accent):    #D98E2B
#   Teal (QA/trust):   #2E6B6B
#   Brick red (risk):  #B23B3B
#   Off-white (bg):    #F4F1EC
#   Dark charcoal:     #1A1A1A  (dark mode bg)
#   Slate blue:        #7E8FB5  (dark mode navy replacement)

echo "=== REMAINING ATLANTIA ASSETS ==="
echo "Generated so far (10/10 from session 1):"
echo "  national-symbols/flag.png"
echo "  national-symbols/seal.png"
echo "  national-symbols/coat-of-arms.png"
echo "  national-symbols/nation-map.png"
echo "  civic-documents/constitution-header.png"
echo "  civic-documents/passport-cover.png"
echo "  civic-documents/naturalization-certificate.png"
echo "  national-symbols/prime-plaque.png"
echo "  atlantia-logo-v2.png"
echo "  atlantia-icon-v2.png"
echo ""
echo "=== BATCH 2: State Seals A (Forge → Compass) ==="
echo "  state-seals/forge-state.png"
echo "  state-seals/signal-state.png"
echo "  state-seals/exchange-state.png"
echo "  state-seals/ledger-state.png"
echo "  state-seals/atelier-state.png"
echo "  state-seals/cartography-state.png"
echo "  state-seals/proving-state.png"
echo "  state-seals/archive-state.png"
echo "  state-seals/arcade-state.png"
echo "  state-seals/compass-state.png"
echo ""
echo "=== BATCH 3: State Seals B + Judiciary + Currency ==="
echo "  state-seals/logistics-state.png"
echo "  state-seals/frontier-state.png"
echo "  state-seals/federal-district.png"
echo "  state-seals/census-state.png"
echo "  state-seals/judiciary-emblem.png"
echo "  currency/credit-coin.png"
echo "  currency/banknote-low.png"
echo "  currency/banknote-high.png"
echo "  stamps/standard-definitive.png"
echo "  stamps/audit-day.png"
echo ""
echo "=== BATCH 4: Stamps + Ceremonial + Badges ==="
echo "  stamps/founding-day.png"
echo "  ceremonial/founding-day-banner.png"
echo "  ceremonial/audit-day-poster.png"
echo "  badges/security-badge.png"
echo "  badges/eval-verified.png"
echo "  badges/known-limitation-flag.png"
echo "  badges/judiciary-badge.png"
echo ""
echo "=== BATCH 5: Division Icons A ==="
echo "  division-icons/engineering.png"
echo "  division-icons/marketing.png"
echo "  division-icons/sales.png"
echo "  division-icons/legal.png"
echo "  division-icons/finance.png"
echo "  division-icons/design.png"
echo "  division-icons/gis.png"
echo "  division-icons/quality.png"
echo "  division-icons/testing.png"
echo "  division-icons/academic.png"
echo ""
echo "=== BATCH 6: Division Icons B + Wordmark ==="
echo "  division-icons/game-development.png"
echo "  division-icons/product.png"
echo "  division-icons/project-management.png"
echo "  division-icons/spatial-computing.png"
echo "  division-icons/specialized.png"
echo "  atlantia-wordmark-v2.png"
echo "  atlantia-social-v2.png"
echo "  atlantia-banner-v2.png"
echo ""
echo "=== BATCH 7: Dark Mode Variants ==="
echo "  dark/flag-dark.png"
echo "  dark/seal-dark.png"
echo "  dark/logo-dark.png"
echo "  dark/icon-dark.png"
echo "  dark/banner-dark.png"
echo "  dark/wordmark-dark.png"
echo "  dark/judiciary-badge-dark.png"

cat << 'PROMPTS'

=== PASTE INTO code_execution BATCH 2 ===

const sealBase = "Small circular state seal of Atlantia. Warm off-white #F4F1EC interior. Thin deep navy #1B2A4A outer ring. Single centered icon in warm amber #D98E2B. Flat vector, no text, no gradient, minimalist, one coherent visual family.";

await generateImage({ images: [
  { prompt: sealBase + " Icon: gear interlocking with code bracket </>. Forge State (engineering).", outputPath: "atlantia/assets/state-seals/forge-state.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,photorealism" },
  { prompt: sealBase + " Icon: megaphone with small upward trend line. Signal State (marketing).", outputPath: "atlantia/assets/state-seals/signal-state.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,photorealism" },
  { prompt: sealBase + " Icon: two hands handshake silhouette. Exchange State (sales).", outputPath: "atlantia/assets/state-seals/exchange-state.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,photorealism,realistic" },
  { prompt: sealBase + " Icon: balanced scales of justice, two pans on a horizontal beam. Ledger State (legal/finance).", outputPath: "atlantia/assets/state-seals/ledger-state.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,photorealism" },
  { prompt: sealBase + " Icon: paintbrush crossing diagonally over a ruler. Atelier State (design).", outputPath: "atlantia/assets/state-seals/atelier-state.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,photorealism" },
  { prompt: sealBase + " Icon: teardrop map location pin above a grid of lines. Cartography State (GIS).", outputPath: "atlantia/assets/state-seals/cartography-state.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,photorealism" },
  { prompt: sealBase + " Icon: shield outline with checkmark inside. Proving State (testing).", outputPath: "atlantia/assets/state-seals/proving-state.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,photorealism" },
  { prompt: sealBase + " Icon: open book with two pages visible. Archive State (academic).", outputPath: "atlantia/assets/state-seals/archive-state.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,photorealism,writing" },
  { prompt: sealBase + " Icon: stylized arcade joystick outline with directional pad. Arcade State (game dev).", outputPath: "atlantia/assets/state-seals/arcade-state.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,photorealism" },
  { prompt: sealBase + " Icon: simple compass needle with N on thin circle. Compass State (product).", outputPath: "atlantia/assets/state-seals/compass-state.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,photorealism" }
]});

=== PASTE INTO code_execution BATCH 3 ===

const sealBase = "Small circular state seal of Atlantia. Warm off-white #F4F1EC interior. Thin deep navy #1B2A4A outer ring. Single centered icon in warm amber #D98E2B. Flat vector, no text, no gradient, minimalist.";

await generateImage({ images: [
  { prompt: sealBase + " Icon: horizontal stack of bars like a simplified Gantt chart. Logistics State (project management).", outputPath: "atlantia/assets/state-seals/logistics-state.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,photorealism" },
  { prompt: sealBase + " Icon: simplified 3D cube wireframe outline. Frontier State (spatial computing).", outputPath: "atlantia/assets/state-seals/frontier-state.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D shading,shadow,photorealism,filled cube" },
  { prompt: sealBase + " Icon: a small classical column (government building pillar). Federal District (specialized cross-cutting agents).", outputPath: "atlantia/assets/state-seals/federal-district.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,photorealism" },
  { prompt: sealBase + " Icon: simple bar chart with upward arrow above the tallest bar. Census State (data).", outputPath: "atlantia/assets/state-seals/census-state.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,photorealism" },
  { prompt: "Small circular emblem for Atlantia Judiciary. Muted teal #2E6B6B outer ring (NOT navy — judiciary is visually distinct from all state seals). Warm off-white #F4F1EC interior. Centered icon: magnifying glass over a checkmark, rendered in deep navy #1B2A4A (NOT amber — further distinguishing judiciary). Flat vector, minimalist, no text. Same size/proportions as the 16 state seals but with teal ring and navy icon to signal it belongs to the Judiciary, not a state.", outputPath: "atlantia/assets/state-seals/judiciary-emblem.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,photorealism,amber,amber color" },
  { prompt: "Flat vector circular coin face — the Atlantian Credit (₳). Deep navy #1B2A4A background. Centered currency symbol ₳ in warm amber #D98E2B, bold and clear. Thin muted teal #2E6B6B decorative ring near the coin's outer edge. Simple geometric notched coin-edge pattern. Minimalist, no portraits, no other text. Digital currency icon style.", outputPath: "atlantia/assets/currency/credit-coin.png", aspectRatio: "1:1", negativePrompt: "text other than currency symbol,portrait,face,gradient,3D,photorealistic coin" },
  { prompt: "Horizontal banknote design — low denomination Atlantian Credit. Warm off-white #F4F1EC background. Fine navy #1B2A4A guilloche-style geometric line border around all four edges (simple concentric geometric line patterns, not photorealistic security printing). Small compass-rose watermark-style emblem in pale amber centered-left third. Right third: clean blank rectangular panel reserved for denomination number. Flat vector illustration, restrained and modern. No portraits, no baked-in text beyond the watermark emblem.", outputPath: "atlantia/assets/currency/banknote-low.png", aspectRatio: "16:9", negativePrompt: "text,portraits,faces,photorealistic,complex,3D" },
  { prompt: "Horizontal banknote design — high denomination Atlantian Credit. Identical layout to low-denomination note but border linework in muted teal #2E6B6B instead of navy, to visually distinguish value tier. Warm off-white #F4F1EC background. Same compass-rose watermark centered-left. Same blank denomination panel on right third. Flat vector. No portraits, no text.", outputPath: "atlantia/assets/currency/banknote-high.png", aspectRatio: "16:9", negativePrompt: "text,portraits,faces,photorealistic,complex,3D" },
  { prompt: "Small rectangular postage stamp illustration — standard definitive stamp of Atlantia. Classic perforated scalloped die-cut border around all edges. Warm off-white #F4F1EC background inside the perforations. Small centered compass-rose icon in warm amber #D98E2B. Thin navy #1B2A4A frame line just inside the perforated edge. Flat vector, no text, minimalist. Looks like a real postage stamp.", outputPath: "atlantia/assets/stamps/standard-definitive.png", aspectRatio: "3:4", negativePrompt: "text,gradient,3D,photorealistic,complex" },
  { prompt: "Small rectangular postage stamp — Audit Day commemorative stamp of Atlantia. Same perforated-edge format as the standard definitive stamp. Warm off-white #F4F1EC background. Central icon: magnifying glass over a checkmark in muted teal #2E6B6B — referencing the Judiciary's weekly benchmark review. Same thin navy #1B2A4A frame line inside the perforations. Flat vector, no text.", outputPath: "atlantia/assets/stamps/audit-day.png", aspectRatio: "3:4", negativePrompt: "text,gradient,3D,photorealistic,complex" }
]});

=== PASTE INTO code_execution BATCH 4 ===

await generateImage({ images: [
  { prompt: "Small rectangular postage stamp — Founding Day commemorative stamp of Atlantia. Same perforated-edge format. Warm off-white #F4F1EC background. Central icon: the full Atlantia coat-of-arms compass rose rendered slightly larger than the standard stamp icon. Same color palette navy #1B2A4A amber #D98E2B. Flat vector, no text.", outputPath: "atlantia/assets/stamps/founding-day.png", aspectRatio: "3:4", negativePrompt: "text,gradient,3D,photorealistic" },
  { prompt: "Wide horizontal ceremonial Founding Day banner illustration for Atlantia. Deep navy #1B2A4A background. Large centered compass-rose emblem in warm amber #D98E2B. Thin muted teal #2E6B6B geometric rays radiating outward from the emblem — simple straight lines, not fireworks or ornate patterns. Generous blank space at the bottom third for text overlay. Flat vector, festive but restrained. No baked-in text.", outputPath: "atlantia/assets/ceremonial/founding-day-banner.png", aspectRatio: "16:9", negativePrompt: "text,photorealistic,gradient,fireworks,ornate,3D" },
  { prompt: "Vertical poster illustration for Audit Day in Atlantia. Warm off-white #F4F1EC background. Large magnifying glass over a checkmark icon in muted teal #2E6B6B as the dominant central visual. Thin navy #1B2A4A border frame. Blank space at top and bottom for headline and date text overlay. Flat vector, clean, formal and institutional in tone — this is an audit, not a party. No baked-in text.", outputPath: "atlantia/assets/ceremonial/audit-day-poster.png", aspectRatio: "9:16", negativePrompt: "text,photorealistic,gradient,festive,bright colors,3D" },
  { prompt: "Small shield-shaped security division badge for Atlantia. Deep navy #1B2A4A shield outline. Warm off-white #F4F1EC interior. Centered simple padlock icon in warm amber #D98E2B. Flat vector, minimalist, no text. Suitable for small inline badge in security documentation.", outputPath: "atlantia/assets/badges/security-badge.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,photorealism,complex" },
  { prompt: "Small circular Eval-Verified trust badge for Atlantia. Muted teal #2E6B6B outer ring. White interior. Simple checkmark icon centered in teal #2E6B6B. Flat vector design, quality-seal aesthetic, no text, no stars. 24x24px inline badge style — minimal and clean.", outputPath: "atlantia/assets/badges/eval-verified.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,photorealism,stars,complex" },
  { prompt: "Small flat vector warning flag icon for Known Limitations sections in Atlantia documentation. Brick red #B23B3B. Simple triangle outline with centered exclamation mark. No fill beyond the line color. Rounded corners on the triangle. Transparent background implied by white. Minimalist, consistent single line weight, 24x24px optimized.", outputPath: "atlantia/assets/badges/known-limitation-flag.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,fill,photorealism,complex" },
  { prompt: "Judicial division circular badge for Atlantia. Thin muted teal #2E6B6B outer ring. Warm off-white #F4F1EC interior. Centered scales of justice icon in deep navy #1B2A4A. Flat vector, no text. Ceremonial seal for the Judiciary division used in governance documentation.", outputPath: "atlantia/assets/badges/judiciary-badge.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,photorealism,amber color" }
]});

=== PASTE INTO code_execution BATCH 5 ===

const iconBase = "Single flat vector icon. Minimalist line-art style. Single consistent line weight. Deep navy #1B2A4A lines on transparent/white background. No fill except line color. Rounded line caps. Geometric and simplified, not detailed or realistic. Square 1:1 canvas. Professional icon set style similar to Lucide or Feather icons.";

await generateImage({ images: [
  { prompt: iconBase + " Icon subject: a gear wheel interlocking with a code bracket </>. Engineering division.", outputPath: "atlantia/assets/division-icons/engineering.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,fill,photorealism,multiple line weights" },
  { prompt: iconBase + " Icon subject: a megaphone with a small upward trend line. Marketing division.", outputPath: "atlantia/assets/division-icons/marketing.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,fill,photorealism" },
  { prompt: iconBase + " Icon subject: two hands in a handshake. Sales division.", outputPath: "atlantia/assets/division-icons/sales.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,fill,photorealism,realistic hands" },
  { prompt: iconBase + " Icon subject: classical balanced scales of justice. Legal division.", outputPath: "atlantia/assets/division-icons/legal.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,fill,photorealism" },
  { prompt: iconBase + " Icon subject: simple bar chart with upward arrow above it. Finance division.", outputPath: "atlantia/assets/division-icons/finance.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,fill,photorealism" },
  { prompt: iconBase + " Icon subject: paintbrush crossing over a ruler. Design division.", outputPath: "atlantia/assets/division-icons/design.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,fill,photorealism" },
  { prompt: iconBase + " Icon subject: map location pin on a grid background. GIS division.", outputPath: "atlantia/assets/division-icons/gis.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,fill,photorealism" },
  { prompt: "Single flat vector icon. Minimalist line-art style. Muted teal #2E6B6B lines on white background (NOT navy — quality/trust content uses teal). Icon subject: magnifying glass over a checkmark. Quality/QA division — teal color is intentional, signals trust content.", outputPath: "atlantia/assets/division-icons/quality.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,fill,photorealism,navy color" },
  { prompt: iconBase + " Icon subject: shield with checkmark inside. Testing division.", outputPath: "atlantia/assets/division-icons/testing.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,fill,photorealism" },
  { prompt: iconBase + " Icon subject: open book with two visible pages. Academic division.", outputPath: "atlantia/assets/division-icons/academic.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,fill,photorealism,writing on pages" }
]});

=== PASTE INTO code_execution BATCH 6 ===

const iconBase = "Single flat vector icon. Minimalist line-art. Single consistent line weight. Deep navy #1B2A4A lines on white. No fill. Rounded line caps. Geometric, simplified. Square 1:1. Professional icon-set style.";

await generateImage({ images: [
  { prompt: iconBase + " Icon: stylized arcade joystick with directional pad. Game development division.", outputPath: "atlantia/assets/division-icons/game-development.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,fill,photorealism" },
  { prompt: iconBase + " Icon: a roadmap path with milestone dots along it. Product management division.", outputPath: "atlantia/assets/division-icons/product.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,fill,photorealism" },
  { prompt: iconBase + " Icon: horizontal stack of Gantt-chart-style bars. Project management division.", outputPath: "atlantia/assets/division-icons/project-management.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,fill,photorealism" },
  { prompt: iconBase + " Icon: simplified 3D cube wireframe outline. Spatial computing division.", outputPath: "atlantia/assets/division-icons/spatial-computing.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D fill,shadow,photorealism" },
  { prompt: iconBase + " Icon: simple compass needle pointing north. Specialized/Federal District division.", outputPath: "atlantia/assets/division-icons/specialized.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,shadow,fill,photorealism" },
  { prompt: "Wide horizontal wordmark lockup for Atlantia. Left side: small simplified compass-rose icon in warm amber #D98E2B. Right side: the word ATLANTIA in bold geometric sans-serif capitals, deep navy #1B2A4A, wide letter spacing. Very small text below: 'Every specialist, mapped and spawnable.' in warm gray. Warm off-white #F4F1EC background. Flat vector, no gradients, no drop shadows, professional SaaS brand style.", outputPath: "atlantia/assets/atlantia-wordmark-v2.png", aspectRatio: "16:9", negativePrompt: "script fonts,3D text,neon,gradient,photorealistic,additional taglines beyond the one specified" },
  { prompt: "Dark mode version of Atlantia compass rose app icon. Rounded square. Deep charcoal #1A1A1A background. Centered compass rose in warm amber #D98E2B (unchanged). Four main cardinal points, bold and legible. Flat vector, no text, no gradient.", outputPath: "atlantia/assets/dark/icon-dark.png", aspectRatio: "1:1", negativePrompt: "text,gradient,3D,photorealism,complex" },
  { prompt: "Dark mode version of Atlantia national flag. Deep charcoal #1A1A1A background instead of navy. Compass-rose emblem in warm amber #D98E2B (unchanged). Thin off-white #F4F1EC horizontal band beneath the emblem. Flat vector, no gradients, no text. Dark-GitHub-theme-optimized version of the national flag.", outputPath: "atlantia/assets/dark/flag-dark.png", aspectRatio: "4:3", negativePrompt: "text,gradient,3D,photorealism,navy background" }
]});

PROMPTS
