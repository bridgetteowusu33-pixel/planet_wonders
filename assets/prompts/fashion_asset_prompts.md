# Fashion Asset Generation Prompts — Paper-Doll System

## Golden Rule
> Never draw clothes ON a body. Always draw clothes FOR a body.
> If the artist sees skin while drawing clothes — it's wrong.

---

## Architecture

```
Stack(
  body.png,        // immutable anchor
  bottoms.png,     // waist-down fabric only
  tops.png,        // torso fabric only
  dress.png,       // replaces tops + bottoms
  outerwear.png,   // hoodie, jacket — sits ABOVE tops
  hats.png,        // head only
)
```

---

## Global Rules (apply to ALL prompts below)

- Output format: PNG, fully transparent background
- Canvas size: **1024 x 1536 px** (2:3 ratio) — same for body AND all clothing
- Orientation: front-facing, standing pose
- Alignment: centered on canvas, **pixel-aligned** to the body (no shifts, no scaling)
- Style: soft 2D / semi-3D cartoon, smooth shading, rounded edges, child-friendly
- No shadows outside the fabric
- No text, no watermarks

### Clothing-Specific Rules
- **NO skin, NO face, NO hair, NO arms, NO legs, NO neck, NO shoulders, NO torso**
- **NO mannequins, NO inner shirts, NO body illusion, NO background color**
- **ONLY clothing fabric** — transparent cut-outs where skin would show
- Open necklines, armholes, waist openings
- Think **paper-doll cut-out**, not a dressed character

---

## PROMPT 1: Ava — Base Body

> **This is the immutable anchor. Never change proportions after finalizing.**

```
A cute cartoon girl character, age 7-8, standing in a relaxed front-facing pose
with arms slightly away from her body. She has warm brown skin, big expressive
brown eyes, and long wavy brown hair.

She wears ONLY simple neutral underwear/base clothing (plain light tank top and
plain light shorts) — modest, no logos, no patterns. Bare feet.

Full body visible from head to toes. Centered on a 1024x1536 transparent PNG
canvas. Soft 2D/semi-3D cartoon style with smooth shading and rounded features.
Bright, cheerful expression. No background. No text.

This character will be used as the BASE LAYER in a paper-doll dress-up system.
All clothing will be overlaid on top of this exact pose and proportions.
```

---

## PROMPT 2: Summer Dress

```
A child's casual summer dress, drawn as a flat transparent clothing cut-out for
a paper-doll system. The dress is light sky blue with small white polka dots.

The dress includes:
- Round neckline opening (transparent hole — no neck or skin visible)
- Short puffy sleeves that end at the shoulder seam
- A-line skirt falling to just above the knees
- Soft fabric folds and gentle shading

The dress must NOT include:
- Any body parts (no skin, no arms, no shoulders, no neck)
- Any inner shirt or layering illusion
- Any mannequin shape

Positioned on a 1024x1536 transparent PNG canvas, centered and aligned to fit
a front-facing cartoon child character (age 7-8) standing with arms slightly
away from the body. The dress occupies roughly the torso-to-knees area of the
canvas, with everything else transparent.

Soft 2D/semi-3D cartoon style, smooth shading, rounded edges. No background.
No text.
```

---

## PROMPT 3: 4th of July Dress

```
A child's patriotic 4th of July dress, drawn as a flat transparent clothing
cut-out for a paper-doll system. Red, white, and blue color scheme with small
stars and stripes pattern.

The dress includes:
- Sweetheart or round neckline opening (transparent hole)
- Thin shoulder straps (no sleeves)
- Fitted bodice in navy blue with white stars
- Flared skirt in red and white stripes, falling to just above the knees
- A small red ribbon bow at the waist

The dress must NOT include any body parts, skin, mannequin shape, or background.
Just the fabric shell with transparent cut-outs for neck, arms, and below the hem.

Positioned on a 1024x1536 transparent PNG canvas, centered and aligned to fit
a front-facing cartoon child character (age 7-8). The dress occupies the
torso-to-knees area of the canvas.

Soft 2D/semi-3D cartoon style, smooth shading. No background. No text.
```

---

## PROMPT 4: Hoodie

```
A child's casual hoodie (no inner shirt), drawn as a flat transparent clothing
cut-out for a paper-doll system. Solid color (e.g., light blue).

The hoodie includes:
- Hood resting flat behind the neckline
- Open neck hole (transparent cut-out where the neck would be)
- Long sleeves ending at the wrists
- Ribbed cuffs and hem
- Two front pockets

The hoodie must NOT include:
- Any body parts (no neck, no torso shape, no arms inside sleeves)
- Any inner shirt visible anywhere
- Any mannequin or body volume

The sleeve interiors are transparent. The bottom hem is an open transparent edge.
ONLY the hoodie fabric is visible (paper-doll cut-out).

Positioned on a 1024x1536 transparent PNG canvas, centered and aligned to fit
a front-facing cartoon child character (age 7-8) standing with arms slightly
away from the body. The hoodie occupies the shoulder-to-hip area of the canvas.

Soft 2D/semi-3D cartoon style, smooth shading. No background. No text.
```

---

## PROMPT 5: Jeans (Shorts)

```
A pair of child's denim jean shorts, drawn as a flat transparent clothing
cut-out for a paper-doll system. Classic blue denim wash with visible stitching,
a small button at the waist, and rolled-up cuffs at the hem.

The jeans include:
- Waistband with belt loops and a single button
- Two front pockets with visible pocket edges
- Short legs ending mid-thigh with rolled cuffs
- Realistic denim texture with faded wash

The jeans must NOT include:
- Any body parts (no hips, no torso, no legs inside)
- Any hip/torso volume or mannequin form
- Any torso height above the waistband

The waist opening is a transparent hole at the top. The leg openings are
transparent at the bottom. ONLY the denim fabric shell is visible.

Positioned on a 1024x1536 transparent PNG canvas, centered and aligned to fit
a front-facing cartoon child character (age 7-8). The jeans occupy ONLY the
waist-to-mid-thigh area of the canvas — everything above and below is transparent.

Soft 2D/semi-3D cartoon style, smooth shading. No background. No text.
```

---

## PROMPT 6: Baseball Cap

```
A child's baseball cap, drawn as a flat transparent clothing cut-out for a
paper-doll system. Solid color (e.g., red). No logos, no text, no patches.

The cap includes:
- Rounded crown with six panels and a top button
- Curved brim/visor
- Adjustable strap visible at the back

The cap must NOT include:
- Any head shape, hair, face, or ears
- Any mannequin or stand

The interior of the cap is a transparent hole (where the head would go).
ONLY the fabric/material of the cap is visible.

Positioned on a 1024x1536 transparent PNG canvas, centered and aligned to sit
on top of a front-facing cartoon child character's head (age 7-8). The cap
occupies ONLY the top portion of the canvas (roughly the top 15%) — everything
below is transparent.

Soft 2D/semi-3D cartoon style, smooth shading. No background. No text.
```

---

## Asset File Structure

```
assets/
  characters/
    Ava/
      Ava.PNG              ← base body (Prompt 1)
  clothes/
    USA/
      dresses/
        summer_dress.PNG   ← Prompt 2
        july_4_dress.PNG   ← Prompt 3
      tops/
        hoodie.PNG         ← Prompt 4
      bottoms/
        jeans.PNG          ← Prompt 5
      hats/
        baseball_cap.PNG   ← Prompt 6
```

---

---

# GHANA — Afia

## PROMPT G1: Afia — Base Body

> **This is the immutable anchor for Ghana. Never change proportions after finalizing.**

```
A cute cartoon girl character, age 7-8, standing in a relaxed front-facing pose
with arms slightly away from her body. She has rich dark brown skin, big
expressive dark brown eyes, and black hair styled in two afro puffs with
colorful beads on the hair ties.

She wears ONLY simple neutral underwear/base clothing (plain light tank top and
plain light shorts) — modest, no logos, no patterns. Bare feet.

Full body visible from head to toes. Centered on a 1024x1536 transparent PNG
canvas. Soft 2D/semi-3D cartoon style with smooth shading and rounded features.
Bright, cheerful expression. No background. No text.

This character will be used as the BASE LAYER in a paper-doll dress-up system.
All clothing will be overlaid on top of this exact pose and proportions.
```

---

## PROMPT G2: Kente Dress

```
A child's traditional Ghanaian kente cloth dress, drawn as a flat transparent
clothing cut-out for a paper-doll system. The dress features vibrant kente
weave patterns in gold, green, red, and black geometric strips.

The dress includes:
- Round neckline opening (transparent hole — no neck or skin visible)
- Short puffed sleeves with kente fabric
- Fitted bodice with kente strip pattern
- Flared A-line skirt falling to just below the knees
- Bright gold and green dominant color scheme with red accents

The dress must NOT include any body parts, skin, mannequin shape, or background.
Just the fabric shell with transparent cut-outs for neck, arms, and below the hem.

Positioned on a 1024x1536 transparent PNG canvas, centered and aligned to fit
a front-facing cartoon child character (age 7-8). The dress occupies the
torso-to-knees area of the canvas.

Soft 2D/semi-3D cartoon style, smooth shading. No background. No text.
```

---

## PROMPT G3: Ankara Print Dress

```
A child's colorful Ankara wax-print dress, drawn as a flat transparent clothing
cut-out for a paper-doll system. Bold African wax print pattern in orange, blue,
and yellow with circular and floral motifs.

The dress includes:
- Off-shoulder neckline with small ruffle trim (transparent hole for neck)
- Flutter sleeves
- Fitted waist with a fabric sash/bow at the back
- Full circle skirt falling to knee length
- Vibrant, saturated Ankara print covering the entire dress

The dress must NOT include any body parts, skin, mannequin shape, or background.

Positioned on a 1024x1536 transparent PNG canvas, centered and aligned to fit
a front-facing cartoon child character (age 7-8).

Soft 2D/semi-3D cartoon style, smooth shading. No background. No text.
```

---

## PROMPT G4: Kente Top

```
A child's kente-style blouse/top, drawn as a flat transparent clothing cut-out
for a paper-doll system. Traditional kente weave pattern in gold and green
with geometric strip design.

The top includes:
- Round neckline opening (transparent hole)
- Short sleeves ending at the shoulder seam
- Kente strip pattern running horizontally across the chest
- Hem falls at the waist level
- Gold fringe trim at the hem

The top must NOT include any body parts, skin, or mannequin shape.
Only the fabric is visible — transparent at neckline, armholes, and below hem.

Positioned on a 1024x1536 transparent PNG canvas, centered and aligned to fit
a front-facing cartoon child character (age 7-8). The top occupies the
shoulder-to-waist area of the canvas.

Soft 2D/semi-3D cartoon style, smooth shading. No background. No text.
```

---

## PROMPT G5: Ankara Print Top

```
A child's Ankara wax-print blouse, drawn as a flat transparent clothing cut-out
for a paper-doll system. Bold African print pattern in warm red, orange, and
yellow with traditional motifs.

The top includes:
- V-neckline opening (transparent hole)
- Cap sleeves with peplum detail
- Fitted bodice
- Peplum flare at the waist
- Bright, vibrant Ankara pattern

The top must NOT include any body parts, skin, or mannequin shape.

Positioned on a 1024x1536 transparent PNG canvas, centered and aligned to fit
a front-facing cartoon child character (age 7-8). The top occupies the
shoulder-to-waist area of the canvas.

Soft 2D/semi-3D cartoon style, smooth shading. No background. No text.
```

---

## PROMPT G6: Kente Wrap Skirt

```
A child's kente-style wrap skirt, drawn as a flat transparent clothing cut-out
for a paper-doll system. Traditional kente weave in gold, green, and red strips.

The skirt includes:
- High waistband with a wrap-style front overlap
- Kente pattern strips running vertically
- Skirt length falls to just below the knees
- Soft drape with visible fabric folds

The skirt must NOT include any body parts, hips, or mannequin shape.
The waist opening is transparent at the top, leg openings transparent at bottom.

Positioned on a 1024x1536 transparent PNG canvas, centered and aligned to fit
a front-facing cartoon child character (age 7-8). The skirt occupies ONLY the
waist-to-below-knee area of the canvas.

Soft 2D/semi-3D cartoon style, smooth shading. No background. No text.
```

---

## PROMPT G7: Ankara Shorts

```
A pair of child's Ankara wax-print shorts, drawn as a flat transparent clothing
cut-out for a paper-doll system. Bold African print in blue, yellow, and white
with traditional circular motifs.

The shorts include:
- Elastic waistband with drawstring
- Relaxed fit, ending mid-thigh
- Vibrant Ankara pattern covering the entire shorts
- Soft fabric folds

The shorts must NOT include any body parts, hips, or mannequin shape.
Waist and leg openings are transparent.

Positioned on a 1024x1536 transparent PNG canvas, centered and aligned to fit
a front-facing cartoon child character (age 7-8). The shorts occupy ONLY the
waist-to-mid-thigh area of the canvas.

Soft 2D/semi-3D cartoon style, smooth shading. No background. No text.
```

---

## PROMPT G8: Kufi Hat

```
A child's traditional Ghanaian kufi hat, drawn as a flat transparent clothing
cut-out for a paper-doll system. Embroidered cylindrical cap in gold and green
with kente-inspired geometric patterns.

The hat includes:
- Flat-topped cylindrical shape
- Rich gold base fabric with green and red embroidered patterns
- Slightly textured surface

The hat must NOT include any head shape, hair, face, or ears.
The interior is a transparent hole where the head would go.

Positioned on a 1024x1536 transparent PNG canvas, centered and aligned to sit
on top of a front-facing cartoon child character's head (age 7-8). The hat
occupies ONLY the top portion of the canvas — everything below is transparent.

Soft 2D/semi-3D cartoon style, smooth shading. No background. No text.
```

---

## PROMPT G9: Head Wrap

```
A child's colorful Ghanaian-style head wrap, drawn as a flat transparent
clothing cut-out for a paper-doll system. Ankara wax-print fabric in vibrant
orange, purple, and gold, tied in a high wrap style.

The head wrap includes:
- Fabric wrapped around the head with a tall front bow/knot
- Ankara pattern visible across the wrap
- Soft fabric folds and draping
- Extends slightly above and to the sides of the head

The head wrap must NOT include any head shape, hair, face, or ears.
The interior is transparent.

Positioned on a 1024x1536 transparent PNG canvas, centered and aligned to sit
on a front-facing cartoon child character's head (age 7-8). The wrap occupies
the top portion of the canvas.

Soft 2D/semi-3D cartoon style, smooth shading. No background. No text.
```

---

## PROMPT G10: Waist Beads

```
A set of colorful Ghanaian waist beads, drawn as a flat transparent clothing
cut-out for a paper-doll system. Multiple strands of small beads in gold, red,
blue, and green.

The beads include:
- 3-4 strands of small round beads
- Each strand a different color combination
- Draped around the waist/hip area
- Slight sway and natural drape

The beads must NOT include any body parts, skin, or mannequin shape.
Only the bead strands are visible — everything else is transparent.

Positioned on a 1024x1536 transparent PNG canvas, centered and aligned to sit
at the waist area of a front-facing cartoon child character (age 7-8).

Soft 2D/semi-3D cartoon style, smooth shading. No background. No text.
```

---

## PROMPT G11: Ahenema Sandals

```
A pair of traditional Ghanaian Ahenema sandals, drawn as a flat transparent
clothing cut-out for a paper-doll system. Gold-colored royal sandals with
decorative embossed patterns.

The sandals include:
- Flat sole with slight platform
- Gold-colored leather straps across the foot
- Decorative embossed patterns on the straps
- Traditional Ghanaian royal sandal style

The sandals must NOT include any feet, toes, or body parts.
Only the sandal material is visible — transparent everywhere else.

Positioned on a 1024x1536 transparent PNG canvas, centered and aligned to sit
at the feet area of a front-facing cartoon child character (age 7-8). The
sandals occupy ONLY the very bottom portion of the canvas.

Soft 2D/semi-3D cartoon style, smooth shading. No background. No text.
```

---

## Ghana Asset File Structure

```
assets/
  characters/
    Afia/
      Afia.PNG               ← base body (Prompt G1)
  clothes/
    Ghana/
      dresses/
        kente_dress.PNG      ← Prompt G2
        ankara_dress.PNG     ← Prompt G3
      tops/
        kente_top.PNG        ← Prompt G4
        ankara_top.PNG       ← Prompt G5
      bottoms/
        kente_skirt.PNG      ← Prompt G6
        ankara_shorts.PNG    ← Prompt G7
      hats/
        kufi_hat.PNG         ← Prompt G8
        head_wrap.PNG        ← Prompt G9
      beads/
        waist_beads.PNG      ← Prompt G10
      shoes/
        ahenema_sandals.PNG  ← Prompt G11
```

---

## Verification Checklist

After generating each asset:

1. Open in an image editor with transparent checkerboard background
2. Verify canvas is exactly 1024 x 1536
3. Verify NO skin, body parts, or background visible
4. Layer on top of Ava body — clothing should align perfectly with NO scaling
5. Check that transparent holes exist at neckline, armholes, waist, leg openings
6. Verify the clothing "wraps" the body area without including body volume
