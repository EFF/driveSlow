MapService = () ->
    create = (center) ->
        mapOptions =
            center: new google.maps.LatLng(center.latitude, center.longitude)
            replace: true
            zoom: 17
            mapTypeId: google.maps.MapTypeId.ROADMAP

        return new google.maps.Map(document.getElementById('map-canvas'), mapOptions)

    createPolygon = (shape, map) ->
        shape = shape[0...shape.length-1]

        polygonOptions =
            paths: []
            fillColor: 'red'
            fillOpacity: 0.4
            strokeOpacity: 0.2
            map: map

        for point in shape
            polygonOptions.paths.push(new google.maps.LatLng(parseFloat(point[1]), parseFloat(point[0])))
        
        new google.maps.Polygon(polygonOptions)

    updateMap = (map, coords) ->
        map.setCenter new google.maps.LatLng(coords.latitude, coords.longitude)
        map.setHeading coords.heading

    service =
        create: create
        createPolygon: createPolygon
        updateMap: updateMap

    return service

module.exports = MapService
