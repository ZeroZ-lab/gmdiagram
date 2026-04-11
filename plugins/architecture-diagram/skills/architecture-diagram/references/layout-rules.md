# Layout Rules Reference

These rules compute SVG coordinates from the JSON schema. Follow them to position all elements deterministically — do NOT guess coordinates.

## Constants

| Name | Value | Purpose |
|------|-------|---------|
| `PAGE_MARGIN` | 40px | Space between SVG edge and first element |
| `LAYER_GAP` | 50px | Vertical gap between layer cards |
| `MODULE_GAP` | 20px | Horizontal gap between modules inside a layer |
| `MODULE_MIN_W` | 100px | Minimum module width |
| `MODULE_H` | 50px | Standard module height (no badges) |
| `MODULE_H_BADGE` | 65px | Module height with tech badges |
| `LAYER_PAD_H` | 16px | Layer card horizontal padding |
| `LAYER_PAD_TOP` | 35px | Layer card top padding (for label) |
| `LAYER_PAD_BOT` | 16px | Layer card bottom padding |
| `SVG_W` | 1000px | SVG viewBox width (fixed) |
| `LEGEND_OFFSET` | 50px | Space below last layer before legend |

## Step 1: Calculate Layer Dimensions

For each layer, calculate its content width and height:

```
layer_content_h = max(module_h for each module)   // tallest module
                  or MODULE_H if no children

layer_card_h = LAYER_PAD_TOP + layer_content_h + LAYER_PAD_BOT
```

For width, compute the total module row width:
```
total_modules_w = sum(module_w for each module) + MODULE_GAP * (num_modules - 1)
layer_card_w = max(total_modules_w + LAYER_PAD_H * 2, 300px)
```

Module width is determined by label length:
```
module_w = max(MODULE_MIN_W, label_length * 8 + 32)
```
- `label_length`: number of characters in the module label
- Multiply by 8 (approximate monospace char width at 12px)
- Add 32 for padding

If the layer has tech badges, use `MODULE_H_BADGE` instead of `MODULE_H`.

## Step 2: Position Layers Vertically

Stack layers top-to-bottom with gaps:

```
layer_y[0] = PAGE_MARGIN
layer_y[i] = layer_y[i-1] + layer_card_h[i-1] + LAYER_GAP
```

All layers are centered horizontally at the same x position:
```
layer_x = PAGE_MARGIN
layer_card_w = SVG_W - PAGE_MARGIN * 2   // all layers span full width
```

**Exception**: If layers have no children and few connections, reduce `layer_card_w` to the natural content width and center layers.

## Step 3: Position Modules Inside Layers

Modules are horizontally centered within their layer card.

```
total_modules_w = sum of all module widths + MODULE_GAP * gaps
start_x = layer_x + (layer_card_w - total_modules_w) / 2

module_x[0] = start_x
module_x[i] = module_x[i-1] + module_w[i-1] + MODULE_GAP
module_y = layer_y + LAYER_PAD_TOP + 8   // 8px below layer label
```

## Step 4: Compute Connection Paths

For each connection, draw a line from the source component to the target component.

### Source/Target Anchor Points

Each component has 4 anchor points:
```
top_center    = (x + w/2, y)
bottom_center = (x + w/2, y + h)
left_center   = (x, y + h/2)
right_center  = (x + w, y + h/2)
```

### Connection Routing Rules

1. **If source is above target**: Use `bottom_center` of source → `top_center` of target
2. **If source is below target**: Use `top_center` of source → `bottom_center` of target
3. **If source and target are in the same layer**: Use `right_center` of source → `left_center` of target

### Connection Label Position

```
label_x = (source_x + target_x) / 2
label_y = (source_y + target_y) / 2
```

Place a background rect behind the label text:
```
bg_rect_x = label_x - label_width/2 - 4
bg_rect_y = label_y - 10
bg_rect_w = label_width + 8
bg_rect_h = 16
```

## Step 5: Compute ViewBox

```
viewBox_h = max(layer_y + layer_card_h for all layers)  // bottom of last layer
            + LEGEND_OFFSET                               // gap before legend
            + 50                                          // legend height
            + 30                                          // bottom padding
```

```
viewBox = "0 0 SVG_W viewBox_h"
```

Default: `"0 0 1000 620"`. Adjust `viewBox_h` based on actual content.

## Step 6: Position Legend

```
legend_x = PAGE_MARGIN
legend_y = max(layer_y + layer_card_h for all layers) + LEGEND_OFFSET
```

Legend items are placed horizontally, 110px apart.

## Worked Example: Chrome Architecture

### Input (simplified)
- Layer 1: "Browser Process" → 3 modules (UI/Tabs, Network, Storage)
- Layer 2: "Renderer Process" → 3 modules (Blink, V8, DOM/CSS)  
- Layer 3: "GPU Process" → 1 module (OpenGL/Vulkan)
- Layer 4: "Utility Process" → 2 modules (Audio, Plugin)

### Calculation

**Layer 1:**
- Module widths: UI/Tabs=100, Network=100, Storage=100
- Total modules w: 100+100+100 + 20*2 = 340
- Layer card: w=920 (full width), h=35+50+16=101

**Layer 2 (with badges):**
- Module widths: Blink=100, V8=100, DOM/CSS=100
- Total modules w: 100+100+100 + 20*2 = 340
- Layer card: w=920, h=35+65+16=116
- Stacked effect: extra 3px offset for duplicate border

**Layer 3:**
- Module width: OpenGL/Vulkan=130
- Layer card: w=920, h=35+50+16=101

**Layer 4:**
- Module widths: Audio=100, Plugin/PPAPI=120
- Layer card: w=920, h=35+50+16=101

**Vertical positions:**
```
layer_y[0] = 30
layer_y[1] = 30 + 101 + 50 = 181
layer_y[2] = 181 + 116 + 50 = 347
layer_y[3] = 347 + 101 + 50 = 498
```

**viewBox:** `"0 0 1000 620"` (620 = 498 + 101 + 50 + 30)

## Edge Cases

### Multiple instances (`count: "multiple"`)
- Draw a second border rect offset by (+4, +3) with lower opacity
- This creates a stacked-card visual indicating multiplicity

### Single module, wide label
- Module width can exceed MODULE_MIN_W if the label is long
- Cap at layer_card_w - LAYER_PAD_H * 2 to prevent overflow

### Too many modules in one layer (>5)
- Reduce MODULE_GAP to 12px
- If still overflowing, reduce module widths proportionally

### No connections
- Skip Step 4 entirely, layout is just stacked layers

### Groups
- Draw boundary rect around the bounding box of all children
- Add 20px padding on each side
- Position label at top-left of the boundary
