defmodule LoadedBike.Web.TourView do
  use LoadedBike.Web, :view
  import Kerosene.HTML

  def waypoint_css_class(tour, index) do
    total = length(tour.waypoints)
    cond do
      index == 0 ->
        "start"
      index == total - 1 && tour.status == :completed ->
        "finish"
      rem(index + 1, 7) == 0 ->
        "week"
      true ->
        ""
    end
  end

  def status_badge(:completed) do
    content_tag(:span, "Completed", class: "badge badge-pill badge-success")
  end

  def status_badge(:active) do
    content_tag(:span, "On the road", class: "badge badge-pill badge-warning")
  end

  def status_badge(:planned) do
    content_tag(:span, "Planned", class: "badge badge-pill badge-default")
  end
end