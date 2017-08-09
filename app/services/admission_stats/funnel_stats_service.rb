module AdmissionStats
  class FunnelStatsService
    # @param start_time [DateTime, String] (Optional) Default to beginning of yesterday.
    # @param end_time [DateTime, String] (Optional) Defaults to end of yesterday.
    def initialize(start_time = nil, end_time = nil)
      start_time ||= 1.day.ago.beginning_of_day
      end_time ||= 1.day.ago.end_of_day
      start_time = Date.parse(start_time).beginning_of_day if start_time.is_a?(String)
      end_time = Date.parse(end_time).end_of_day if end_time.is_a?(String)
      @date_range = start_time..end_time
    end

    def load
      {
        'Total Sign Ups' => signed_up,
        'Screening Completed' => screening_completed,
        'Added Cofounders' =>  cofounders_added,
        'Payment Initiated' => payment_initiated,
        'Fee Paid' => fee_paid,
        'Revenue' => "₹#{revenue.to_i}"
      }
    end

    private

    def signed_up
      Startup.level_zero.where(created_at: @date_range).count
    end

    def screening_completed
      verified_timeline_events.joins(:target).where(targets: { key: Target::KEY_ADMISSIONS_SCREENING }).where(created_at: @date_range).count
    end

    def fee_paid
      verified_timeline_events.joins(:target).where(targets: { key: Target::KEY_ADMISSIONS_FEE_PAYMENT }).where(created_at: @date_range).count
    end

    def revenue
      Payment.where(paid_at: @date_range).sum(:amount)
    end

    def payment_initiated
      Startup.joins(:payments).where(payments: { created_at: @date_range }).count
    end

    def cofounders_added
      verified_timeline_events.joins(:target).where(targets: { key: Target::KEY_ADMISSIONS_COFOUNDER_ADDITION }).where(created_at: @date_range).count
    end

    def verified_timeline_events
      @verified_timeline_events ||= TimelineEvent.where(status: TimelineEvent::STATUS_VERIFIED)
    end
  end
end
