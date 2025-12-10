class CreateDefaultPipeline < ActiveRecord::Migration[7.0]
  def up
    # Criar pipeline padrão para cada account existente
    Account.find_each do |account|
      pipeline = Crm::Pipeline.create!(
        account: account,
        name: 'Pipeline Padrão',
        is_default: true
      )

      # Criar stages padrão
      default_stages = [
        { name: 'Novo', position: 1 },
        { name: 'Em Contato', position: 2 },
        { name: 'Qualificado', position: 3 },
        { name: 'Fechado', position: 4 }
      ]

      default_stages.each do |stage_data|
        Crm::Stage.create!(
          pipeline: pipeline,
          account: account,
          name: stage_data[:name],
          position: stage_data[:position]
        )
      end
    end
  end

  def down
    Crm::Pipeline.where(is_default: true).destroy_all
  end
end

