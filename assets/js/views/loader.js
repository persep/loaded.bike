import MainView         from "./main"
import TourShowView     from "./tour/show"
import TourEditView     from "./tour/edit"
import WaypointShowView from "./waypoint/show"
import WaypointEditView from "./waypoint/edit"
import WaypointNewView  from "./waypoint/new"

const views = {
  TourShowView,
  TourEditView,
  WaypointShowView,
  WaypointEditView,
  WaypointNewView,
}

export default function loadView(viewName){
  return views[viewName] || MainView
}
