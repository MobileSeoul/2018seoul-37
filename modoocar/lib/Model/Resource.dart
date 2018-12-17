class ModooCarResource {
  
  double defaultZoom;
  
  double maxZoom;
  double markerIconSize;
  double markerWidth;
  double markerHeight;
  double buttonWidth;
  double buttonHeigth;
  
  ModooCarResource(){
    this.defaultZoom = 13.0;
    this.maxZoom = 17.0;
    this.markerIconSize = 27.0;
    this.markerWidth = 55.0;
    this.markerHeight = 55.0;
    this.buttonWidth = 45.0;
    this.buttonHeigth = 20.0;
  }
}

class EntAssetsImages{
  String socarMarker;
  String socarLogo;
  String greencarMarker;
  String greencarLogo;
  

  EntAssetsImages(){
    this.socarMarker = "assets/icon/socar_marker.png";
    this.socarLogo = "assets/logo/socar_logo.png";
    this.greencarMarker = "assets/icon/greencar_marker.png";
    this.greencarLogo = "assets/logo/greencar_logo.png";
  }
}

class FilterImage {
  String socar;
  String greencar;
  String all;

  FilterImage(){
    this.socar = "assets/logo/socar_filter.png";
    this.greencar = "assets/logo/greencar_filter.png";
    this.all = "assets/logo/refresh_filter.png";
  }
  
}


var filterName = [ "all","그린카", "쏘카"];