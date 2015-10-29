class SearchWorksItemController < ApplicationController
  def show
    item = SearchWorksItem.new(params[:id])
    if item.exists?
      render json: { collection: item.collection }
    else
      render json: { error: 'SearchWorks item does not exist' }
    end
  end
end
