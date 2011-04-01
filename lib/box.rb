require_relative 'background'
require_relative 'line'
require_relative 'shared_default_stylings'

class Box
  include DefaultsProcessor
  include Background

  DEFAULT_STYLING = {
    #text-align
    text_align: :left
  }

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


  attr_accessor :style, :text

  def initialize(opts = {})
    @style = process_defaults(opts)
    border_check!
    @objects = []
    process_text(opts.fetch(:text, nil))
  end

  def border_check!
    return unless style[:border_style]
    [:padding_top, :padding_bottom, :padding_left, :padding_right].each do |pad|
      style[pad] += 1
    end
  end
###########
# Drawing #
###########

  def construct_display_array
    @display_array = background_array.dup
    draw_border
    @objects.each{ |o| o.draw_to(self) }
    draw_text
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

########
# Info #
########

  def right_clearance
    style[:x] + style[:margin_right] + style[:width]
  end

  def bottom_clearance
    style[:y] + style[:margin_bottom] + style[:height]
  end

  def in_bounds?(x = 0, y = 0)
    (x >= 0) && (y >= 0) && (x < style[:width] - style[:padding_right] - style[:padding_left]) && (y < style[:height] - style[:padding_top] - style[:padding_bottom])
  end


##########
# Adding #
##########

  def << (object)
    object.style[:x] += object.style[:margin_left]
    object.style[:y] += object.style[:margin_top]
    @objects << object
    readjust_size!
    self
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

########
# Text #
########

  def process_text(new_text)
    @text = new_text
    @text_dimensions = if @text
      array = text_array
      { x: 0, y: 0, width: array[0].length, height: array.length }
    else
      { x: 0, y: 0, width: 0, height: 0 }
    end
    readjust_size!
  end

  def draw_text
    mark(0, 0, text_array)
  end

  def text_array
    return [] unless @text
    base_lines = @text.split(/\n/)
    max_width  = base_lines.inject(0){ |m, line| [m, line.length].max }
    base_lines.collect { |line| line + style[:background] * (max_width - line.length) }
  end

  private

  def contained_styles
    @objects.collect(&:style) + [@text_dimensions]
  end

  def default_values
    @@default_styling ||=
      SharedDefaultStylings::DEFAULT_STYLING.merge(DEFAULT_STYLING)
  end

  def dependent_defaults
    @@dependent_defaults ||= 
      SharedDefaultStylings::DEPENDENT_DEFAULTS.merge(DEPENDENT_DEFAULTS)
  end

  def draw_border
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

  def readjust_size!
    readjust_width!
    readjust_height!
  end

  def readjust_width!
    max = contained_styles.inject(0) do |m, s|
      [m, s[:width] + s[:x] + style[:padding_left] + style[:padding_right] ].max
    end

    @style[:width] = max if max > @style[:width]
  end

  def readjust_height!
    max = contained_styles.inject(0) do |m, s|
      [m, s[:height] + s[:y] + style[:padding_top] + style[:padding_bottom] ].max
    end

    @style[:height] = max if max > @style[:height]
  end
end
