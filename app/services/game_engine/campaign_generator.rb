module GameEngine
  class CampaignGenerator
    def self.run(party_handle)
      # 1. Fetch the static archetype
      party = Party.find_by(handle: party_handle)
      raise "Invalid Party Handle" unless party

      # 2. Construct the Initial State
      {
        week: 1,
        funds: 5000, # Starting budget

        # [GDD Source: 38] Party Simulation Variables
        party_stats: {
          narrative_coherence: 1.0,      # Starts perfect
          narrative_control: 0.8,        # High initial control
          faction_integrity: 0.7,        # Some initial tension
          moral_conditioning_index: 0.0  # Base is not yet conditioned
        },

        # [GDD Source: 40] Voter Simulation Variables
        # We initialize every demographic based on the yaml rules
        demographics: initialize_demographics(party)
      }
    end

    private

    def self.initialize_demographics(selected_party)
      Demographic.all.map do |demo|
        # Determine if this demographic leans toward the player's party
        is_base = demo.party_lean.include?(selected_party.handle)

        {
          id: demo.id,
          name: demo.name,

          # [GDD Source: 40] Dynamic Variables
          loyalty: is_base ? 0.7 : 0.2,            # Higher if they lean your way
          dissonance: 0.0,                         # Starts at zero
          tolerance: demo.base_dissonance_threshold, # Loaded from YAML

          # Track alignment with specific narratives (empty at start)
          active_narratives: {}
        }
      end
    end
  end
end
