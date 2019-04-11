require "../spec_helper"
require "../../src/hyperparam/matrix"

module Hyperparam
  describe Matrix do
    describe "initialization" do
      it "supports creation with a linear index initialiser" do
        matrix = Matrix(Int32, 2, 3).new { |idx| idx }
        # TODO: test values
      end

      it "supports creation with an indices initialiser" do
        Matrix(UInt32, 2, 3).build { |i, j| i * j }
      end      

      it "supports creation with a single, repeated value" do
        matrix = Matrix(Int32, 2, 3).of 123
        # TODO: test values
      end      
    end

    describe "#size" do
      it "provides the total capacity" do
        matrix = Matrix(Nil, 2, 3).of nil
        matrix.size.should eq(6)
      end
    end
  end
end
