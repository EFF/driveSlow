MapService = () ->
    create = (center) ->
        mapOptions =
            center: new google.maps.LatLng(center.latitude, center.longitude)
            replace: true
            zoom: 15
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

    return {
        create: create
        createPolygon: createPolygon
    }

module.exports = MapService
