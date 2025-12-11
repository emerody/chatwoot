module Crm
  class StagesController < Api::V1::Accounts::BaseController
    before_action :set_stage, only: [:update, :destroy]

    def update
      if @stage.update(stage_params)
        render json: stage_json(@stage), status: :ok
      else
        render json: { errors: @stage.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      if @stage.contact_stages.any?
        render json: { error: 'Não é possível deletar stage com contatos' }, status: :unprocessable_entity
      else
        @stage.destroy
        head :no_content
      end
    end

    def reorder
      params[:stages].each do |stage_data|
        stage = current_account.crm_stages.find(stage_data[:id])
        stage.update(position: stage_data[:position])
      end
      render json: { success: true }
    end

    private

    def set_stage
      @stage = current_account.crm_stages.find(params[:id])
    end

    def stage_params
      params.require(:stage).permit(:name, :position, :color)
    end

    def stage_json(stage)
      {
        id: stage.id,
        name: stage.name,
        position: stage.position,
        color: stage.color
      }
    end
  end
end

