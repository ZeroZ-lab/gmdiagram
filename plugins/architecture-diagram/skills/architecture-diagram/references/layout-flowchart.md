# Flowchart Layout Rules Reference

These rules compute SVG coordinates from the flowchart JSON schema. Follow them to position all elements deterministically — do NOT guess coordinates.

## Constants

| Name | Value | Purpose |
|------|-------|---------|
| `PAGE_MARGIN` | 40px | Space between SVG edge and first element |
| `NODE_GAP_V` | 60px | Vertical gap between stacked nodes |
| `NODE_GAP_H` | 40px | Horizontal gap for side-by-side branching |
| `DIAMOND_W` | 140px | Decision diamond width |
| `DIAMOND_H` | 90px | Decision diamond height |
| `TERMINAL_RX` | 20px | Corner radius for start/end nodes |
| `PROCESS_RX` | 4px | Corner radius for process nodes |
| `SVG_W` | 1000px | SVG viewBox width (fixed) |
| `IO_SKEW` | 12px | Horizontal skew offset for parallelogram |
| `SUBPROCESS_INSET` | 3px | Inner rect inset for subprocess double border |
| `LEGEND_OFFSET` | 50px | Space below last node before legend |
| `BRANCH_LABEL_OFFSET` | 8px | Offset of Yes/No label from decision edge |

## Step 1: Calculate Node Dimensions

Each node type has different dimension rules:

### Start / End terminals
```
node_w = max(100, label_length * 8 + 32)
node_h = 40
rx = TERMINAL_RX   // creates stadium/rounded pill shape
```

### Process nodes
```
node_w = max(120, label_length * 8 + 32)
node_h = max(40, description_lines * 14 + 28)
rx = PROCESS_RX
```

### Decision nodes (diamond)
```
node_w = max(DIAMOND_W, label_length * 7 + 40)
node_h = max(DIAMOND_H, node_w * 0.65)
// Adjust so text fits inside the diamond
// Diamond is drawn as a polygon centered at (cx, cy)
```

### I/O nodes (parallelogram)
```
node_w = max(120, label_length * 8 + 32 + IO_SKEW * 2)
node_h = 40
// Drawn as polygon with skew on left and right edges
```

### Subprocess nodes (double-border rect)
```
node_w = max(120, label_length * 8 + 32)
node_h = max(40, description_lines * 14 + 28)
rx = PROCESS_RX
// Draw outer rect + inner rect inset by SUBPROCESS_INSET
```

### Document nodes (wavy bottom)
```
node_w = max(120, label_length * 8 + 32)
node_h = max(45, description_lines * 14 + 28)
// Bottom edge is a sinusoidal wave path instead of straight line
```

## Step 2: Determine Flow Columns

The primary flow direction is **top-to-bottom** (vertical). Decision nodes create branching:

1. Start with the `start` node at the center column
2. Follow connections direction=down to stack nodes vertically
3. When a decision branches:
   - **"yes" branch**: continues down in the same column
   - **"no" branch**: goes right to a new column
4. Loop-back connections route along the right side of the diagram

Column positions:
```
main_column_x = SVG_W / 2   // center the main flow
branch_column_x[i] = main_column_x + (i * (DIAMOND_W + NODE_GAP_H))
```

If the flow branches left, use:
```
left_branch_x = main_column_x - (DIAMOND_W + NODE_GAP_H)
```

## Step 3: Position Nodes Vertically

Stack nodes top-to-bottom within each column:

```
node_y[0] = PAGE_MARGIN
node_y[i] = node_y[i-1] + node_h[i-1] + NODE_GAP_V
```

For nodes that merge back into the main flow (after a branch), their y-position is:
```
merge_y = max(main_flow_next_y, branch_flow_bottom_y) + NODE_GAP_V
```

### Decision node center offset

Decision diamonds are centered on their connection points:
```
diamond_cx = column_x
diamond_cy = node_y + DIAMOND_H / 2
```

The next node after a decision is positioned:
```
next_y = diamond_cy + DIAMOND_H / 2 + NODE_GAP_V
```

## Step 4: Position Nodes Horizontally

All nodes in the main flow are centered at `main_column_x`:
```
node_x = main_column_x - node_w / 2
```

Branch nodes are centered in their respective columns:
```
branch_node_x = branch_column_x - branch_node_w / 2
```

### Swimlane positioning

If swimlanes are defined:
```
swimlane_label_w = 120   // reserved for label on the left
swimlane_band_h = max(node_h for nodes in swimlane) + 40  // padding
swimlane_y[i] = swimlane_y[i-1] + swimlane_band_h[i-1]

// Offset all node positions by the swimlane
node_x += swimlane_label_w
// Adjust main_column_x accordingly
```

Swimlane label is positioned:
```
label_x = PAGE_MARGIN
label_y = swimlane_y + swimlane_band_h / 2   // vertically centered
```

## Step 5: Compute Connection Paths

### Straight arrows (direction: down)

From bottom-center of source to top-center of target:
```
start_x = source_x + source_w / 2
start_y = source_y + source_h
end_x = target_x + target_w / 2
end_y = target_y
```

For decision diamonds, the bottom anchor is the bottom vertex:
```
bottom_vertex = (diamond_cx, diamond_cy + DIAMOND_H / 2)
```

### Side arrows (direction: right or left)

From right/left-center of source to left/right-center of target:
```
// direction: right
start_x = source_x + source_w   // right edge
start_y = source_y + source_h / 2
end_x = target_x                // left edge of target
end_y = target_y + target_h / 2
```

For decision diamonds, the right vertex is:
```
right_vertex = (diamond_cx + DIAMOND_W / 2, diamond_cy)
```

### Loop-back connections

Loop-back arrows route along the right side of the diagram using a **cubic Bezier curve**:

```
// From the right side of source, curve up to the top of target
start_x = source_x + source_w
start_y = source_y + source_h / 2
end_x = target_x + target_w
end_y = target_y

// Control points route the curve to the right
loop_offset = max(60, (branch_column_x - main_column_x) / 2 + 40)
cp1_x = start_x + loop_offset
cp1_y = start_y
cp2_x = end_x + loop_offset
cp2_y = end_y

path = "M start_x,start_y C cp1_x,cp1_y cp2_x,cp2_y end_x,end_y"
```

The arrowhead marker is placed at the end point. The path is drawn with `stroke-dasharray` if the connection style is "dashed".

### Branch labels

Place "Yes" and "No" labels near the decision output edges:

```
// "Yes" label — below the decision (down direction)
yes_label_x = diamond_cx
yes_label_y = diamond_cy + DIAMOND_H / 2 + BRANCH_LABEL_OFFSET + 12

// "No" label — to the right of the decision (right direction)
no_label_x = diamond_cx + DIAMOND_W / 2 + BRANCH_LABEL_OFFSET + 8
no_label_y = diamond_cy + 4
```

### Connection label background

Each label has a small background rect for readability:
```
bg_x = label_x - label_w / 2 - 4
bg_y = label_y - 10
bg_w = label_w + 8
bg_h = 16
```

## Step 6: Compute ViewBox

```
rightmost = max(node_x + node_w for all nodes, including branch columns)
bottommost = max(node_y + node_h for all nodes)

viewBox_w = rightmost + PAGE_MARGIN + (loop-back offset if any) + 40
viewBox_h = bottommost + LEGEND_OFFSET + 50 + 30
```

Clamp viewBox_w to at least SVG_W:
```
viewBox_w = max(viewBox_w, SVG_W)
```

Default viewBox: `"0 0 1000 800"`. Adjust based on actual content.

## Step 7: Position Legend

```
legend_x = PAGE_MARGIN
legend_y = bottommost + LEGEND_OFFSET
```

Legend items are placed horizontally, 120px apart.

---

## Worked Example: CI/CD Pipeline

### Input (simplified)

10 nodes, 2 decision points, 2 loop-back connections:

```
Start → Code Commit → Build → Unit Tests → [Tests Pass?] ─yes→ Integration Tests
                                     │                              │
                                    no (loop)                   Deploy Staging
                                                                  │
                                                           [Approved?] ─yes→ Deploy Prod → End
                                                                │
                                                               no (loop to Code Commit)
```

### Constants

- SVG_W = 1000, PAGE_MARGIN = 40, NODE_GAP_V = 60, NODE_GAP_H = 40
- DIAMOND_W = 140, DIAMOND_H = 90

### Column Layout

- Main column center: SVG_W / 2 = 500
- Loop-back right offset: 80px to the right of the rightmost element

### Node Dimensions

| Node | Type | label_length | node_w | node_h |
|------|------|-------------|--------|--------|
| Start | start | 5 | 100 | 40 |
| Code Commit | process | 11 | 120 | 40 |
| Build | subprocess | 5 | 120 | 40 |
| Unit Tests | process | 10 | 120 | 40 |
| Tests Pass? | decision | 11 | 140 | 90 |
| Integration Tests | subprocess | 18 | 176 | 40 |
| Deploy Staging | process | 14 | 144 | 40 |
| Approved? | decision | 9 | 140 | 90 |
| Deploy Production | process | 17 | 168 | 40 |
| End | end | 3 | 100 | 40 |

### Vertical Positions (main column)

```
node_y[start]           = 40
node_y[code-commit]     = 40 + 40 + 60    = 140
node_y[build]           = 140 + 40 + 60   = 240
node_y[unit-test]       = 240 + 40 + 60   = 340
node_y[tests-pass]      = 340 + 40 + 60   = 440  (diamond, h=90)
node_y[integration]     = 440 + 90 + 60   = 590
node_y[deploy-staging]  = 590 + 40 + 60   = 690
node_y[approved]        = 690 + 40 + 60   = 790  (diamond, h=90)
node_y[deploy-prod]     = 790 + 90 + 60   = 940
node_y[end]             = 940 + 40 + 60   = 1040
```

### Horizontal Positions (centered on main column)

```
node_x[start]           = 500 - 100/2     = 450
node_x[code-commit]     = 500 - 120/2     = 440
node_x[build]           = 500 - 120/2     = 440
node_x[unit-test]       = 500 - 120/2     = 440
node_x[tests-pass]      = 500 - 140/2     = 430  (diamond cx=500)
node_x[integration]     = 500 - 176/2     = 412
node_x[deploy-staging]  = 500 - 144/2     = 428
node_x[approved]        = 500 - 140/2     = 430  (diamond cx=500)
node_x[deploy-prod]     = 500 - 168/2     = 416
node_x[end]             = 500 - 100/2     = 450
```

### Loop-back Paths

**"No" from Tests Pass? → Code Commit:**
```
start: right vertex of diamond = (500 + 70, 485) = (570, 485)
end: right edge of Code Commit = (440 + 120, 140) = (560, 140)
loop_offset = 80
cp1 = (570 + 80, 485) = (650, 485)
cp2 = (560 + 80, 140) = (640, 140)
path = "M 570,485 C 650,485 640,140 560,140"
```

**"No" from Approved? → Code Commit:**
```
start: right vertex of diamond = (500 + 70, 835) = (570, 835)
end: right edge of Code Commit = (560, 140)
loop_offset = 100
cp1 = (570 + 100, 835) = (670, 835)
cp2 = (560 + 100, 140) = (660, 140)
path = "M 570,835 C 670,835 660,140 560,140"
```

### Branch Labels

```
"Yes" for tests-pass:  (500, 440 + 45 + 8 + 12) = (500, 505)
"No" for tests-pass:   (500 + 70 + 8 + 8, 485 + 4) = (586, 489)
"Yes" for approved:    (500, 790 + 45 + 8 + 12) = (500, 855)
"No" for approved:     (500 + 70 + 8 + 8, 835 + 4) = (586, 839)
```

### ViewBox

```
rightmost = max(560 + 120, 670 + 40) = 710  // including loop paths
bottommost = 1040 + 40 = 1080
viewBox = "0 0 750 1160"
```

### Swimlane Bands (if enabled)

Three horizontal bands grouping nodes:

```
Developer:  y=20, h=160+60=160   (Start, Code Commit)
CI System:  y=220, h=590-220+40+30=440  (Build, Unit Tests, Tests Pass?, Integration Tests)
QA / Ops:   y=670, h=1080-670+30=440  (Deploy Staging, Approved?, Deploy Prod, End)
```

Swimlane label column width: 120px. All node x-positions shifted right by 120px.

---

## Edge Cases

### Multiple loop-backs to the same node

Stack the loop-back curves with increasing offset:
```
loop_offset[0] = 60
loop_offset[1] = 100
loop_offset[2] = 140
```
Each subsequent curve routes further to the right to avoid overlap.

### Decision with no "yes" path

If a decision only has a "no" branch, treat the default path as continuing down:
```
// No explicit yes connection → straight down to next node
// "no" branch goes right
```

### Nodes with very long labels

Cap node width at 250px and wrap text onto multiple lines:
```
if node_w > 250:
  node_w = 250
  // Split label into lines at word boundaries
  // Increase node_h by 14px per additional line
```

### Empty swimlanes

Skip rendering a swimlane band if it has no children. Do not leave an empty gap.

### Diamond text overflow

If decision label text is too wide for the diamond:
```
// Increase diamond dimensions proportionally
DIAMOND_W = max(140, label_length * 7 + 40)
DIAMOND_H = max(90, DIAMOND_W * 0.65)
```

### Merge points (multiple arrows into one node)

If two connections target the same node:
- Main flow arrow enters from top (bottom_center → top_center)
- Branch arrow enters from the right side (right_center or left offset)
- Offset the second arrow's y slightly to avoid visual overlap
