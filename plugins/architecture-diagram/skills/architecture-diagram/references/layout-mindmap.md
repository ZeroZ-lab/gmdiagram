# Mind Map Layout Rules

These rules compute SVG coordinates from the JSON schema. Follow them to position all elements deterministically — do NOT guess coordinates.

## Constants

| Name | Value | Purpose |
|------|-------|---------|
| `SVG_W` | 1200px | SVG viewBox width (fixed) |
| `SVG_H` | 800px | SVG viewBox height (starting value, auto-adjusted) |
| `CENTER_NODE_R` | 50px | Central node circle radius |
| `BRANCH_H_GAP` | 120px | Horizontal distance between branch levels |
| `BRANCH_V_GAP` | 30px | Vertical gap between sibling branches |
| `BRANCH_NODE_H` | 32px | Branch node height |
| `BRANCH_NODE_PAD` | 24px | Horizontal padding inside branch nodes (12px each side) |
| `CHAR_W` | 8px | Approximate character width at branch font size |
| `PAGE_MARGIN` | 40px | Minimum space between content and SVG edge |

## Step 1: Determine Central Node Position

```
center_x = SVG_W / 2   // = 600
center_y = SVG_H / 2   // = 400 (initial; adjusted after Step 3)
```

The central node is a circle centered at `(center_x, center_y)` with radius `CENTER_NODE_R`.

## Step 2: Assign Sides to Top-Level Branches

For each top-level branch (direct child of `centralNode`):

1. If `side` is `"left"` or `"right"` — use that value.
2. If `side` is `"auto"` or not set — distribute evenly:
   - Split branches into two groups: first half goes right, second half goes left.
   - If odd number: the extra branch goes to the side with less total subtree height (computed in Step 3).

All descendants of a top-level branch inherit their ancestor's side.

## Step 3: Compute Subtree Heights (Recursive)

For each branch, calculate the total vertical space its subtree occupies:

```
function subtreeHeight(branch):
    if branch has no children:
        return BRANCH_NODE_H
    children_total = sum(subtreeHeight(child) for each child)
                      + BRANCH_V_GAP * (num_children - 1)
    return max(BRANCH_NODE_H, children_total)
```

The total height of the mind map (both sides combined):

```
right_height = sum(subtreeHeight(b) for right-side branches) + BRANCH_V_GAP * (num_right - 1)
left_height  = sum(subtreeHeight(b) for left-side branches)  + BRANCH_V_GAP * (num_left - 1)
total_height = max(right_height, left_height) + CENTER_NODE_R * 2 + PAGE_MARGIN * 2
```

Adjust `center_y` and `SVG_H`:

```
SVG_H = total_height
center_y = SVG_H / 2
```

## Step 4: Compute Branch X Positions

For each level of depth (1-indexed, where level 1 = top-level branches):

```
// Right-side branches
branch_x = center_x + CENTER_NODE_R + BRANCH_H_GAP * level

// Left-side branches
branch_x = center_x - CENTER_NODE_R - BRANCH_H_GAP * level - branch_node_w
```

Where `branch_node_w` is the width of the branch node (computed in Step 6).

## Step 5: Compute Branch Y Positions (Vertical Centering)

For each group of sibling branches, center them vertically relative to their parent:

```
function layoutChildren(children, parent_y, parent_subtree_h):
    total_h = sum(subtreeHeight(child)) + BRANCH_V_GAP * (num_children - 1)
    start_y = parent_y + (parent_subtree_h - total_h) / 2

    current_y = start_y
    for each child:
        child_y = current_y + (subtreeHeight(child) - BRANCH_NODE_H) / 2
        // ^ centers the node within its subtree allocation
        layoutChildren(child.children, current_y, subtreeHeight(child))
        current_y += subtreeHeight(child) + BRANCH_V_GAP
```

For top-level branches, the parent is the central node at `center_y`:

```
// Right side
layoutChildren(right_branches, center_y - subtree_h/2, total_right_subtree_h)

// Left side
layoutChildren(left_branches, center_y - subtree_h/2, total_left_subtree_h)
```

## Step 6: Compute Branch Node Widths

```
branch_node_w = max(60, label_length * CHAR_W + BRANCH_NODE_PAD * 2)
```

- `label_length`: number of characters in the branch label
- Minimum width: 60px
- Add 24px padding (12px each side)

## Step 7: Compute Connection Paths (Cubic Bezier)

For each parent-child pair, draw a cubic bezier `<path>` from the parent's edge to the child's edge.

### Right-side connections

Parent is to the left of the child:
```
x1 = parent right edge    // parent_x + parent_w (or center_x + CENTER_NODE_R for central node)
y1 = parent center y
x2 = child left edge      // child_x
y2 = child center y       // child_y + BRANCH_NODE_H / 2

path = "M x1,y1 C (x1+40),y1 (x2-40),y2 x2,y2"
```

### Left-side connections

Parent is to the right of the child:
```
x1 = parent left edge     // parent_x (or center_x - CENTER_NODE_R for central node)
y1 = parent center y
x2 = child right edge     // child_x + child_w
y2 = child center y

path = "M x1,y1 C (x1-40),y1 (x2+40),y2 x2,y2"
```

The control point offset of 40px creates a smooth S-curve. Adjust proportionally if `BRANCH_H_GAP` differs from default.

## Step 8: Compute ViewBox

Auto-calculate the viewBox to fit all branches with margin:

```
// Find extremes
min_x = min of all branch left edges - PAGE_MARGIN
max_x = max of all branch right edges + PAGE_MARGIN
min_y = min of all branch top edges - PAGE_MARGIN
max_y = max of all branch bottom edges + PAGE_MARGIN

// Include central node
min_x = min(min_x, center_x - CENTER_NODE_R - PAGE_MARGIN)
max_x = max(max_x, center_x + CENTER_NODE_R + PAGE_MARGIN)

viewBox = "min_x min_y (max_x - min_x) (max_y - min_y)"
```

If all content fits within `SVG_W x SVG_H`, use the simpler default:
```
viewBox = "0 0 SVG_W SVG_H"
```

## Worked Example: Product Feature Map

### Input

- Central node: "gmdiagram" (id: "root")
- 4 top-level branches (all `side: "auto"`):
  - **Diagram Types** (5 children): Architecture, Mind Map, Flowchart, Sequence, ER Diagram
  - **Visual Styles** (6 children): Dark Pro, Hand-Drawn, Light Corp, Cyberpunk, Blueprint, Warm Cozy
  - **Output Formats** (4 children): HTML, SVG, PNG, PDF
  - **Icon System** (3 children): DevIcons, Simple Icons, Custom SVG

### Side Assignment (auto-balanced)

4 branches, split evenly:
- **Right side**: Diagram Types, Visual Styles (first 2)
- **Left side**: Output Formats, Icon System (last 2)

### Subtree Height Calculation

```
// Leaf nodes have height = BRANCH_NODE_H = 32

// Diagram Types: 5 children
subtreeHeight("diagram-types") = 32*5 + 30*4 = 160 + 120 = 280

// Visual Styles: 6 children
subtreeHeight("visual-styles") = 32*6 + 30*5 = 192 + 150 = 342

// Output Formats: 4 children
subtreeHeight("output-formats") = 32*4 + 30*3 = 128 + 90 = 218

// Icon System: 3 children
subtreeHeight("icon-system") = 32*3 + 30*2 = 96 + 60 = 156
```

### Total Side Heights

```
right_total = 280 + 342 + 30 = 652
left_total  = 218 + 156 + 30 = 404
total_height = max(652, 404) + 50*2 + 40*2 = 652 + 180 = 832
```

### SVG Dimensions

```
SVG_H = 832
center_x = 600
center_y = 416
```

### Central Node

```
Circle at (600, 416), radius 50
```

### Right-Side Branch X Positions (Level 1)

```
branch_x = 600 + 50 + 120 * 1 = 770
```

### Right-Side Branch Y Positions

```
// Right side total height = 652
start_y = 416 - 652/2 = 90

// Diagram Types: subtree=280, starts at y=90
diagram_types_y = 90 + (280 - 32) / 2 = 90 + 124 = 214
// Center: 214 + 16 = 230

// Visual Styles: subtree=342, starts at y=90+280+30=400
visual_styles_y = 400 + (342 - 32) / 2 = 400 + 155 = 555
// Center: 555 + 16 = 571
```

### Right-Side Children Y (Diagram Types, 5 children)

```
start_y = 90  // parent subtree start
children_total = 32*5 + 30*4 = 280

child[0] "Architecture": y = 90, center = 106
child[1] "Mind Map":     y = 90 + 32 + 30 = 152, center = 168
child[2] "Flowchart":    y = 152 + 32 + 30 = 214, center = 230
child[3] "Sequence":     y = 214 + 32 + 30 = 276, center = 292
child[4] "ER Diagram":   y = 276 + 32 + 30 = 338, center = 354
```

### Right-Side Children Y (Visual Styles, 6 children)

```
start_y = 400
child[0] "Dark Pro":     y = 400, center = 416
child[1] "Hand-Drawn":   y = 400 + 62 = 462, center = 478
child[2] "Light Corp":   y = 462 + 62 = 524, center = 540
child[3] "Cyberpunk":    y = 524 + 62 = 586, center = 602
child[4] "Blueprint":    y = 586 + 62 = 648, center = 664
child[5] "Warm Cozy":    y = 648 + 62 = 710, center = 726
```

### Left-Side Branch X Positions (Level 1)

```
branch_x = 600 - 50 - 120 * 1 - branch_node_w
// Output Formats (w~100): x = 600 - 50 - 120 - 100 = 330
// Icon System (w~90): x = 600 - 50 - 120 - 90 = 340
```

### Left-Side Branch Y Positions

```
start_y = 416 - 404/2 = 214

// Output Formats: subtree=218, starts at y=214
output_formats_y = 214 + (218 - 32) / 2 = 214 + 93 = 307
// Center: 307 + 16 = 323

// Icon System: subtree=156, starts at y=214+218+30=462
icon_system_y = 462 + (156 - 32) / 2 = 462 + 62 = 524
// Center: 524 + 16 = 540
```

### Connection Paths (Examples)

```
// Central node → Diagram Types (right side)
M 650,416 C 690,416 730,230 770,230

// Central node → Output Formats (left side)
M 550,416 C 510,416 430,323 430,323

// Diagram Types → Architecture (right side, level 2)
M 870,230 C 910,230 950,106 990,106
```

### ViewBox

```
// Rightmost edge: level-2 branch right edge ~ 990 + 100 = 1090
// Leftmost edge: level-1 branch left edge ~ 330
// Width needed: 1090 - 330 + 80 (margin) = 840, fits in 1200

min_x = 0
min_y = 0
viewBox = "0 0 1200 832"
```

## Edge Cases

### Single branch on one side
- The single branch is vertically centered on `center_y`
- No siblings to distribute, so subtree_h = parent allocation

### Very deep nesting (level 4+)
- Branches may extend beyond SVG bounds
- Increase `SVG_W` by `BRANCH_H_GAP` for each additional level
- Or reduce `BRANCH_H_GAP` to 80px for levels 3+

### Uneven sides
- If one side is much taller, `center_y` shifts toward that side's center
- The shorter side's branches are vertically centered within the total height

### Long labels
- Branch node width expands to fit label text
- Cap at 200px; truncate label with ellipsis if wider

### Too many top-level branches (>8)
- Consider regrouping into fewer branches with deeper nesting
- Or increase `BRANCH_V_GAP` and `SVG_H` proportionally
