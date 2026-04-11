# Sequence Diagram — Layout Rules

## Constants

| Constant | Value | Description |
|----------|-------|-------------|
| SVG_W | 1200 | Total SVG width |
| ACTOR_GAP | 150 | Horizontal gap between actors |
| ACTOR_START_X | 120 | Left margin for first actor |
| MSG_START_Y | 100 | First message y position |
| MSG_GAP | 40 | Vertical gap between messages |
| ACTIVATION_W | 12 | Activation box width |
| ACTOR_BOX_H | 36 | Actor box height |
| ACTOR_FIGURE_H | 50 | Stick figure height |
| FRAGMENT_PAD | 15 | Fragment box padding |

## Actor Positioning

```
actor_x[i] = ACTOR_START_X + i * ACTOR_GAP
```

Actor label centered above the lifeline at `(actor_x[i], 30)`.

## Lifeline Length

```
max_order = max(message.order)
lifeline_bottom = MSG_START_Y + max_order * MSG_GAP + 40
```

Each actor gets a dashed vertical line:
```
from (actor_x[i], actor_top + ACTOR_BOX_H) to (actor_x[i], lifeline_bottom)
```

## Message Y Position

```
message_y[order] = MSG_START_Y + (order - 1) * MSG_GAP
```

## Message Routing

For messages between different actors:
```
from_x = actor_x[from_index]
to_x = actor_x[to_index]
arrow_y = message_y[order]
```

For self-messages (from == to):
```
path = M x,y L x+30,y L x+30,y+20 L x,y+20
```

## Activation Boxes

Track which actors are active during which messages:
```
For each actor, find first and last order where activate=true or involved
activation_top = MSG_START_Y + (first_order - 1) * MSG_GAP
activation_bottom = MSG_START_Y + (last_order - 1) * MSG_GAP
```

## Fragment Bounds

```
fragment_x = min(actor_x for involved actors) - FRAGMENT_PAD
fragment_y = MSG_START_Y + (min(children) - 1) * MSG_GAP - FRAGMENT_PAD
fragment_w = max(actor_x for involved actors) - fragment_x + FRAGMENT_PAD * 2
fragment_h = (max(children) - min(children) + 1) * MSG_GAP + FRAGMENT_PAD * 2
```

For alt with else:
```
else_y = MSG_START_Y + (else_children[0] - 1) * MSG_GAP - 5
divider_line: from fragment_x to fragment_x + fragment_w at else_y
```

## ViewBox

```
viewBox_w = max(actor_x) + ACTOR_START_X
viewBox_h = lifeline_bottom + 30
```

## Worked Example: Login Flow

4 actors: User, Client, AuthServer, Database

```
actor_x = [120, 270, 420, 570]
max_order = 10
lifeline_bottom = 100 + 10 * 40 + 40 = 540

Messages:
  1. User→Client (y=100)
  2. Client→AuthServer (y=140)
  3. AuthServer→Database (y=180)
  4. Database→AuthServer (y=220, return)
  5. AuthServer→Client (y=260) [alt: valid]
  6. Client→User (y=300) [alt: valid]
  7. AuthServer→Client (y=340) [alt: invalid]
  8. Client→User (y=380) [alt: invalid]

Fragment "alt":
  x = 120 - 15 = 105
  y = 260 - 15 = 245
  w = 570 - 120 + 30 = 480
  h = (8-5+1) * 40 + 30 = 190

  else divider at y = 340 - 5 = 335
```
