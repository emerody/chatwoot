class CreateCrmContactStages < ActiveRecord::Migration[7.0]
  def change
    create_table :crm_contact_stages do |t|
      t.references :contact, null: false, foreign_key: true
      t.references :stage, null: false, foreign_key: { to_table: :crm_stages }
      t.references :account, null: false, foreign_key: true
      t.timestamp :moved_at

      t.timestamps
    end

    add_index :crm_contact_stages, [:contact_id, :account_id], unique: true
    add_index :crm_contact_stages, :stage_id
    add_index :crm_contact_stages, :moved_at
  end
end

