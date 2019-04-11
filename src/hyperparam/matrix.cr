# Generic, type-safe abstract matrix structure.
#
# This structure provides an *M* x *N* rectangular array of any
# [field](https://en.wikipedia.org/wiki/Field_(mathematics)) *T*. That is, *T*
# must define operations for addition, subtraction, multiplication and division.
#
# Where possible, all matrix operations provide validation at the type level.
#
# Based on: https://github.com/aca-labs/matrix
module Hyperparam
  struct Matrix(T, M, N)

    # Creates Matrix, yielding the linear index for each element to provide an
    # initial value.
    def initialize(&block : Int32 -> T)
      {{ raise("Matrix dimensions must be positive") if M < 0 || N < 0 }}
      @buffer = Pointer(T).malloc(size, &block)
    end

    # Creates a Matrix with each element initialized as *value*.
    def self.of(value : T)
      Matrix(T, M, N).new { value }
    end    

    # Gets the capacity (total number of elements) of `self`.
    def size
      M * N
    end
  end
end
