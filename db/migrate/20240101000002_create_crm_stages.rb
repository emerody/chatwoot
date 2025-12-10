class CreateCrmStages < ActiveRecord::Migration[7.0]
  def change
    create_table :crm_stages do |t|
      t.references :pipeline, null: false, foreign_key: { to_table: :crm_pipelines }
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :position, null: false
      t.string :color, limit: 7

      t.timestamps
    end

    add_index :crm_stages, [:pipeline_id, :position]
    add_index :crm_stages, :account_id
  end
end

