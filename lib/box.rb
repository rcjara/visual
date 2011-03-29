require_relative 'background'
require_relative 'line'

class Box
  include Background
  DEFAULT_CORNERS = {
    standard: '+'
  }

  DEFAULT_STYLING = {
    #position
    x: 0,
    y: 0,
    #size
    width:  0,
    height: 0,
    #background
    background: ' ',
    #springingness
    spring_x: false,
    spring_y: false,
    #border
    border_style: nil,
    #corners
    top_left_corner:     nil,
    top_right_corner:    nil,
    bottom_left_corner:  nil,
    bottom_right_corner: nil,

  }

  DEPENDENT_DEFAULTS = {
    springy: {
      type: :direct,
      dependents: [:spring_x, :spring_y] 
    },
    border_style: {
      type: :additional,
      dependents: [:border_style],
      also: [:corners]
    },
    corners: {
      type: :hash,
      hash: DEFAULT_CORNERS,
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
    @style = self.class.process_styles(opts)
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
          display_array[j + y][i + x] = chr
        end
      end
    end
  end

  def << (object)
    @objects << object
    readjust_size!
    self
  end

  def in_bounds?(x = 0, y = 0)
    (x >= 0) && (y >= 0) && (x < @style[:width]) && (y < @style[:height])
  end

  def self.process_styles(styling)
    style_hash = process_dependent_defaults(styling)
    
    DEFAULT_STYLING.each_pair do |key, default_value|
      style_hash[key] = styling[key] || style_hash[key] || default_value
    end

    style_hash
  end

  def self.process_dependent_defaults(styling)
    style_hash = {}
    DEPENDENT_DEFAULTS.each_pair do |key, opts_hash|
      if styling[key]
        process_dependent_default(styling, style_hash, key, opts_hash)
      end
    end

    style_hash
  end

  def self.process_dependent_default(styling, style_hash, key, opts_hash)
    case opts_hash[:type]
    when :direct
      opts_hash[:dependents].each do |dependent|
        style_hash[dependent] = styling[key]
      end
    when :additional
      opts_hash[:dependents].each do |dependent|
        style_hash[dependent] = styling[key]
      end
      opts_hash[:also].each do |also_key|
        also_value = DEPENDENT_DEFAULTS[also_key]
        styling[also_key] ||= styling[key]
        process_dependent_default(styling, style_hash, also_key, also_value)
      end
    else
      opts_hash[:dependents].each do |dependent|
        type = opts_hash[:type]
        style_hash[dependent] = opts_hash[type][ styling[key] ]
      end
    end
  end

  private

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
