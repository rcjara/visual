module Background
  def background_array
    @background_array ||= construct_background_array
  end

  def construct_background_array
    (0...style[:height]).collect { style[:background] * style[:width] }
  end

  def draw_to(other)
    ignore_chr = style[:transparent] ? style[:background] : nil
    other.mark(style[:x], style[:y], display_array, ignore_chr)
  end

  def display
    display_array.join("\n") + "\n"
  end

  def display_array(force = false)
    if force
      self.construct_display_array
    else
      @display_array || self.construct_display_array
    end

    @display_array
  end

end
