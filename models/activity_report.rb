class ActivityReport < ::Activity
  def self.policy_class
    ActiveAdmin::ActivityReportPolicy
  end
end
