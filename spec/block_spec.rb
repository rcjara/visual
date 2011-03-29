require_relative 'spec_helper'
require_relative '../lib/Box'

include BoxSpecHelper

describe Box do
  describe "a basic Box" do
    before(:each) do
      @b = Box.new(20, 12)
    end

    it "should display blank lines" do
      @b.display.should == <<EOS
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
EOS
    end
    
    
  end

  describe "a Box with '.' as it's background" do
    before(:each) do
      @b = Box.new(20, 12, :background => '.')
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
      @b = Box.new(0, 0, background: '.', springy: true)
    end

    it "should display just an empty newline" do
      @b.display.should == "\n"
    end
    
    
    describe "on adding an object by <<" do
      before(:each) do
        @b << Box.new(20, 12)
      end
      
      it "should have the height/ width of the new object" do
        @b.height.should == 12
        @b.width.should  == 20
      end
      
      it "should display the added object" do
        @b.display.should == BoxSpecHelper::BLANK_20_12
      end
      
      describe "on adding a second object by <<" do
        before(:each) do
          @b << Box.new(12, 20)
        end

        it "should have the height / width of both objects" do
          @b.height.should == 20
          @b.width.should  == 20
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
      @b = Box.new(10, 6, border: :standard)
    end

    it "should have a border_style" do
      @b.border_style.should == :standard
    end
    
    
    it "should display properly" do
      @b.display.should == BORDER_10_6
    end
    
  end
  
  
end
