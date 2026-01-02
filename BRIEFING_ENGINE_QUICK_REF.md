# BriefingEngine Quick Reference

## One-Line Summary
The BriefingEngine is a stateless narrative interpreter that transforms game state JSON into a structured briefing packet with advisor reports, visual rendering flags, and strategic direction options for the player.

## Quick Start

### Basic Usage
```ruby
game_state = {
  "party_stats" => {
    "narrative_coherence" => 0.6,
    "narrative_control" => 0.65,
    "faction_integrity" => 0.55,
    "moral_conditioning_index" => 0.4
  },
  "demographics" => [...]
}

briefing = GameEngine::BriefingEngine.generate_briefing(game_state)

# Returns a briefing_packet with:
briefing[:advisor_reports]       # Layer 1: Advisor feedback
briefing[:visual_manifest]        # Layer 2: UI rendering flags
briefing[:strategic_directions]   # Layer 3: Player choice options
briefing[:agenda_locked]          # Gating until direction selected
```

## Three Core Layers

### 1. Advisor Reports (The "Read")
- **Purpose:** Contextual narrative feedback from advisors
- **Data:** `config/game_data/briefing_items.yml` (12+ items)
- **Filtering:** Condition-based (e.g., `party.narrative_coherence < 0.4`)
- **Feature:** Moral Equivalence System (cynical messages when moral conditioning > 0.5)

**Example Condition:**
```yaml
condition: "party.narrative_coherence < 0.4 && party.faction_integrity < 0.3"
```

### 2. Visual Manifest (The "Aesthetic")
- **Purpose:** UI rendering directives (glitches, corruption, palette shifts)
- **Components:**
  - `glitch_intensity` — Chromatic aberration/UI noise based on narrative breakdown
  - `fracture_state` — Icon corruption/visual breaks based on faction health
  - `palette_corruption` — Color shift from cyan to sickly yellow-green based on moral conditioning
  - `aesthetic_mode` — Overall tone (pristine/unified/fractured/corrupted/standard)

**Color Scheme:**
```
Pristine:   Cyan (#00FFFF) — clean, coherent narrative
Corrupted:  Sickly Green (#b5d96f) — heavy moral conditioning
```

### 3. Strategic Directions (The "Pivot")
- **Purpose:** Long-term narrative strategies that lock the Agenda phase
- **Data:** `config/game_data/strategic_directions.yml` (6+ pivots)
- **Gating:** Player must select one direction before proceeding
- **Effect:** Global modifiers applied to subsequent phases
  - `bots_cost` — Bot deployment cost change (-30% to +10%)
  - `virality_multiplier` — Message spread multiplier (0.7 to 1.7x)
  - `coherence_penalty` — Narrative loss multiplier (0.6 to 2.0x)
  - `moral_conditioning_multiplier` — Conditioning speed (0.5 to 2.0x)

## Key Features

### ✓ Functional & Stateless
- No database queries
- No side effects
- Same input = Same output
- Thread-safe

### ✓ YAML-Driven
- All narrative text in YAML files
- Designers can modify without code changes
- Easy to add new advisors, conditions, and directions

### ✓ Condition Evaluation
- Supports: `<`, `>`, `<=`, `>=`, `==`, `!=`
- Logic: `&&`, `||`
- Paths: `party.stat` or `demographics.name.stat`

### ✓ Moral Equivalence System
- Normal messages → cynical messages based on moral_conditioning
- Advisors become desensitized to ethics as conditioning rises
- Same advisor, different tone

### ✓ Visual Scaling
- All visual flags scale linearly with state values
- Glitch/corruption/breaks increase as coherence/integrity drop
- Palette shift from pristine cyan to sickly green

## File Map

| File | Purpose |
|------|---------|
| `app/services/game_engine/briefing_engine.rb` | Main service (3 layers + gating) |
| `app/services/game_engine/condition_evaluator.rb` | Condition string evaluation |
| `app/models/briefing_item.rb` | FrozenRecord model for advisor messages |
| `app/models/strategic_direction.rb` | FrozenRecord model for strategic pivots |
| `config/game_data/briefing_items.yml` | 12+ advisor messages with conditions |
| `config/game_data/strategic_directions.yml` | 6+ strategic pivot options |
| `BRIEFING_ENGINE.md` | Full documentation |

## Adding Content (No Code Changes!)

### Add a New Advisor Message
Edit `config/game_data/briefing_items.yml`:
```yaml
- id: 13
  advisor: "Economic Advisor"
  priority: "medium"
  condition: "party.funds < 2000"
  message: "Our budget is depleted."
  message_cynical: "Money's tight. Cut costs or find new revenue."
  tags: ["economic", "warning"]
```

### Add a New Strategic Direction
Edit `config/game_data/strategic_directions.yml`:
```yaml
- id: 7
  handle: "media_control"
  title: "Media Control"
  narrative_hook: "Own the narrative."
  description: "Invest in media infrastructure..."
  condition: "party.funds > 5000"
  global_modifiers:
    bots_cost: -0.15
    virality_multiplier: 1.6
    coherence_penalty: 1.2
    moral_conditioning_multiplier: 1.3
  tags: ["media", "high_cost"]
```

**FrozenRecord automatically discovers new entries!**

## Testing

```ruby
# Test 1: Basic generation
briefing = GameEngine::BriefingEngine.generate_briefing(game_state)
assert briefing[:advisor_reports].present?
assert briefing[:visual_manifest].present?
assert briefing[:strategic_directions].present?

# Test 2: Moral equivalence
normal = GameEngine::BriefingEngine.generate_briefing(low_moral_state)
cynical = GameEngine::BriefingEngine.generate_briefing(high_moral_state)
assert normal[:advisor_reports].first[:message] != cynical[:advisor_reports].first[:message]

# Test 3: Stateless
first = GameEngine::BriefingEngine.generate_briefing(state)
second = GameEngine::BriefingEngine.generate_briefing(state)
assert first == second
```

## Party Stats Reference

All values are **floats from 0.0 to 1.0**:

| Stat | Meaning | Rising = |
|------|---------|----------|
| `narrative_coherence` | Story consistency | Less glitch |
| `narrative_control` | How tightly the narrative is controlled | Less glitch |
| `faction_integrity` | Coalition unity | Less fracture |
| `moral_conditioning_index` | How much public morality has been conditioned | More palette corruption |

## Condition Examples

```ruby
# Single stat check
"party.narrative_coherence < 0.4"

# Complex AND
"party.narrative_coherence < 0.4 && party.faction_integrity < 0.3"

# OR condition
"party.funds < 2000 || party.narrative_coherence < 0.3"

# Demographic check
"demographics.youth.loyalty > 0.7"

# Always true/false
"true"
"false"
```

## Performance

- **YAML Load:** Once at boot (cached by FrozenRecord)
- **Condition Eval:** O(n) where n = number of conditions (typically <50)
- **Service Call:** Single-pass, no queries
- **Memory:** Stateless, no accumulation

**Typical Response Time:** <5ms

## Integration with Controllers

```ruby
class BriefingsController < ApplicationController
  def show
    game_state = @campaign.current_game_state
    briefing = GameEngine::BriefingEngine.generate_briefing(game_state)
    render json: briefing
  end
end
```

## Frontend Integration Points

| Data | Frontend Use |
|------|--------------|
| `advisor_reports` | Display as notification cards with priority coloring |
| `visual_manifest.glitch_intensity` | Apply chromatic aberration CSS filter |
| `visual_manifest.fracture_state` | Distort faction icons or add visual breaks |
| `visual_manifest.palette_corruption` | Override UI colors with sickly green/yellow |
| `aesthetic_mode` | Trigger overall UI theme (pristine/corrupted/etc) |
| `strategic_directions` | Render as selectable strategy cards |
| `agenda_locked` | Show lock overlay until direction selected |

## Common Mistakes

❌ **Wrong:** Hardcoding narrative text in service  
✅ **Right:** Put text in YAML, service just selects based on conditions

❌ **Wrong:** Complex condition logic with parentheses  
✅ **Right:** Simple conditions with && and ||, evaluated left-to-right

❌ **Wrong:** Trying to modify state inside generate_briefing  
✅ **Right:** Service is read-only, returns data for frontend to decide next action

❌ **Wrong:** Assuming same direction appears every time  
✅ **Right:** Directions are filtered by conditions, set conditions appropriately

## Debugging

```ruby
# Check what BriefingItems exist
BriefingItem.all.map { |item| [item.id, item.advisor, item.condition] }

# Check what StrategicDirections exist
StrategicDirection.all.map { |dir| [dir.id, dir.handle, dir.condition] }

# Test a condition directly
evaluator = GameEngine::ConditionEvaluator.new(party_stats, demographics)
evaluator.evaluate("party.narrative_coherence < 0.5")  # => true/false

# Check which advisors trigger for a state
game_state = { ... }
briefing = GameEngine::BriefingEngine.generate_briefing(game_state)
briefing[:advisor_reports].each { |r| puts "#{r[:advisor]}: #{r[:priority]}" }
```

## Next Steps

1. **Integrate with Campaign Model** — Load game_state from Campaign#state_json
2. **Frontend Rendering** — Consume briefing_packet to render UI
3. **Direction Selection** — Save selected direction to Campaign#active_forecast
4. **Gating Logic** — Lock Agenda phase until active_forecast is set
5. **Theme Expansion** — Add more advisors, directions, and visual states in YAML

---

**Status:** Production Ready  
**Last Updated:** January 2, 2026  
**Maintainer:** Doctrine Development Team
