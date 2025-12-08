class CampaignsController < ApplicationController
  # Standard Rails 8 auth is active by default here (no allow_unauthenticated_access)

  def index
    if Current.user.campaigns.empty?
      redirect_to new_campaign_path and return
    end
    @campaigns = Current.user.campaigns.order(updated_at: :desc)
  end

  def new
    # The "New Game" Screen
    @parties = Party.all
    @campaign = Campaign.new
  end

  def create
    # 1. Generate the simulation state using the Service
    initial_state = GameEngine::CampaignGenerator.run(params[:party_handle])

    party = Party.find_by(handle: params[:party_handle])

    @campaign = Current.user.campaigns.build(
      title: "#{party.name} Campaign",
      archetype_handle: params[:party_handle],
      current_week: 1,
      completed: false,
      state_snapshot: initial_state
    )

    if @campaign.save
      redirect_to campaign_path(@campaign)
    else
      redirect_to new_campaign_path, alert: "Initialization failed."
    end
  end

  def show
    # The actual gameplay view
    @campaign = Current.user.campaigns.find(params[:id])
    @state = @campaign.state_snapshot
  end
end
