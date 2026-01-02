module GameEngine
  # ConditionEvaluator: Parses and evaluates condition strings against game state
  # Supports conditions like: "party.narrative_coherence < 0.4"
  # and: "demographics.youth.loyalty > 0.7"
  class ConditionEvaluator
    OPERATORS = {
      ">" => :>,
      "<" => :<,
      ">=" => :>=,
      "<=" => :<=,
      "==" => :==,
      "!=" => :!=
    }.freeze

    def initialize(party_stats, demographics)
      @party_stats = party_stats
      @demographics = demographics
    end

    def evaluate(condition_string)
      return true if condition_string == "true"
      return false if condition_string == "false"

      # Split by logical operators (&&, ||) while preserving structure
      if condition_string.include?("&&")
        parts = condition_string.split("&&").map(&:strip)
        return parts.all? { |part| evaluate(part) }
      end

      if condition_string.include?("||")
        parts = condition_string.split("||").map(&:strip)
        return parts.any? { |part| evaluate(part) }
      end

      # Evaluate single condition
      evaluate_single_condition(condition_string)
    end

    private

    def evaluate_single_condition(condition)
      # Find the operator
      operator_match = OPERATORS.keys.find { |op| condition.include?(op) }
      return false unless operator_match

      parts = condition.split(operator_match).map(&:strip)
      return false unless parts.length == 2

      left_value = resolve_value(parts[0])
      right_value = resolve_value(parts[1])

      # Perform the comparison
      left_value.send(OPERATORS[operator_match], right_value)
    rescue StandardError => e
      # Log error and return false for safety
      Rails.logger.warn("BriefingEngine: Failed to evaluate condition '#{condition}': #{e.message}")
      false
    end

    def resolve_value(value_string)
      value_string = value_string.strip

      # If it starts with a quote, it's a string literal
      return value_string[1...-1] if value_string.start_with?('"') && value_string.end_with?('"')

      # If it's numeric, convert to number
      return value_string.to_f if value_string.match?(/^\d+\.?\d*$/)

      # Otherwise, try to resolve from game state
      resolve_from_game_state(value_string)
    end

    def resolve_from_game_state(path)
      # Path format: "party.narrative_coherence" or "demographics.youth.loyalty"
      parts = path.split(".")

      if parts[0] == "party"
        resolve_party_stat(parts[1..].join("."))
      elsif parts[0] == "demographics"
        resolve_demographic(parts[1..].join("."))
      else
        # Unknown path, return 0
        0.0
      end
    end

    def resolve_party_stat(stat_path)
      # stat_path is like "narrative_coherence"
      # Access @party_stats[stat_path] with nested support
      parts = stat_path.split(".")
      value = @party_stats

      parts.each do |part|
        value = value.is_a?(Hash) ? value[part] : nil
        return 0.0 if value.nil?
      end

      value.is_a?(Numeric) ? value : 0.0
    end

    def resolve_demographic(demo_path)
      # demo_path is like "youth.loyalty"
      parts = demo_path.split(".")
      demographic_name = parts[0]
      stat_name = parts[1..].join(".")

      # Find the demographic by name (case-insensitive)
      demographic = @demographics.find do |d|
        (d.is_a?(Hash) ? d["name"]&.downcase : d.name&.downcase) == demographic_name.downcase
      end

      return 0.0 unless demographic

      # Access the stat from the demographic
      value = demographic.is_a?(Hash) ? demographic[stat_name] : demographic.send(stat_name) rescue nil
      value.is_a?(Numeric) ? value : 0.0
    end
  end
end
