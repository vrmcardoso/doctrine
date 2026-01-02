# BriefingEngine Service Documentation

## Overview

The **BriefingEngine** is the narrative interpreter for Doctrine's Briefing Phase. It translates raw simulation data (game state JSON) into structured briefing packets for the frontend, organizing information into three distinct layers:

1. **The "Read" Layer** - Advisor Reports (conditional narrative feedback)
2. **The "Aesthetic" Layer** - Visual Manifest (UI/rendering flags based on state)
3. **The "Pivot" Layer** - Strategic Directions (player choice gates for Agenda Planning)

The service is **functional, stateless, and completely driven by YAML configuration** — allowing designers to create new advisor messages, visual states, and strategic pivots without touching Ruby code.

---

## Architecture

### Core Service: `GameEngine::BriefingEngine`

**Location:** `app/services/game_engine/briefing_engine.rb`

**Entry Point:**
```ruby
briefing_packet = GameEngine::BriefingEngine.generate_briefing(game_state_json)
```

**Input:**
- `game_state_json` (Hash): Contains `party_stats` (Float values 0.0-1.0) and `demographics` (Array of demographic data)

**Output:**
- `briefing_packet` (Hash): A structured response with three layers plus gating information

---

## Layer 1: Advisor Reports (The "Read")

### Purpose
Provide contextual feedback from advisors based on the current game state. Advisors filter in/out based on **conditions** defined in YAML.

### Data Source
**File:** `config/game_data/briefing_items.yml`

**Structure:**
```yaml
- id: 1
  advisor: "Head of Strategy"
  priority: "high"  # high, medium, low
  condition: "party.narrative_coherence < 0.4"
  message: "Our narrative is fracturing..."
  message_cynical: "The story's falling apart..."  # Shown when moral_conditioning > 0.5
  tags: ["crisis", "narrative"]
```

### Condition Evaluation
Conditions support:
- **Party stats:** `party.narrative_coherence`, `party.faction_integrity`, `party.moral_conditioning_index`, `party.narrative_control`
- **Demographics:** `demographics.youth.loyalty`, `demographics.older_voters.dissonance`
- **Operators:** `<`, `>`, `<=`, `>=`, `==`, `!=`
- **Logic:** `&&` (AND), `||` (OR)

**Examples:**
```
party.narrative_coherence < 0.4
party.faction_integrity < 0.3 && party.narrative_coherence < 0.5
demographics.youth.loyalty > 0.7
```

### Moral Equivalence System
When `moral_conditioning_index > 0.5`, the engine selects the `message_cynical` variant instead of the standard `message`. This allows the same advisors to sound more normalized/cynical as players condition public morality.

**Example:**
- Standard: "Our narrative is strong. Maintain messaging consistency."
- Cynical: "People know what you stand for—or at least what you want them to think."

### Output Format
```ruby
{
  advisor: "Head of Strategy",
  priority: "high",
  priority_level: 1,  # 1=high, 2=medium, 3=low (for sorting)
  message: "Selected message (standard or cynical)",
  tags: ["crisis", "narrative"],
  timestamp: "2026-01-02T15:54:21Z"
}
```

---

## Layer 2: Visual Manifest (The "Aesthetic")

### Purpose
Generate rendering directives for the frontend UI based on narrative breakdown, faction fracture, and moral corruption.

### Visual Flags

#### 1. **Glitch Intensity** (Narrative Breakdown)
Based on: Average of `narrative_coherence` and `narrative_control`

```
< 0.3: severe  (chromatic_aberration: 0.15, ui_noise: 0.8)
< 0.5: high    (chromatic_aberration: 0.10, ui_noise: 0.5)
< 0.7: medium  (chromatic_aberration: 0.05, ui_noise: 0.2)
≥ 0.7: low     (chromatic_aberration: 0.0,  ui_noise: 0.0)
```

**Purpose:** Chromatic aberration and UI noise visualize narrative incoherence to the player.

#### 2. **Fracture State** (Faction Integrity)
Based on: `faction_integrity`

```
< 0.3: critical  (icon_corruption: 0.9, visual_breaks: true)
< 0.5: severe    (icon_corruption: 0.6, visual_breaks: true)
< 0.7: moderate  (icon_corruption: 0.3, visual_breaks: false)
≥ 0.7: stable    (icon_corruption: 0.0, visual_breaks: false)
```

**Purpose:** Corrupts faction icons and splits UI elements to show coalition fracture.

#### 3. **Palette Corruption** (Moral Conditioning)
Based on: `moral_conditioning_index`

```
> 0.7: severe
  - shift: sickly_yellow_green
  - colors: #b5d96f, #e8d96f
  - corruption: 80%

> 0.5: moderate
  - shift: sickly_yellow_green
  - colors: #d4e89f, #f0e8a8
  - corruption: 50%

> 0.3: low
  - shift: sickly_yellow_green (subtle, 20% opacity)
  - corruption: 20%

≤ 0.3: none
  - shift: cyan (default pristine)
  - corruption: 0%
```

**Purpose:** Shifts the UI palette from pristine cyan toward sickly yellow-green as moral conditioning rises, visually indicating the player's compromised principles.

#### 4. **Aesthetic Mode** (Overall Tone)

```
pristine:    High narrative_coherence (>0.8) + Low moral_conditioning (<0.3)
unified:     High coherence (>0.6) + High conditioning (>0.6) [strong unified vision]
fractured:   Low coherence (<0.5)
corrupted:   High moral conditioning (>0.7)
standard:    Default state
```

### Output Format
```ruby
{
  glitch_intensity: {
    level: "severe",
    chromatic_aberration: 0.15,
    ui_noise: 0.8
  },
  fracture_state: {
    level: "critical",
    icon_corruption: 0.9,
    visual_breaks: true
  },
  palette_corruption: {
    level: "severe",
    shift_direction: "sickly_yellow_green",
    primary_color_override: "#b5d96f",
    secondary_color_override: "#e8d96f",
    corruption_percentage: 0.8
  },
  aesthetic_mode: "corrupted"
}
```

---

## Layer 3: Strategic Directions (The "Pivot")

### Purpose
Present 2-3 strategic pivots that lock the Agenda phase until one is selected. These are long-term narrative strategies that apply global modifiers to future phases.

### Data Source
**File:** `config/game_data/strategic_directions.yml`

**Structure:**
```yaml
- id: 1
  handle: "populist_pivot"
  title: "The Populist Pivot"
  narrative_hook: "Bypass the elites. Speak directly to the people."
  description: "Shift messaging toward outsider narratives..."
  condition: "party.faction_integrity > 0.4"  # Must pass to appear as an option
  global_modifiers:
    bots_cost: -0.20  # 20% cheaper bot operations
    virality_multiplier: 1.5  # 50% more viral
    coherence_penalty: 1.0  # No penalty
    moral_conditioning_multiplier: 1.2  # 20% faster moral conditioning
  tags: ["high_risk", "high_reward", "populist"]
```

### Global Modifiers Explained

| Modifier | Range | Effect |
|----------|-------|--------|
| `bots_cost` | -0.30 to 0.10 | Percentage change in bot deployment cost |
| `virality_multiplier` | 0.7 to 1.7 | Multiplier for message virality spread |
| `coherence_penalty` | 0.6 to 2.0 | Multiplier for narrative coherence loss per action |
| `moral_conditioning_multiplier` | 0.5 to 2.0 | Speed of moral conditioning accumulation |

### Gating Mechanism

The Agenda Planning phase is **locked** (`agenda_locked: true`) until the player selects one direction and writes it to the `active_forecast` key in the game state JSON.

**Gating Output:**
```ruby
{
  agenda_locked: true,
  lock_message: "Strategic direction must be selected before proceeding to Agenda Planning.",
  strategic_directions: {
    available_directions: [ /* 2-3 direction objects */ ],
    selection_required: true
  }
}
```

### Output Format (Per Direction)
```ruby
{
  id: 1,
  handle: "populist_pivot",
  title: "The Populist Pivot",
  narrative_hook: "Bypass the elites. Speak directly to the people.",
  description: "Shift messaging toward outsider narratives...",
  global_modifiers: {
    "bots_cost" => -0.2,
    "virality_multiplier" => 1.5,
    "coherence_penalty" => 1.0,
    "moral_conditioning_multiplier" => 1.2
  },
  tags: ["high_risk", "high_reward"],
  recommendation_level: 1  # 0=highest, 2=lowest
}
```

---

## Usage Examples

### Example 1: Standard Briefing Generation

```ruby
game_state = {
  "week" => 2,
  "party_stats" => {
    "narrative_coherence" => 0.6,
    "narrative_control" => 0.65,
    "faction_integrity" => 0.55,
    "moral_conditioning_index" => 0.45
  },
  "demographics" => [
    { "id" => 1, "name" => "Older Voters", "loyalty" => 0.7, "dissonance" => 0.1 },
    { "id" => 2, "name" => "Youth & Students", "loyalty" => 0.4, "dissonance" => 0.5 }
  ]
}

briefing = GameEngine::BriefingEngine.generate_briefing(game_state)

# Access the three layers
briefing[:advisor_reports]         # Layer 1: Advisor feedback
briefing[:visual_manifest]         # Layer 2: UI rendering flags
briefing[:strategic_directions]    # Layer 3: Player choice options
briefing[:agenda_locked]           # Gating flag
```

### Example 2: Testing Moral Equivalence

```ruby
high_moral_state = {
  "party_stats" => {
    "narrative_coherence" => 0.3,
    "moral_conditioning_index" => 0.8  # HIGH
  },
  "demographics" => []
}

briefing = GameEngine::BriefingEngine.generate_briefing(high_moral_state)

# Advisors will use cynical messages instead of standard ones
briefing[:advisor_reports].each do |report|
  puts report[:message]  # Will include cynical variants
end
```

### Example 3: Checking Visual State

```ruby
game_state = {
  "party_stats" => {
    "narrative_coherence" => 0.2,    # Very low
    "faction_integrity" => 0.25,     # Very low
    "moral_conditioning_index" => 0.85  # Very high
  },
  "demographics" => []
}

briefing = GameEngine::BriefingEngine.generate_briefing(game_state)
visual = briefing[:visual_manifest]

# Expect severe glitch effects
visual[:glitch_intensity][:level]  # => "severe"

# Expect fractured coalition rendering
visual[:fracture_state][:icon_corruption]  # => 0.9

# Expect heavy palette corruption
visual[:palette_corruption][:corruption_percentage]  # => 0.8
```

---

## Adding New Briefing Items

To add a new advisor message:

1. **Open** `config/game_data/briefing_items.yml`
2. **Append** a new entry with a unique ID:
   ```yaml
   - id: 13
     advisor: "Economic Advisor"
     priority: "medium"
     condition: "party.funds < 2000"
     message: "Our budget is depleted. Strategic spending is necessary."
     message_cynical: "Money's tight. Time to cut costs or find new revenue."
     tags: ["economic", "warning"]
   ```
3. **No code changes needed** — FrozenRecord will automatically load the new item.

---

## Adding New Strategic Directions

To add a new strategic pivot:

1. **Open** `config/game_data/strategic_directions.yml`
2. **Append** a new direction with a unique ID and handle:
   ```yaml
   - id: 7
     handle: "media_control"
     title: "Media Control"
     narrative_hook: "Own the narrative. Control the message."
     description: "Invest heavily in media infrastructure..."
     condition: "party.funds > 5000"
     global_modifiers:
       bots_cost: -0.15
       virality_multiplier: 1.6
       coherence_penalty: 1.2
       moral_conditioning_multiplier: 1.3
     tags: ["media", "high_cost"]
   ```
3. **No code changes needed** — the engine will discover and serve the new direction.

---

## Condition Evaluator

**Location:** `app/services/game_engine/condition_evaluator.rb`

The ConditionEvaluator parses and evaluates YAML condition strings against game state.

### Supported Features

- **Numeric comparisons:** `<`, `>`, `<=`, `>=`, `==`, `!=`
- **Party stats:** `party.narrative_coherence`, `party.faction_integrity`, etc.
- **Demographics:** `demographics.<name>.<stat>` (name is case-insensitive)
- **Logical operators:** `&&`, `||`
- **Parentheses not yet supported** (conditions are evaluated left-to-right)

### Examples

```ruby
evaluator = GameEngine::ConditionEvaluator.new(party_stats, demographics)

# Simple comparison
evaluator.evaluate("party.narrative_coherence < 0.4")  # => true/false

# Complex AND condition
evaluator.evaluate("party.narrative_coherence < 0.4 && party.faction_integrity < 0.3")

# Demographic check
evaluator.evaluate("demographics.youth.loyalty > 0.7")
```

---

## Models

### BriefingItem (FrozenRecord)
**Location:** `app/models/briefing_item.rb`

Maps to: `config/game_data/briefing_items.yml`

**Attributes:**
- `id`, `advisor`, `priority`, `condition`
- `message`, `message_cynical`
- `tags`

### StrategicDirection (FrozenRecord)
**Location:** `app/models/strategic_direction.rb`

Maps to: `config/game_data/strategic_directions.yml`

**Attributes:**
- `id`, `handle`, `title`, `narrative_hook`, `description`
- `condition`, `global_modifiers` (Hash), `tags`

---

## Testing

The service is **fully testable** and **stateless**. You can call `generate_briefing` multiple times with different states and expect consistent, predictable results.

**Key Testing Principles:**
1. Each call to `generate_briefing` is independent (no side effects)
2. Conditions are evaluated deterministically
3. Visual flags scale linearly with state values
4. Moral conditioning always triggers cynical messages above 0.5

**Example Test:**
```ruby
game_state_1 = { "party_stats" => { "moral_conditioning_index" => 0.3 } }
game_state_2 = { "party_stats" => { "moral_conditioning_index" => 0.8 } }

briefing_1 = GameEngine::BriefingEngine.generate_briefing(game_state_1)
briefing_2 = GameEngine::BriefingEngine.generate_briefing(game_state_2)

# Both should work independently and return valid briefing packets
assert briefing_1[:advisor_reports].present?
assert briefing_2[:advisor_reports].present?
```

---

## Integration with Frontend

The `briefing_packet` returned by `generate_briefing` is ready to be sent to the frontend as JSON.

**Typical Controller Usage:**

```ruby
class BriefingsController < ApplicationController
  def show
    game_state = @campaign.current_game_state
    briefing_packet = GameEngine::BriefingEngine.generate_briefing(game_state)
    render json: briefing_packet
  end
end
```

**Frontend consumes:**
- `advisor_reports` — Display as notification cards
- `visual_manifest` — Apply CSS transforms/filters
- `strategic_directions` — Render as selectable buttons/cards
- `agenda_locked` — Show overlay/lock UI until direction selected

---

## Performance Notes

- **FrozenRecord Loading:** YAML is loaded once at boot (in production)
- **Condition Evaluation:** O(n) where n = number of conditions (linear, typically <50)
- **Service Call:** Single-pass evaluation, no database queries
- **Memory:** Stateless; each call creates new objects (no accumulation)

---

## Future Extensions

Possible enhancements:

1. **Weighted Direction Selection:** Instead of random 0-2, score directions based on game state alignment
2. **Advisor Opinions:** Different advisors react differently to the same state (weighted response)
3. **Campaign History:** "The last time we tried this, it failed" messages that reference past decisions
4. **Dynamic Thresholds:** YAML-configurable glitch/fracture thresholds instead of hardcoded
5. **Advisor Relationships:** Advisors who can conflict with each other in the briefing

---

## Files Summary

| File | Purpose |
|------|---------|
| `app/services/game_engine/briefing_engine.rb` | Main service (3 layers + gating) |
| `app/services/game_engine/condition_evaluator.rb` | Condition string parser/evaluator |
| `app/models/briefing_item.rb` | FrozenRecord model for advisor messages |
| `app/models/strategic_direction.rb` | FrozenRecord model for strategic pivots |
| `config/game_data/briefing_items.yml` | Advisor message data (12+ items) |
| `config/game_data/strategic_directions.yml` | Strategic direction data (6 pivots) |

---

**Last Updated:** January 2, 2026  
**Status:** Production Ready
