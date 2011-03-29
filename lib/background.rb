module Background
  def background_array
    @background_array ||= construct_background_array
  end

  def construct_background_array
    (0...@height).collect { @background * @width }
  end

  def draw_to(other)
    other.mark(@x, @y, display_array, @background)
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
