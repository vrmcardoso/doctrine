module GameEngine
  class BriefingEngine
    # Main entry point: takes a game_state JSON blob and returns a briefing_packet
    # @param game_state [Hash] The current game state with party_stats and demographics
    # @return [Hash] A briefing_packet with advisor_reports, visual_manifest, and strategic_directions
    def self.generate_briefing(game_state)
      engine = new(game_state)
      {
        advisor_reports: engine.generate_advisor_reports,
        visual_manifest: engine.generate_visual_manifest,
        strategic_directions: engine.generate_strategic_directions,
        agenda_locked: true,  # Agenda phase is locked until active_forecast is set
        lock_message: "Strategic direction must be selected before proceeding to Agenda Planning."
      }
    end

    def initialize(game_state)
      @game_state = game_state
      @party_stats = game_state.fetch("party_stats", {})
      @demographics = game_state.fetch("demographics", {})
    end

    # ============================================================================
    # Layer 1: Advisor Report Generation (The "Read" Layer)
    # ============================================================================

    def generate_advisor_reports
      BriefingItem.all.select { |item| matches_condition?(item.condition) }
        .group_by(&:advisor)
        .map { |advisor, items| format_advisor_report(advisor, items) }
        .sort_by { |report| report[:priority_level] }
    end

    # ============================================================================
    # Layer 2: Visual Manifest Generator (The "Aesthetic" Layer)
    # ============================================================================

    def generate_visual_manifest
      {
        glitch_intensity: calculate_glitch_intensity,
        fracture_state: calculate_fracture_state,
        palette_corruption: calculate_palette_corruption,
        aesthetic_mode: determine_aesthetic_mode
      }
    end

    # ============================================================================
    # Layer 3: Strategic Forecast Generator (The "Pivot" Layer)
    # ============================================================================

    def generate_strategic_directions
      available_directions = StrategicDirection.all
        .select { |direction| matches_condition?(direction.condition) }
        .map { |direction| format_strategic_direction(direction) }

      # Limit to 2-3 options, prioritizing based on current state
      selected = prioritize_strategic_directions(available_directions)

      {
        available_directions: selected,
        count: selected.length,
        selection_required: true,
        message: "You must select a strategic direction to proceed to Agenda Planning."
      }
    end

    private

    # ============================================================================
    # Helper Methods for Advisor Reports
    # ============================================================================

    def format_advisor_report(advisor, items)
      # Select highest priority item for this advisor
      item = items.max_by { |i| priority_to_number(i.priority) }

      {
        advisor: advisor,
        priority: item.priority,
        priority_level: priority_to_number(item.priority),
        message: select_message(item),
        tags: item.tags,
        timestamp: Time.current.iso8601
      }
    end

    def select_message(item)
      # Moral Equivalence System: Select cynical version if moral_conditioning is high
      moral_index = @party_stats.fetch("moral_conditioning_index", 0.0)

      if moral_index > 0.5 && item.respond_to?(:message_cynical)
        item.message_cynical || item.message
      else
        item.message
      end
    end

    def priority_to_number(priority_string)
      case priority_string
      when "high"
        1
      when "medium"
        2
      when "low"
        3
      else
        4
      end
    end

    # ============================================================================
    # Helper Methods for Visual Manifest
    # ============================================================================

    def calculate_glitch_intensity
      # Based on narrative_coherence and narrative_control
      narrative_coherence = @party_stats.fetch("narrative_coherence", 1.0)
      narrative_control = @party_stats.fetch("narrative_control", 1.0)

      # Glitch intensity increases as these drop below thresholds
      avg_narrative = (narrative_coherence + narrative_control) / 2.0

      if avg_narrative < 0.3
        { level: "severe", chromatic_aberration: 0.15, ui_noise: 0.8 }
      elsif avg_narrative < 0.5
        { level: "high", chromatic_aberration: 0.10, ui_noise: 0.5 }
      elsif avg_narrative < 0.7
        { level: "medium", chromatic_aberration: 0.05, ui_noise: 0.2 }
      else
        { level: "low", chromatic_aberration: 0.0, ui_noise: 0.0 }
      end
    end

    def calculate_fracture_state
      # Based on faction_integrity
      faction_integrity = @party_stats.fetch("faction_integrity", 1.0)

      if faction_integrity < 0.3
        { level: "critical", icon_corruption: 0.9, visual_breaks: true }
      elsif faction_integrity < 0.5
        { level: "severe", icon_corruption: 0.6, visual_breaks: true }
      elsif faction_integrity < 0.7
        { level: "moderate", icon_corruption: 0.3, visual_breaks: false }
      else
        { level: "stable", icon_corruption: 0.0, visual_breaks: false }
      end
    end

    def calculate_palette_corruption
      # Based on moral_conditioning_index
      moral_index = @party_stats.fetch("moral_conditioning_index", 0.0)

      if moral_index > 0.7
        {
          level: "severe",
          shift_direction: "sickly_yellow_green",
          primary_color_override: "#b5d96f",
          secondary_color_override: "#e8d96f",
          corruption_percentage: 0.8
        }
      elsif moral_index > 0.5
        {
          level: "moderate",
          shift_direction: "sickly_yellow_green",
          primary_color_override: "#d4e89f",
          secondary_color_override: "#f0e8a8",
          corruption_percentage: 0.5
        }
      elsif moral_index > 0.3
        {
          level: "low",
          shift_direction: "sickly_yellow_green",
          primary_color_override: "rgba(212, 232, 159, 0.2)",
          secondary_color_override: "rgba(240, 232, 168, 0.2)",
          corruption_percentage: 0.2
        }
      else
        {
          level: "none",
          shift_direction: "cyan",
          primary_color_override: nil,
          secondary_color_override: nil,
          corruption_percentage: 0.0
        }
      end
    end

    def determine_aesthetic_mode
      narrative_coherence = @party_stats.fetch("narrative_coherence", 1.0)
      moral_index = @party_stats.fetch("moral_conditioning_index", 0.0)

      if narrative_coherence > 0.8 && moral_index < 0.3
        "pristine"
      elsif narrative_coherence > 0.6 && moral_index > 0.6
        "unified"
      elsif narrative_coherence < 0.5
        "fractured"
      elsif moral_index > 0.7
        "corrupted"
      else
        "standard"
      end
    end

    # ============================================================================
    # Helper Methods for Strategic Directions
    # ============================================================================

    def format_strategic_direction(direction)
      {
        id: direction.id,
        handle: direction.handle,
        title: direction.title,
        narrative_hook: direction.narrative_hook,
        description: direction.description,
        global_modifiers: direction.global_modifiers,
        tags: direction.tags,
        recommendation_level: calculate_recommendation_level
      }
    end

    def prioritize_strategic_directions(directions)
      sorted = directions.sort_by { |d| d[:recommendation_level] }
      sorted.take(3)
    end

    def calculate_recommendation_level
      rand(0..2)
    end

    # ============================================================================
    # Condition Evaluation (The "Logic" Layer)
    # ============================================================================

    def matches_condition?(condition_string)
      return true if condition_string == "true"
      return false if condition_string == "false"

      ConditionEvaluator.new(@party_stats, @demographics).evaluate(condition_string)
    end
  end
end
