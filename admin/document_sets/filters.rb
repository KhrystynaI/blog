module Admin
  module DocumentSets
    module Filters

      def self.included(base)
        base.filter :doc_id, label: 'Doc Set ID', filters: [:equals, :contains]
        base.filter :title
        base.filter :customer
        base.filter :expiry_date
        base.filter :assignee, as: :select, collection: -> { User.employees }
        base.filter :created_at, label: 'Date Created'
        base.filter :updated_at, label: 'Date Modified'
        base.filter :tags
        base.filter :state, as: :select, collection: DocumentSet::STATES
        base.filter :published_at, label: 'Date Published'
        base.filter :vendor
      end
    end
  end
end
