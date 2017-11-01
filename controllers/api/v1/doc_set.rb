module API
  module V1
    class DocSet < Grape::API
      include API::V1::Defaults

      resource :docsets do
        desc 'Return count of all DocumentSets'
        get 'count'  do
          DocumentSet.count
        end
      end

      resource :docset do
        desc 'Return a Document Set'
        params do
          requires :id, type: String, desc: 'The DocumentSet ID'
        end

        route_param :id, root: 'docset' do
          get do
            DocumentSet.find(params[:id])
          end

          get 'state' do
            DocumentSet.where(id: params[:id]).pluck('state').first.titleize
          end
        end
      end
    end
  end
end
