module Api
  module V1
    module Accounts
      module Crm
        class ContactsController < Api::V1::Accounts::BaseController
          before_action :set_contact, only: [:move_to_stage]

          def move_to_stage
            stage = current_account.crm_stages.find(params[:stage_id])
            
            # Usar transação para garantir atomicidade
            ActiveRecord::Base.transaction do
              # Remove contato do stage anterior se existir
              # Usando delete_all para execução imediata sem callbacks
              deleted_count = current_account.crm_contact_stages
                .where(contact_id: @contact.id)
                .delete_all
              
              # Adiciona ao novo stage com timestamp
              contact_stage = current_account.crm_contact_stages.create!(
                contact: @contact,
                stage: stage,
                account: current_account,
                moved_at: Time.current
              )
            end

            # Recarrega o contato para garantir dados atualizados
            @contact.reload

            render json: {
              success: true,
              contact: contact_json(@contact),
              stage: {
                id: stage.id,
                name: stage.name
              }
            }
          end

          def contacts_in_stage
            stage = current_account.crm_stages.find(params[:stage_id])
            contacts = stage.contacts.includes(:crm_contact_stages)
            
            render json: {
              stage_id: stage.id,
              contacts: contacts.map { |contact| contact_json(contact) }
            }
          end

          private

          def set_contact
            @contact = current_account.contacts.find(params[:id])
          end

          def contact_json(contact)
            {
              id: contact.id,
              name: contact.name,
              email: contact.email,
              phone: contact.phone_number,
              avatar_url: contact.avatar_url,
              identifier: contact.identifier,
              current_stage: contact.crm_stage_for_account(current_account.id)&.id
            }
          end
        end
      end
    end
  end
end


