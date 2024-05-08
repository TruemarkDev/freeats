# frozen_string_literal: true

class Tasks::ChangeStatus
  include Dry::Monads[:result, :do]

  include Dry::Initializer.define -> do
    option :task, Types::Instance(Task)
    option :new_status, Types::Strict::String.enum(*Task.statuses.keys)
    option :actor_account, Types::Instance(Account)
  end

  def call
    return Success(task) if task.status == new_status

    old_values = {
      status: task.status,
      due_date: task.due_date
    }

    repeat = new_status == "closed" && task.repeating?

    if repeat
      task.due_date = new_due_date(task)
    else
      task.status = new_status
    end

    ActiveRecord::Base.transaction do
      yield save_task(task)
      yield add_task_status_changed_events(old_values:, task:, repeat:, actor_account:)
    end

    Success(task)
  end

  private

  def save_task(task)
    task.save!

    Success()
  rescue ActiveRecord::RecordInvalid => e
    Failure[:task_invalid, task.errors.full_messages.presence || e.to_s]
  end

  def add_task_status_changed_events(old_values:, task:, repeat:, actor_account:)
    if repeat
      task_status_changed_params = {
        actor_account:,
        type: :task_status_changed,
        eventable: task,
        changed_field: :status,
        changed_from: "open",
        changed_to: "closed"
      }

      yield Events::Add.new(params: task_status_changed_params).call

      task_status_changed_params = {
        actor_account: nil,
        type: :task_status_changed,
        eventable: task,
        changed_field: :status,
        changed_from: "closed",
        changed_to: "open"
      }

      yield Events::Add.new(params: task_status_changed_params).call

      task_changed_params = {
        actor_account: nil,
        type: :task_changed,
        eventable: task,
        changed_field: :due_date,
        changed_from: old_values[:due_date].to_s,
        changed_to: task.due_date.to_s
      }

      yield Events::Add.new(params: task_changed_params).call
    else
      task_status_changed_params = {
        actor_account:,
        type: :task_status_changed,
        eventable: task,
        changed_field: :status,
        changed_from: old_values[:status],
        changed_to: task.status
      }

      yield Events::Add.new(params: task_status_changed_params).call
    end

    Success()
  end

  def new_due_date(task)
    due_date = task.due_date

    case task.repeat_interval
    when "daily" then due_date.next_weekday
    when "weekly" then due_date + 1.week
    when "monthly" then due_date + 1.month
    when "yearly" then due_date + 1.year
    end
  end
end
