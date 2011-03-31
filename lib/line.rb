require_relative 'background'
require_relative 'shared_default_stylings'

class Line
  include Background
  include DefaultsProcessor

  CHR_WIDTH  = 3.5
  CHR_HEIGHT = 5.0

  LINE_DEFAULT_STYLING = {
    mark:       :standard,
    #start/end markings
    start_mark: nil,
    end_mark:   nil
  }

  LINE_DEPENDENT_DEFAULTS = {
    ends_mark: {
      type: :direct,
      dependents: [:start_mark, :end_mark]
    }
  }

  attr_reader :style
  attr_accessor :x1, :x2, :y1, :y2

  def initialize(x1, y1, x2, y2, args={})
    ends_mark  = args.fetch(:ends_mark, nil)

    @style = process_defaults(args)

    @style[:height] = [y1, y2].max + 1
    @style[:width ] = [x1, x2].max + 1

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
    case style[:mark]
    when :standard
      difx.abs > dify.abs ? '-' : '|'
    else
      style[:mark]
    end
  end

  private

  def default_values
    @@default_values ||= 
      SharedDefaultStylings::DEFAULT_STYLING.merge(LINE_DEFAULT_STYLING)
  end

  def dependent_defaults
    @@default_dependents ||=
      SharedDefaultStylings::DEPENDENT_DEFAULTS.merge(LINE_DEPENDENT_DEFAULTS)
  end

  def mark_ends!
    @display_array[@y1][@x1] = style[:start_mark] if style[:start_mark]
    @display_array[@y2][@x2] = style[:end_mark]   if style[:end_mark]
  end

end
