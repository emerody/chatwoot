module Crm
  class ContactStage < ApplicationRecord
    self.table_name = 'crm_contact_stages'

    belongs_to :contact, class_name: '::Contact'
    belongs_to :stage, class_name: 'Crm::Stage'
    belongs_to :account

    validates :contact_id, presence: true
    validates :stage_id, presence: true
    validates :account_id, presence: true
    validates :contact_id, uniqueness: { scope: :account_id, message: 'já está em um stage neste account' }

    before_create :set_moved_at

    private

    def set_moved_at
      self.moved_at = Time.current
    end
  end
end

