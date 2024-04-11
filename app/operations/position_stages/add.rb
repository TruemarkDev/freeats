# frozen_string_literal: true

class PositionStages::Add
  include Dry::Monads[:result, :try, :do]

  # TODO: pass actor_account
  include Dry::Initializer.define -> do
    option :params, Types::Strict::Hash.schema(
      list_index: Types::Params::Integer,
      name: Types::Params::String,
      position: Types::Instance(Position)
    )
    option :actor_account, Types::Instance(Account)
  end

  def call
    position_stage = PositionStage.new(params)

    ActiveRecord::Base.transaction do
      yield save_position_stage(position_stage)
      yield add_event(position_stage:, actor_account:)
    end

    Success()
  end

  private

  def save_position_stage(position_stage)
    result = Try[ActiveRecord::RecordInvalid] do
      position_stage.save!
    end.to_result

    case result
    in Success(_)
      Success()
    in Failure[ActiveRecord::RecordInvalid => e]
      Failure[:position_stage_invalid, position_stage.errors.full_messages.presence || e.to_s]
    end
  end

  def add_event(position_stage:, actor_account:)
    position_stage_added_params = {
      actor_account:,
      type: :position_stage_added,
      eventable: position_stage,
      properties: { name: position_stage.name }
    }

    yield Events::Add.new(params: position_stage_added_params).call

    Success()
  end
end
