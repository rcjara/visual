require_relative 'spec_helper'
require_relative '../lib/Box'

include BoxSpecHelper

describe Box do
  describe "process_dependent_defaults" do
    it "should register all the dependent styles" do
      h = Box.process_dependent_defaults(:size => 5)
      h[:height].should == 5
      h[:width].should == 5
    end

    it "should handle :hash type defaults" do
      h = Box.process_dependent_defaults(corners: :standard)
      CORNERS.each{|c| h[c].should == '+' }
    end

    it "should handle :additional type defaults" do
      h = Box.process_dependent_defaults(border_style: :standard)
      h[:border_style].should == :standard
      CORNERS.each{|c| h[c].should == '+' }
    end
    
    
    it "should return an empty hash in response to nonsense" do
      h = Box.process_dependent_defaults(:blize => 5)
      h.should be_empty
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

  describe "a Box with padding and non-wrapping text" do
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
  
  
end
