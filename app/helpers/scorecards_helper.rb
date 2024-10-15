# frozen_string_literal: true

module ScorecardsHelper
  def score_icon(score, with_text: false)
    case score
    when "irrelevant"
      label_tag(:score_irrelevant, class: "text-danger") do
        concat(content_tag(:i, nil, class: "fas fa-frown"))
        if with_text
          concat(
            content_tag(:span, class: "ms-2") do
              t("candidates.advancement.irrelevant")
            end
          )
        end
      end
    when "relevant"
      label_tag(:score_relevant, class: "text-warning") do
        concat(content_tag(:i, nil, class: "fas fa-meh"))
        if with_text
          concat(
            content_tag(:span, class: "ms-2") do
              t("candidates.advancement.might_be_irrelevant")
            end
          )
        end
      end
    when "good"
      label_tag(:score_good, class: "text-success") do
        concat(content_tag(:i, nil, class: "fas fa-smile"))
        if with_text
          concat(
            content_tag(:span, class: "ms-2") do
              t("candidates.advancement.good_candidate")
            end
          )
        end
      end
    when "perfect"
      label_tag(:score_perfect, class: "text-info") do
        concat(content_tag(:i, nil, class: "fas fa-grin-stars"))
        if with_text
          concat(
            content_tag(:span, class: "ms-2") do
              t("candidates.advancement.perfect_candidate")
            end
          )
        end
      end
    end
  end

  def visible_stages(placement)
    placement.position.stages_including_deleted.filter do |stage|
      stage.scorecard_template.present? &&
        (stage.list_index <= placement.position_stage.list_index && !stage.deleted) ||
        placement.scorecards.any? { _1.position_stage_id == stage.id }
    end
  end
end
