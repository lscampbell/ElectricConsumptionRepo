module Pagination
  class PagedData
    attr_accessor :data, :total_pages, :current_page, :limit_value
    def initialize(data, total_pages, current_page, limit_value)
      self.data = data.map(&:to_hash)
      self.total_pages = total_pages
      self.current_page = current_page
      self.limit_value = limit_value
    end
  end

  def paginate(data)
    PagedData.new data, data.total_pages, data.current_page, data.limit_value
  end
end