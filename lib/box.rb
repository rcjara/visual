require_relative 'background'
require_relative 'line'
require_relative 'shared_default_stylings'

class Box
  include DefaultsProcessor
  include Background

  DEPENDENT_DEFAULTS = {
    corners: {
      type: :hash,
      hash: {standard: '+'},
      dependents: [:top_left_corner, :top_right_corner, 
        :bottom_left_corner, :bottom_right_corner]
    },
    size: {
      type: :direct,
      dependents: [:width, :height]
    }
  }


  attr_accessor :style

  def initialize(opts = {})
    @style = process_defaults(opts)
    @text = process_text(opts.fetch(:text, nil))
    @objects = []
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
          display_array[j + y + style[:padding_top] ] \
                       [i + x + style[:padding_left] ] = chr
        end
      end
    end
  end

  def << (object)
    object.style[:x] += object.style[:margin_left]
    object.style[:y] += object.style[:margin_top]
    @objects << object
    readjust_size!
    self
  end

  def right_clearance
    style[:x] + style[:margin_right] + style[:width]
  end

  def bottom_clearance
    style[:y] + style[:margin_bottom] + style[:height]
  end

  def add_right(object)
    if @objects.empty?
      self.<< object
    else
      object.style[:x] = @objects.last.right_clearance
      object.style[:y] = @objects.last.style[:y]
      self.<< object
    end

    readjust_size!
    self
  end

  def add_bottom(object)
    if @objects.empty?
      self.<< object
    else
      object.style[:x] = @objects.last.style[:x]
      object.style[:y] = @objects.last.bottom_clearance
      self.<< object
    end

    readjust_size!
    self
  end

  def add_at(object, x = 0, y = 0)
    object.style[:x] = x
    object.style[:y] = y
    self.<< object
  end

  def add_centered(object)
    horizontal_center!(object)
    vertical_center!(object)
    self.<< object
  end

  def horizontal_center!(object)
    if object.style[:width] > style[:width]
      object.style[:x] = 0
    else
      object.style[:x] = (style[:width] - object.style[:width]) / 2
    end
  end

  def vertical_center!(object)
    if object.style[:height] > style[:height]
      object.style[:y] = 0
    else
      object.style[:y] = (style[:height] - object.style[:height]) / 2
    end
  end

  def in_bounds?(x = 0, y = 0)
    (x >= 0) && (y >= 0) && (x < style[:width] - style[:padding_right] - style[:padding_left]) && (y < style[:height] - style[:padding_top] - style[:padding_bottom])
  end

  private

  def default_values
    SharedDefaultStylings::DEFAULT_STYLING
  end

  def dependent_defaults
    @@dependent_defaults ||= 
      SharedDefaultStylings::DEPENDENT_DEFAULTS.merge(DEPENDENT_DEFAULTS)
  end

  def draw_border!
    return unless @style[:border_style]
    case @style[:border_style]
    when :standard
      draw_standard_border!
    end
  end

  def draw_corners!
    @display_array[ 0][ 0] = @style[:top_left_corner]
    @display_array[ 0][-1] = @style[:top_right_corner]
    @display_array[-1][ 0] = @style[:bottom_left_corner]
    @display_array[-1][-1] = @style[:bottom_right_corner]
  end

  def draw_standard_border!
    @display_array[ 0] = '-' * @style[:width]
    @display_array[-1] = '-' * @style[:width]
    @display_array[1...-1].each do |line|
      line[0]  = '|'
      line[-1] = '|'
    end
    draw_corners!
  end

  def process_text(text)
    return nil unless text
  end

  def readjust_size!
    readjust(:width)  if @style[:spring_x]
    readjust(:height) if @style[:spring_y]
  end

  #only ever used for width/height
  def readjust(property)
    position = case property
      when :width
        :x
      when :height
        :y
      end
    max = @objects.inject(0) do |m, obj|
      [m, obj.style[position] + obj.style[property] ].max
    end

    @style[property] = max if max > @style[property]
  end

end
