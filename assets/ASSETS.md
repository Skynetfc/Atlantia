# Atlantia — Brand & National Asset Catalogue

Color palette (all assets use only these):

| Role | Hex | Use |
|---|---|---|
| Navy (primary) | `#1B2A4A` | Headers, borders, primary elements |
| Amber (accent) | `#D98E2B` | Compass rose, highlights, active state |
| Teal (QA/trust) | `#2E6B6B` | Judiciary, eval results, trust signals |
| Brick red (risk) | `#B23B3B` | Deprecation flags, known limitations |
| Off-white (bg) | `#F4F1EC` | Backgrounds, document bases |
| Charcoal (dark) | `#1A1A1A` | Dark-mode backgrounds |
| Slate blue (dark) | `#7E8FB5` | Dark-mode navy replacement |

---

## Session 1 — Generated ✅

| File | Asset |
|---|---|
| `national-symbols/flag.png` | National Flag |
| `national-symbols/seal.png` | National Seal |
| `national-symbols/coat-of-arms.png` | Coat of Arms |
| `national-symbols/nation-map.png` | Nation Map — 16 States |
| `national-symbols/prime-plaque.png` | Atlantia Prime Capital Plaque |
| `civic-documents/constitution-header.png` | Constitution Document Header |
| `civic-documents/passport-cover.png` | Agent Passport Cover |
| `civic-documents/naturalization-certificate.png` | Certificate of Naturalization |
| `atlantia-logo-v2.png` | Primary Logomark (8-point compass rose) |
| `atlantia-icon-v2.png` | App Icon / Favicon |

---

## Batch 2 — State Seals A ⏳

| File | State | Division |
|---|---|---|
| `state-seals/forge-state.png` | Forge State | engineering |
| `state-seals/signal-state.png` | Signal State | marketing |
| `state-seals/exchange-state.png` | Exchange State | sales |
| `state-seals/ledger-state.png` | Ledger State | legal + finance |
| `state-seals/atelier-state.png` | Atelier State | design |
| `state-seals/cartography-state.png` | Cartography State | gis |
| `state-seals/proving-state.png` | Proving State | testing |
| `state-seals/archive-state.png` | Archive State | academic |
| `state-seals/arcade-state.png` | Arcade State | game-development |
| `state-seals/compass-state.png` | Compass State | product |

## Batch 3 — State Seals B + Judiciary + Currency + Stamps ⏳

| File | Asset |
|---|---|
| `state-seals/logistics-state.png` | Logistics State (project-management) |
| `state-seals/frontier-state.png` | Frontier State (spatial-computing) |
| `state-seals/federal-district.png` | The Federal District (specialized) |
| `state-seals/census-state.png` | Census State (data) |
| `state-seals/judiciary-emblem.png` | Judiciary Emblem (teal ring, navy icon — NOT a state) |
| `currency/credit-coin.png` | Atlantian Credit Coin (₳) |
| `currency/banknote-low.png` | Banknote — Low Denomination (navy border) |
| `currency/banknote-high.png` | Banknote — High Denomination (teal border) |
| `stamps/standard-definitive.png` | Standard Definitive Stamp |
| `stamps/audit-day.png` | Audit Day Commemorative Stamp |

## Batch 4 — Stamps + Ceremonial + Badges ⏳

| File | Asset |
|---|---|
| `stamps/founding-day.png` | Founding Day Commemorative Stamp |
| `ceremonial/founding-day-banner.png` | Founding Day Banner |
| `ceremonial/audit-day-poster.png` | Audit Day Poster |
| `badges/security-badge.png` | Security Division Badge |
| `badges/eval-verified.png` | Eval-Verified Trust Badge (teal) |
| `badges/known-limitation-flag.png` | Known Limitation Flag (red) |
| `badges/judiciary-badge.png` | Judiciary Badge (scales of justice) |

## Batch 5 — Division Icons A ⏳

| File | Division |
|---|---|
| `division-icons/engineering.png` | Gear + code bracket |
| `division-icons/marketing.png` | Megaphone + trend line |
| `division-icons/sales.png` | Handshake |
| `division-icons/legal.png` | Scales of justice |
| `division-icons/finance.png` | Bar chart + arrow |
| `division-icons/design.png` | Paintbrush + ruler |
| `division-icons/gis.png` | Map pin + grid |
| `division-icons/quality.png` | Magnifying glass + checkmark (teal) |
| `division-icons/testing.png` | Shield + checkmark |
| `division-icons/academic.png` | Open book |

## Batch 6 — Division Icons B + Dark Variants ⏳

| File | Division / Asset |
|---|---|
| `division-icons/game-development.png` | Joystick |
| `division-icons/product.png` | Roadmap path |
| `division-icons/project-management.png` | Gantt bars |
| `division-icons/spatial-computing.png` | 3D cube wireframe |
| `division-icons/specialized.png` | Compass needle |
| `atlantia-wordmark-v2.png` | Wordmark horizontal lockup |
| `dark/icon-dark.png` | App icon — dark mode |
| `dark/flag-dark.png` | National flag — dark mode |

---

## National Anthem

See `ANTHEM.md` — original text, three verses, free to use (MIT).

*Motto: "Mapped, not memorized."*  
*Currency: The Atlantian Credit (₳)*  
*Capital: Atlantia Prime*

---

## Generation Instructions

To generate the remaining batches, run `bash assets/generate-remaining.sh` and paste
each labeled batch block into a fresh Replit Agent code_execution call using `generateImage({images:[...]})`.
Each session allows 10 images maximum.
