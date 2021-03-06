import MainView from "../../main"
import Map      from "../../map"

export default class UserTourShowView extends MainView {
  mount(){
    super.mount()

    var map = new Map()
    map.init()
    map.loadMarkers()
    map.centerMarkers()
  }

  unmount(){
    super.unmount()
  }
}
