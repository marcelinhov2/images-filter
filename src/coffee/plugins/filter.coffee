class Filter

  getPixels: (context) ->
    canvas = context.canvas

    return context.getImageData(0,0,canvas.width,canvas.height)

  filterImage: (filter, context, var_args) ->
    args = [@getPixels(context)]

    i = 2

    while i < arguments.length
      args.push arguments[i]
      i++

    return filter.apply null, args

  grayscale : (pixels, args) ->
    d = pixels.data
    i = 0

    while i < d.length
      r = d[i]
      g = d[i + 1]
      b = d[i + 2]
      
      # CIE luminance for the RGB
      # The human eye is bad at seeing red and blue, so we de-emphasize them.
      v = 0.2126 * r + 0.7152 * g + 0.0722 * b
      d[i] = d[i + 1] = d[i + 2] = v
      i += 4

    pixels

  brightness : (pixels, adjustment) ->
    d = pixels.data
    i = 0

    while i < d.length
      d[i] += adjustment
      d[i + 1] += adjustment
      d[i + 2] += adjustment
      i += 4
    pixels