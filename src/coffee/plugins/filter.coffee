class Filter

  constructor: ->
    @tmpCanvas = document.createElement('canvas')
    @tmpCtx = @tmpCanvas.getContext('2d')

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

  threshold : (pixels, threshold) ->
    d = pixels.data
    i = 0

    while i < d.length
      r = d[i]
      g = d[i + 1]
      b = d[i + 2]
      v = (if (0.2126 * r + 0.7152 * g + 0.0722 * b >= threshold) then 255 else 0)
      d[i] = d[i + 1] = d[i + 2] = v
      i += 4
    pixels

  convolute : (pixels, weights, opaque = 1) =>
    side = Math.round(Math.sqrt(weights.length))
    halfSide = Math.floor(side / 2)
    src = pixels.data
    sw = pixels.width
    sh = pixels.height
    
    # pad output by the convolution matrix
    w = sw
    h = sh
    output = @createImageData(w, h)
    dst = output.data
    
    # go through the destination image pixels
    alphaFac = (if opaque then 1 else 0)
    y = 0
    counter = 0
    while y < h
      x = 0

      while x < w
        sy = y
        sx = x
        dstOff = (y * w + x) * 4
        
        # calculate the weighed sum of the source image pixels that
        # fall under the convolution matrix
        r = 0
        g = 0
        b = 0
        a = 0
        cy = 0

        while cy < side
          cx = 0

          while cx < side
            scy = sy + cy - halfSide
            scx = sx + cx - halfSide
            if scy >= 0 and scy < sh and scx >= 0 and scx < sw
              srcOff = (scy * sw + scx) * 4
              wt = weights[cy * side + cx]
              r += src[srcOff] * wt
              g += src[srcOff + 1] * wt
              b += src[srcOff + 2] * wt
              a += src[srcOff + 3] * wt
            cx++
          cy++
        if r > 0xFF
          r = 0xFF
        if r < 0
          r = 0
        if g > 0xFF
          g = 0xFF
        if g < 0
          g = 0
        if b > 0xFF
          b = 0xFF
        if b < 0
          b = 0
        if a > 0xFF
          a = 0xFF
        if a < 0
          a = 0
        dst[dstOff] = r
        dst[dstOff + 1] = g
        dst[dstOff + 2] = b
        dst[dstOff + 3] = a + alphaFac * (255 - a)
        x++
      y++
    console.log(counter)
    output

  createImageData : (w, h) ->
    @tmpCtx.createImageData w, h