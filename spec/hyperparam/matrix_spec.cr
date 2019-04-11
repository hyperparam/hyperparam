require "../spec_helper"
require "../../src/hyperparam/matrix"

module Hyperparam
  describe Matrix do
    describe "initialization" do
      it "supports creation with a linear index initialiser" do
        a = Matrix(Int32, 2, 3).new { |idx| idx }
        # TODO: test values
      end

      it "supports creation with an indices initialiser" do
        a = Matrix(UInt32, 2, 3).build { |i, j| i * j }
        # TODO: test values
      end 

      it "supports building from a StaticArray" do
         a = Matrix(Int32, 2, 3).from StaticArray[1, 2, 3, 4, 5, 6]
        # TODO: test values
      end      

      it "supports creation with a single, repeated value" do
        a = Matrix(Int32, 2, 3).of 123
        # TODO: test values
      end      
    end

    describe "#==" do
      it "returns false for differently sized matrices" do
        a = Matrix(Nil, 2, 3).of nil
        b = Matrix(Nil, 3, 4).of nil
        (a == b).should eq(false)
      end

      it "uses element equality for equally sized matrices" do
        a = Matrix(Int32, 2, 3).of 42
        b = Matrix(Float32, 2, 3).of 42.0
        (a == b).should eq(true)
      end

      it "return false for other objects" do
        a = Matrix(Nil, 2, 3).of nil
        (a == "Foo").should eq(false)
      end
    end    

    describe "#*" do
      it "supports matrix multiplication" do
        a = Matrix(Int32, 2, 3).new { |i| i }
        b = Matrix(Int32, 3, 2).new { |i| i }
        expected = Matrix(Int32, 2, 2).from StaticArray[10, 13, 28, 40]
        (a * b).should eq(expected)
      end
    end

    describe "#[]" do
      a = Matrix(Int32, 3, 4).new { |idx| idx }

      it "supports retrieval based on row, column addresses" do
        a[0, 0].should eq(0)
        a[0, 3].should eq(3)
        a[1, 0].should eq(4)
      end

      it "supports negative index lookups" do
        a[-1, -1].should eq(a[2, 3])
      end

      it "raises an index error for invalid indices" do
        expect_raises(IndexError) { a[10, 0] }
        expect_raises(IndexError) { a[-10, 0] }
      end
    end

    describe "#col" do
      a = Matrix(Int32, 2, 3).new { |idx| idx }
      a.col(0).should eq(StaticArray[0, 3])
      a.col(1).should eq(StaticArray[1, 4])
    end

    describe "#num_cols" do
      it "provides the column count" do
        a = Matrix(Nil, 2, 3).of nil
        a.num_cols.should eq(3)
      end
    end  
    
    describe "#num_rows" do
      it "provides the row count" do
        a = Matrix(Nil, 2, 3).of nil
        a.num_rows.should eq(2)
      end
    end

    describe "#row" do
      a = Matrix(Int32, 2, 3).new { |idx| idx }
      a.row(0).should eq(StaticArray[0, 1, 2])
      a.row(1).should eq(StaticArray[3, 4, 5])
    end

    describe "#size" do
      it "provides the total capacity" do
        a = Matrix(Nil, 2, 3).of nil
        a.size.should eq(6)
      end
    end
  end
end
