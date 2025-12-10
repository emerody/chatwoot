module Crm
  class Stage < ApplicationRecord
    self.table_name = 'crm_stages'

    belongs_to :pipeline, class_name: 'Crm::Pipeline'
    belongs_to :account
    has_many :contact_stages, class_name: 'Crm::ContactStage', dependent: :destroy
    has_many :contacts, through: :contact_stages

    validates :name, presence: true
    validates :position, presence: true, numericality: { only_integer: true }
    validates :pipeline_id, presence: true
    validates :account_id, presence: true

    scope :ordered, -> { order(:position) }

    def contacts_count
      contact_stages.count
    end
  end
end

