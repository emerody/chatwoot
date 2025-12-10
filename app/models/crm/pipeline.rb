module Crm
  class Pipeline < ApplicationRecord
    self.table_name = 'crm_pipelines'

    belongs_to :account
    has_many :stages, class_name: 'Crm::Stage', dependent: :destroy
    has_many :contact_stages, class_name: 'Crm::ContactStage', through: :stages

    validates :name, presence: true
    validates :account_id, presence: true

    scope :default_pipeline, -> { where(is_default: true) }

    after_create :create_default_stages, if: :is_default?

    private

    def create_default_stages
      default_stage_names = ['Novo', 'Em Contato', 'Qualificado', 'Fechado']
      default_stage_names.each_with_index do |name, index|
        stages.create!(
          name: name,
          position: index + 1,
          account_id: account_id
        )
      end
    end
  end
end

