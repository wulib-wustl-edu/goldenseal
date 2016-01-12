module ApplicationHelper
  def formatted_time(search_results)
    datetime = search_results.fetch(:value)
    datetime.in_time_zone.strftime("%F %R %Z")
  end
end
