#@codekit-prepend "filter.coffee"

class Camera
  navigator.getUserMedia = navigator.getUserMedia or navigator.webkitGetUserMedia or navigator.mozGetUserMedia

  init: (@videoElement, @canvasElement) ->
    @context = @canvasElement.getContext('2d');
    @filter = new Filter

    do @checkBrowserSupport

  checkBrowserSupport: ->
    if typeof MediaStreamTrack is "undefined"
      alert "This browser does not support MediaStreamTrack.\n\nTry Chrome Canary."
    else
      MediaStreamTrack.getSources @start
      
      setTimeout =>
        do @draw
      , 5000

      do @set_triggers

  set_triggers: ->
    $('#print').click @draw

    $('#grayscale').click =>
      @runFilter @filter.grayscale

    $('#brightness').click =>
      @runFilter @filter.brightness, 40
      
  start: (sourceInfos) =>
    videoSource = _.find sourceInfos, {'kind' : 'video'}

    unless not window.stream
      @videoElement.src = null
      window.stream.stop()

    constraints =
      video:
        optional: [sourceId: videoSource]

    navigator.getUserMedia constraints, @successCallback, @errorCallback

  draw: () =>
    return false  if @videoElement.paused or @videoElement.ended
    @context.drawImage @videoElement, 0, 0, @canvasElement.width, @canvasElement.height
    uri = @canvasElement.toDataURL("image/png")

    @filter.getPixels @context

  successCallback : (stream) =>
    window.stream = stream # make stream available to console
    @videoElement.src = window.URL.createObjectURL(stream)
    @videoElement.play()
  
  errorCallback : (error) =>
    console.log "navigator.getUserMedia error: ", error

  runFilter: (filter, params) ->
    if params
      pixels = @filter.filterImage(filter, @context, params)
    else
      pixels = @filter.filterImage(filter, @context)

    @context.putImageData(pixels, 0, 0);

$(document).ready(->
  canvas = $('#canvas')[0]
  video = $('#webcam')[0]

  camera = new Camera
  camera.init(video, canvas)
)