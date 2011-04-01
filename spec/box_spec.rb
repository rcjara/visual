require_relative 'spec_helper'

include BoxSpecHelper

describe Box do
  describe "process_defaults" do
    it "should register all the dependent styles" do
      h = Box.new.process_defaults(:size => 5)
      h[:height].should == 5
      h[:width].should == 5
    end

    it "should handle :hash type defaults" do
      h = Box.new.process_defaults(corners: :standard)
      CORNERS.each{|c| h[c].should == '+' }
    end

    it "should handle :additional type defaults" do
      h = Box.new.process_defaults(border_style: :standard)
      h[:border_style].should == :standard
      CORNERS.each{|c| h[c].should == '+' }
    end
    
    
    it "should return an empty hash in response to nonsense" do
      h = Box.new.process_defaults(:blize => 5)
      h[:blize].should be_nil
    end
    
    
  end

  describe "process_defaults" do
    it "should be transparent by default" do
      h = Box.new.process_defaults({})
      h[:transparent].should be_true
    end
    
    it "should be non-transparent after over-riding default" do
      h = Box.new.process_defaults(transparent: false)
      h[:transparent].should be_false
    end
  end
  
  
  describe "a 'square'" do 
    before(:each) do
      @b = Box.new(size: 5, background: '.')
    end
    
    it "should display properly" do
      @b.display.should == <<EOS
.....
.....
.....
.....
.....
EOS
    end

    it "should have the right height/width set in style" do
      @b.style[:width].should == 5
      @b.style[:height].should == 5
    end
    
    it "should have the proper clearances" do
      @b.right_clearance.should == 5
      @b.bottom_clearance.should == 5
    end
    
  end



  describe "a basic Box" do
    before(:each) do
      @b = Box.new(width: 20, height: 12)
    end

    it "should display blank lines" do
      @b.display.should == <<EOS
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
EOS
    end

    it "should have its width and height listed in style" do
      @b.style[:width].should == 20
      @b.style[:height].should == 12
    end
    
    
    
  end

  describe "a Box with '.' as it's background" do
    before(:each) do
      @b = Box.new(width: 20, height: 12, :background => '.')
    end

    it "should display its background" do
      @b.display.should == BoxSpecHelper::BLANK_20_12
    end

    it "should respond correctly if marked" do
      @b.mark(0, 0, [
"xxxxxxxx",
"xHello!x",
"xThere!x",
"xxxxxxxx" ], 'x')
      @b.display.should == <<EOS
....................
.Hello!.............
.There!.............
....................
....................
....................
....................
....................
....................
....................
....................
....................
EOS
    end

    it "should raise an error if you try to mark it up with text" do
      lambda {@b.mark(5, 5, "Hello there. You are a big supid\ndumb dumb head.")}.should raise_error
    end
  end

  describe "a simple Box with text" do
    before(:each) do
      @b = Box.new(text: "Hello world", springy: true)
    end

    it "should have the right text array" do
      @b.text_array.should == ["Hello world"]
    end
    
    
    it "should display properly" do
      @b.display.should == <<EOS
Hello world
EOS
    end
  end

  describe "a box with padding and text" do
    before(:each) do
      @b = Box.new(padding: 1, text: "Hello world!", background: ".", springy: true)
    end

    it "should have text" do
      @b.text.should == "Hello world!"
    end
    

    it "should have the right text array" do
      @b.text_array.should == ["Hello world!"]
    end
    
    
    it "should display properly" do
      @b.display.should == <<EOS
..............
.Hello world!.
..............
EOS
    end
    
  end

  describe "multiple lines of text with padding" do
    before(:each) do
      @b = Box.new(padding: 1, text: "Hi there\nyou guys\n... what up?", background: '.', springy: true)
    end

    it "should display properly" do
      @b.display.should == <<EOS
..............
.Hi there.....
.you guys.....
.... what up?.
..............
EOS
    end
  end

  describe "text in a border with horizontal padding" do
    before(:each) do
      @b = Box.new(horizontal_padding: 2, border_style: :standard, 
        text: "This looks like a title!", springy: true)
    end

    it "should have the right paddings" do
      @b.style[:padding_top].should == 1
      @b.style[:padding_bottom].should == 1
      @b.style[:padding_left].should == 3
      @b.style[:padding_right].should == 3
    end
    

    it "should display properly" do
      @b.display.should == <<EOS
+----------------------------+
|  This looks like a title!  |
+----------------------------+
EOS
    end
    
    
  end
  
  describe "centered text in a border with horizontal padding" do
    before(:each) do
      @b = Box.new(horizontal_padding: 2, border_style: :standard, 
        text: "This looks like a title II:\nThe Titling", springy: true,
        text_align: :center)
    end

    it "should have the right paddings" do
      @b.style[:padding_top].should    == 1
      @b.style[:padding_bottom].should == 1
      @b.style[:padding_left].should   == 3
      @b.style[:padding_right].should  == 3
    end
    
    it "should display properly" do
      @b.display.should == <<EOS
+-------------------------------+
|  This looks like a title II:  |
|          The Titling          |
+-------------------------------+
EOS
    end
    
    
  end
  
  

  describe "a fully springy box" do
    before(:each) do
      @b = Box.new(width: 0, height: 0, background: '.', springy: true)
    end

    it "should display just an empty newline" do
      @b.display.should == "\n"
    end
    
    it "should show that spring_x and spring_y are true in style" do
      @b.style[:spring_x].should == true
      @b.style[:spring_y].should == true
    end
    
    
    describe "on adding an object by <<" do
      before(:each) do
        @b << Box.new(width: 20, height: 12)
      end
      
      it "should have the height/ width of the new object" do
        @b.style[:height].should == 12
        @b.style[:width].should  == 20
      end
      
      it "should display the added object" do
        @b.display.should == BoxSpecHelper::BLANK_20_12
      end
      
      describe "on adding a second object by <<" do
        before(:each) do
          @b << Box.new(width: 12, height: 20)
        end

        it "should have the height / width of both objects" do
          @b.style[:height].should == 20
          @b.style[:width].should  == 20
        end
        
        it "should display approriately" do
          @b.display.should == <<EOS
....................
....................
....................
....................
....................
....................
....................
....................
....................
....................
....................
....................
....................
....................
....................
....................
....................
....................
....................
....................
EOS
        end

        describe "on adding a third object by <<" do
          before(:each) do
            @b << Box.new(width: 10, height: 6, border_style: :standard)
          end
          
          it "should display appropriately" do
            @b.display.should == <<EOS
+--------+..........
|........|..........
|........|..........
|........|..........
|........|..........
+--------+..........
....................
....................
....................
....................
....................
....................
....................
....................
....................
....................
....................
....................
....................
....................
EOS
          
          end
          
        end

      end
      
    end
  end
  
  describe "a box with borders" do
    before(:each) do
      @b = Box.new(width: 10, height: 6, border_style: :standard)
    end

    it "should have a border_style" do
      @b.style[:border_style].should == :standard
    end

    it "should have corners" do
      @b.style[:top_left_corner    ].should == '+'
      @b.style[:top_right_corner   ].should == '+'
      @b.style[:bottom_left_corner ].should == '+'
      @b.style[:bottom_right_corner].should == '+'
    end
    
    
    
    it "should display properly" do
      @b.display.should == BORDER_10_6
    end
    
  end

  describe "adding to a box" do
    before(:each) do
      @b = Box.new(springy: true)
    end

    it "should be springy in both x and y" do
      @b.style[:spring_x].should be_true
      @b.style[:spring_y].should be_true
    end
    

    describe "to the right" do
      before(:each) do
        @b.add_right( Box.new(width: 10, height: 6, border_style: :standard) )
      end
      
      it "should display properly" do
        @b.display.should == BORDER_10_6
      end

      it "should have the correct width/height" do
        @b.style[:width].should == 10
        @b.style[:height].should == 6
      end
      
      
      describe "twice" do
        before(:each) do
          @b.add_right( Box.new(width: 10, height: 6, border_style: :standard) )
        end
        
        it "should display properly" do
          @b.display.should == <<EOS
+--------++--------+
|        ||        |
|        ||        |
|        ||        |
|        ||        |
+--------++--------+
EOS
        end

        describe "and then add to the bottom" do
          before(:each) do
            @b.add_bottom(Box.new(width: 8, height: 4, border_style: :standard) )
          end

          it "should have a height of 10" do
            @b.style[:height].should == 10
          end
          
          
          it "should display properly" do
            @b.display.should == <<EOS
+--------++--------+
|        ||        |
|        ||        |
|        ||        |
|        ||        |
+--------++--------+
          +------+  
          |      |  
          |      |  
          +------+  
EOS
          end

        end
        
      end
      
    end
    
    
  end
  
  describe "(non) transparent background" do
    before(:each) do
      @b = Box.new(width: 20, height: 12, background: '.')
      @border_box = Box.new(width: 10, height: 6, border_style: :standard, transparent: false)
    end

    it "should display a blank box" do
      @b.display.should == BLANK_20_12
    end

    it "should display the border box properly" do
      @border_box.display.should == BORDER_10_6
    end
    
    it "the border_box should be transparent" do
      @border_box.style[:transparent].should be_false
    end
    
    
    describe "adding bordered box via add_at" do
      before(:each) do
        @b.add_at(@border_box, 5, 3)
      end
      
      it "display properly" do
        @b.display.should == BOX_IN_THE_MIDDLE
      end
    end
    
    describe "adding bordered box via << with margins" do
      before(:each) do
        @border_box.style[:margin_top] = 3
        @border_box.style[:margin_left] = 5
        @b << @border_box
      end
      
      it "display properly" do
        @b.display.should == BOX_IN_THE_MIDDLE
      end
    end
    
    describe "adding bordered box via << with padding" do
      before(:each) do
        @b.style[:padding_top]  = 3
        @b.style[:padding_left] = 5
        @b << @border_box
      end
      
      it "display properly" do
        @b.display.should == BOX_IN_THE_MIDDLE
      end
    end

    describe "adding bordered box via add_centered" do
      before(:each) do
        @b.add_centered @border_box
      end
      
      it "display properly" do
        @b.display.should == BOX_IN_THE_MIDDLE
      end
    end
  end
  
end
