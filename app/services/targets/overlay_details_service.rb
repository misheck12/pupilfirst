module Targets
  class OverlayDetailsService
    include RoutesResolvable

    def initialize(target, founder)
      @target = target
      @founder = founder
    end

    def all_details
      {
        pendingFounderIds: pending_founder_ids,
        latestEvent: latest_event_details,
        latestFeedback: latest_feedback,
        linkedResources: linked_resources,
        quizQuestions: quiz_questions
      }
    end

    private

    def pending_founder_ids
      @founder.startup.founders.where.not(id: @founder).reject do |founder|
        founder.exited? || founder.timeline_events.where(target: @target).passed.exists?
      end.map(&:id)
    end

    def latest_event_details
      return nil if latest_event.blank?

      {
        description: latest_event.description,
        event_on: latest_event.event_on,
        title: latest_event.title,
        days_elapsed: latest_event.days_elapsed,
        attachments: latest_event_attachments
      }
    end

    def latest_event
      @latest_event ||= @target.latest_linked_event(@founder)
    end

    def latest_feedback
      Targets::FeedbackService.new(@target, @founder).latest_feedback_details
    end

    def latest_event_attachments
      return nil if latest_event.blank?

      attachments = latest_event.timeline_event_files.each_with_object([]) do |file, array|
        array << { type: "file", title: file.title, url: url_helpers.download_timeline_event_file_path(file) }
      end

      latest_event.links.each_with_object(attachments) do |link, array|
        array << { type: "link", title: link[:title], url: link[:url] }
      end
    end

    def linked_resources
      return if @target.resources.blank?

      @target.resources.map do |resource|
        {
          id: resource.id,
          title: resource.title,
          slug: resource.slug,
          canStream: resource.stream?,
          hasLink: resource.link.present?,
          hasFile: resource.file_as.attached?
        }
      end
    end

    def quiz_questions
      return [] if @target.quiz.blank?

      @target.quiz.quiz_questions.each_with_index.map do |question, index|
        {
          index: index,
          question: question.question,
          description: question.description,
          correctAnswerId: question.correct_answer_id,
          answerOptions: answer_options(question).shuffle
        }
      end
    end

    def answer_options(question)
      question.answer_options.map do |answer|
        {
          id: answer.id,
          value: answer.value,
          hint: answer.hint
        }
      end
    end
  end
end
