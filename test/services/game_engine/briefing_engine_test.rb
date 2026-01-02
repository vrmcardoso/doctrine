require "test_helper"

module GameEngine
  class BriefingEngineTest < ActiveSupport::TestCase
    test "generates briefing packet with all three layers" do
      game_state = {
        "week" => 1,
        "party_stats" => {
          "narrative_coherence" => 0.5,
          "narrative_control" => 0.6,
          "faction_integrity" => 0.4,
          "moral_conditioning_index" => 0.3
        },
        "demographics" => [
          { "id" => 1, "name" => "Older Voters", "loyalty" => 0.6, "dissonance" => 0.2 },
          { "id" => 2, "name" => "Youth & Students", "loyalty" => 0.5, "dissonance" => 0.3 }
        ]
      }

      briefing = BriefingEngine.generate_briefing(game_state)

      # Verify all three layers are present
      assert briefing.key?(:advisor_reports)
      assert briefing.key?(:visual_manifest)
      assert briefing.key?(:strategic_directions)
      assert briefing.key?(:agenda_locked)
      assert_equal true, briefing[:agenda_locked]

      # Verify visual manifest structure
      visual = briefing[:visual_manifest]
      assert visual.key?(:glitch_intensity)
      assert visual.key?(:fracture_state)
      assert visual.key?(:palette_corruption)
      assert visual.key?(:aesthetic_mode)

      # Verify strategic directions structure
      directions = briefing[:strategic_directions]
      assert directions.key?(:available_directions)
      assert directions.key?(:selection_required)
      assert_equal true, directions[:selection_required]
      assert directions[:available_directions].length <= 3
      assert directions[:available_directions].length >= 1
    end

    test "applies moral equivalence system when moral_conditioning is high" do
      high_moral_state = {
        "week" => 1,
        "party_stats" => {
          "narrative_coherence" => 0.3,
          "narrative_control" => 0.4,
          "faction_integrity" => 0.5,
          "moral_conditioning_index" => 0.8  # High moral conditioning
        },
        "demographics" => []
      }

      briefing = BriefingEngine.generate_briefing(high_moral_state)
      advisor_reports = briefing[:advisor_reports]

      # When moral conditioning is high, cynical messages should be selected
      # Find a report that should have cynical content
      crisis_report = advisor_reports.find { |r| r[:message].include?("cynical") || r[:message].include?("trained") }
      assert crisis_report.present?, "Should have at least one cynical message when moral_conditioning > 0.5"
    end

    test "generates correct glitch_intensity based on narrative coherence" do
      low_coherence_state = {
        "week" => 1,
        "party_stats" => {
          "narrative_coherence" => 0.2,
          "narrative_control" => 0.1,
          "faction_integrity" => 0.5,
          "moral_conditioning_index" => 0.0
        },
        "demographics" => []
      }

      briefing = BriefingEngine.generate_briefing(low_coherence_state)
      glitch = briefing[:visual_manifest][:glitch_intensity]

      assert_equal "severe", glitch[:level]
      assert_equal 0.15, glitch[:chromatic_aberration]
      assert_equal 0.8, glitch[:ui_noise]
    end

    test "generates correct palette_corruption based on moral_conditioning" do
      high_moral_state = {
        "week" => 1,
        "party_stats" => {
          "narrative_coherence" => 0.5,
          "narrative_control" => 0.5,
          "faction_integrity" => 0.5,
          "moral_conditioning_index" => 0.8  # High moral conditioning
        },
        "demographics" => []
      }

      briefing = BriefingEngine.generate_briefing(high_moral_state)
      palette = briefing[:visual_manifest][:palette_corruption]

      assert_equal "severe", palette[:level]
      assert_equal "sickly_yellow_green", palette[:shift_direction]
      assert_equal 0.8, palette[:corruption_percentage]
      assert palette[:primary_color_override].present?
    end

    test "filters briefing items by condition" do
      # State that should trigger narrative crisis
      crisis_state = {
        "week" => 1,
        "party_stats" => {
          "narrative_coherence" => 0.3,  # Below 0.4 threshold
          "narrative_control" => 0.5,
          "faction_integrity" => 0.5,
          "moral_conditioning_index" => 0.0
        },
        "demographics" => []
      }

      briefing = BriefingEngine.generate_briefing(crisis_state)
      reports = briefing[:advisor_reports]

      # Should have a crisis report about narrative fracturing
      crisis_report = reports.find { |r| r[:priority] == "high" }
      assert crisis_report.present?
      assert crisis_report[:message].include?("fractur")
    end

    test "returns available strategic directions filtered by condition" do
      state = {
        "week" => 1,
        "party_stats" => {
          "narrative_coherence" => 0.8,
          "narrative_control" => 0.8,
          "faction_integrity" => 0.7,
          "moral_conditioning_index" => 0.2
        },
        "demographics" => []
      }

      briefing = BriefingEngine.generate_briefing(state)
      directions = briefing[:strategic_directions]

      assert directions[:available_directions].length > 0
      assert directions[:available_directions].length <= 3

      # Each direction should have required fields
      directions[:available_directions].each do |direction|
        assert direction[:title].present?
        assert direction[:narrative_hook].present?
        assert direction[:global_modifiers].is_a?(Hash)
      end
    end

    test "condition evaluator handles complex conditions" do
      game_state = {
        "week" => 1,
        "party_stats" => {
          "narrative_coherence" => 0.3,
          "narrative_control" => 0.2,
          "faction_integrity" => 0.25,
          "moral_conditioning_index" => 0.0
        },
        "demographics" => []
      }

      # This condition should match (both parts true)
      evaluator = GameEngine::ConditionEvaluator.new(
        game_state["party_stats"],
        game_state["demographics"]
      )

      result = evaluator.evaluate("party.narrative_coherence < 0.4 && party.faction_integrity < 0.3")
      assert_equal true, result

      # This condition should not match (second part false)
      result = evaluator.evaluate("party.narrative_coherence < 0.4 && party.faction_integrity > 0.5")
      assert_equal false, result
    end

    test "briefing engine is stateless and can be called multiple times" do
      state1 = {
        "party_stats" => {
          "narrative_coherence" => 0.9,
          "narrative_control" => 0.9,
          "faction_integrity" => 0.9,
          "moral_conditioning_index" => 0.0
        },
        "demographics" => []
      }

      state2 = {
        "party_stats" => {
          "narrative_coherence" => 0.2,
          "narrative_control" => 0.2,
          "faction_integrity" => 0.2,
          "moral_conditioning_index" => 0.9
        },
        "demographics" => []
      }

      briefing1 = BriefingEngine.generate_briefing(state1)
      briefing2 = BriefingEngine.generate_briefing(state2)

      # Both should generate valid briefings
      assert briefing1[:visual_manifest][:glitch_intensity][:level] != briefing2[:visual_manifest][:glitch_intensity][:level]
      assert briefing1[:visual_manifest][:palette_corruption][:level] != briefing2[:visual_manifest][:palette_corruption][:level]
    end
  end
end
