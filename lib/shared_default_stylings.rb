require 'defaults_processor'

#stylings that should be constant throughout methods
module SharedDefaultStylings

  DEFAULT_STYLING = {
    #position
    x: 0,
    y: 0,
    #size
    width:  0,
    height: 0,
    #background
    background: ' ',
    transparent: true,
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
    #margins
    margin_top:     0,
    margin_bottom:  0,
    margin_left:    0,
    margin_right:   0,
    #padding
    padding_top:    0,
    padding_bottom: 0,
    padding_left:   0,
    padding_right:  0,
  }

  DEPENDENT_DEFAULTS = {
    margins: {
      type: :direct,
      dependents: [:margin_top, :margin_bottom, 
        :margin_left, :margin_right]
    },
    springy: {
      type: :direct,
      dependents: [:spring_x, :spring_y] 
    },
    padding: {
      type: :direct,
      dependents: [:padding_top, :padding_bottom, :padding_left, :padding_right]
    },
    border_style: {
      type: :additional,
      dependents: [:border_style],
      also: [:corners]
    }
  }

end
