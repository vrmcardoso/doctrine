class CreateCampaigns < ActiveRecord::Migration[8.1]
  def change
    create_table :campaigns do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :archetype_handle
      t.integer :current_week
      t.boolean :completed
      t.jsonb :state_snapshot

      t.timestamps
    end
  end
end
