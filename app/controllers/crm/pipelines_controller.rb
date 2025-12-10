module Crm
  class PipelinesController < ApplicationController
    before_action :set_account
    before_action :set_pipeline, only: [:show]

    def show
      @pipeline = @account.crm_pipelines.default_pipeline.first || create_default_pipeline
      @stages = @pipeline.stages.ordered.includes(:contacts)
      
      render json: {
        pipeline: pipeline_json(@pipeline),
        stages: @stages.map { |stage| stage_json(stage) }
      }
    end

    private

    def set_account
      @account = current_user.account
    end

    def set_pipeline
      @pipeline = @account.crm_pipelines.find_by(id: params[:id]) || 
                  @account.crm_pipelines.default_pipeline.first ||
                  create_default_pipeline
    end

    def create_default_pipeline
      pipeline = Crm::Pipeline.create!(
        account: @account,
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
      {
        id: stage.id,
        name: stage.name,
        position: stage.position,
        color: stage.color,
        contacts_count: stage.contacts_count,
        contacts: stage.contacts.limit(50).map { |contact| contact_json(contact) }
      }
    end

    def contact_json(contact)
      {
        id: contact.id,
        name: contact.name,
        email: contact.email,
        phone: contact.phone_number,
        avatar_url: contact.avatar_url,
        identifier: contact.identifier
      }
    end
  end
end

