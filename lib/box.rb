require_relative 'background'
require_relative 'line'

class Box
  include Background

  DEFAULT_CORNERS = {
    standard: '+'
  }

  attr_accessor :width, :height, :x, :y, :border_style

  def initialize(width, height, opts = {})
    @x = opts.fetch(:x, 0)
    @y = opts.fetch(:y, 0)


    @width = width
    @height = height
    @background = opts.fetch(:background, ' ')
    @objects = []

    if opts[:springy]
      @spring_x = true
      @spring_y = true
    end

    @spring_x ||= opts.fetch(:spring_x, false)
    @spring_y ||= opts.fetch(:spring_y, false)

    set_border_options!(opts)

    @text = process_text(opts.fetch(:text, nil))
  end

  def construct_display_array
    @display_array = background_array.dup
    draw_border!
    @objects.each{ |o| o.draw_to(self) }
    @display_array
  end

  def mark(x, y, array, ignore = @background)
    array.each.with_index do |line, j|
      next unless in_bounds?(0, j + y)
      line.each_char.with_index do |chr, i|
        if chr != ignore && in_bounds?(i + x, j + y)
          display_array[j + y][i + x] = chr
        end
      end
    end
  end

  def << (object)
    @objects << object
    readjust_size
    self
  end

  def in_bounds?(x = 0, y = 0)
    (x >= 0) && (y >= 0) && (x < @width) && (y < @height)
  end

  private

  def set_border_options!(opts)
    @border_style = opts.fetch(:border, nil)
    corners = opts.fetch(:corners, DEFAULT_CORNERS[@border_style])
    @top_left_corner     = opts[:top_left_corner] || corners
    @top_right_corner    = opts[:top_right_corner] || corners
    @bottom_left_corner  = opts[:bottom_left_corner] || corners
    @bottom_right_corner = opts[:bottom_right_corner] || corners
  end

  def draw_border!
    return unless @border_style
    case @border_style
    when :standard
      draw_standard_border!
    end
  end

  def draw_corners!
    @display_array[ 0][ 0] = @top_left_corner
    @display_array[ 0][-1] = @top_right_corner
    @display_array[-1][ 0] = @bottom_left_corner
    @display_array[-1][-1] = @bottom_right_corner
  end

  def draw_standard_border!
    @display_array[ 0] = '-' * @width
    @display_array[-1] = '-' * @width
    @display_array[1...-1].each do |line|
      line[0]  = '|'
      line[-1] = '|'
    end
    draw_corners!
  end

  def process_text(text)
    return nil unless text
  end

  def readjust_size
    readjust_width  if @spring_x
    readjust_height if @spring_y
  end

  def readjust_width
    max_x = @objects.inject(0) do |max, obj|
      [max, obj.x + obj.width].max
    end

    @width = max_x if max_x > @width
  end

  def readjust_height
    max_y = @objects.inject(0) do |max, obj|
      [max, obj.y + obj.height].max
    end

    @height = max_y if max_y > @height
  end

end
