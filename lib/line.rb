require_relative 'background'

class Line
  CHR_WIDTH  = 3.5
  CHR_HEIGHT = 5.0

  include Background
  attr_reader :style

  def initialize(x1, y1, x2, y2, args={})
    style = {}
    ends_mark  = args.fetch(:ends_mark, nil)

    @start_mark = @end_mark = ends_mark

    @start_mark ||= args[:start_mark]
    @end_mark   ||= args[:end_mark]

    @mark       = args.fetch(:mark, :standard)
    @background = args.fetch(:ignore, '.')

    @height = [y1, y2].max + 32
    @width  = [x1, x2].max + 32

    @x, @y = 0, 0

    @x1, @x2, @y1, @y2 = x1, x2, y1, y2

  end

  def construct_display_array
    @display_array = background_array.dup

    startx = (@x1 + 0.5) * CHR_WIDTH
    starty = (@y1 + 0.5) * CHR_HEIGHT
    endx   = (@x2 + 0.5) * CHR_WIDTH
    endy   = (@y2 + 0.5) * CHR_HEIGHT
    difx = endx - startx
    dify = endy - starty
    dist = Math::sqrt(difx ** 2 + dify ** 2)

    stepx  = difx / dist
    stepy  = dify / dist
    step = 0

    percentx = difx.abs / (difx.abs + dify.abs)
    percenty = dify.abs / (difx.abs + dify.abs)
    stepby = CHR_WIDTH * percentx + CHR_HEIGHT * percenty
    

    curx, cury = startx, starty
    while step < dist
      precise_mark(curx, cury, difx, dify)
      curx += stepx * stepby
      cury += stepy * stepby
      step += stepby
    end
    precise_mark(endx, endy, difx, dify)
    mark_ends!
    
    @display_array
  end

  def precise_mark(precise_x, precise_y, difx, dify)
    x = (precise_x / CHR_WIDTH).floor
    y = (precise_y / CHR_HEIGHT).floor
    @display_array[y][x] = line_marking(difx, dify)
  end

  def line_marking(difx, dify)
    case @mark
    when :standard
      difx.abs > dify.abs ? '-' : '|'
    else
      @mark
    end
  end

  private

  def mark_ends!
    @display_array[@y1][@x1] = @start_mark if @start_mark
    @display_array[@y2][@x2] = @end_mark   if @end_mark
  end

end
