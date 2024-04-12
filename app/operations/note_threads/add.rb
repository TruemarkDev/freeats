# frozen_string_literal: true

class NoteThreads::Add
  include Dry::Monads[:result, :try]

  include Dry::Initializer.define -> do
    option :params, Types::Strict::Hash.schema(
      candidate_id: Types::Params::Integer
    )
    option :actor_account, Types::Instance(Account)
  end

  def call
    notable_id, notable_type =
      case params
      in { candidate_id: candidate_id }
        [candidate_id, "Candidate"]
      end

    note_thread = NoteThread.new(
      notable_id:,
      notable_type:
    )

    result = Try[ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique] do
      note_thread.save!
    end.to_result

    case result
    in Success(_)
      Success(note_thread)
    in Failure[ActiveRecord::RecordInvalid => e]
      Failure[:note_thread_invalid, note_thread.errors.full_messages.presence || e.to_s]
    in Failure[ActiveRecord::RecordNotUnique => e]
      Failure[:note_thread_not_unique, note_thread.errors.full_messages.presence || e.to_s]
    end
  end
end
