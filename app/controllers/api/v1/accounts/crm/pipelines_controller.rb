module Api
  module V1
    module Accounts
      module Crm
        class PipelinesController < Api::V1::Accounts::BaseController
          def show
            @pipeline = current_account.crm_pipelines.find_by(id: params[:id]) || 
                        current_account.crm_pipelines.default_pipeline.first ||
                        create_default_pipeline
            @stages = @pipeline.stages.ordered.includes(contact_stages: :contact)
            
            render json: {
              pipeline: pipeline_json(@pipeline),
              stages: @stages.map { |stage| stage_json(stage) }
            }
          end

          def default
            @pipeline = current_account.crm_pipelines.default_pipeline.first || create_default_pipeline
            @stages = @pipeline.stages.ordered.includes(contact_stages: :contact)
            
            render json: {
              pipeline: pipeline_json(@pipeline),
              stages: @stages.map { |stage| stage_json(stage) }
            }
          end

          private

          def create_default_pipeline
            pipeline = ::Crm::Pipeline.create!(
              account: current_account,
              name: 'Pipeline Padrão',
              is_default: true
            )
            pipeline
          end

          def pipeline_json(pipeline)
            {
              id: pipeline.id,
              name: pipeline.name,
              is_default: pipeline.is_default
            }
          end

          def stage_json(stage)
            # Buscar contatos que estão atualmente neste stage
            # Como temos validação uniqueness, cada contato só pode ter um registro por account
            contact_stages = stage.contact_stages
              .includes(:contact)
              .order('crm_contact_stages.moved_at DESC')
              .limit(50)
            
            contacts = contact_stages.map(&:contact).compact.uniq
            
            Rails.logger.info "[CRM] Stage #{stage.id} (#{stage.name}): #{contacts.count} contatos encontrados"
            contacts.each do |contact|
              current_stage = contact.crm_stage_for_account(current_account.id)
              Rails.logger.info "[CRM]   - Contato #{contact.id} (#{contact.name}): stage atual=#{current_stage&.id} (#{current_stage&.name}), esperado=#{stage.id}"
            end

            {
              id: stage.id,
              name: stage.name,
              position: stage.position,
              color: stage.color,
              contacts_count: stage.contact_stages.count,
              contacts: contacts.map { |contact| contact_json(contact) }
            }
          end

          def contact_json(contact)
            {
              id: contact.id,
              name: contact.name,
              email: contact.email,
              phone_number: contact.phone_number,
              avatar_url: contact.avatar_url,
              identifier: contact.identifier
            }
          end
        end
      end
    end
  end
end


