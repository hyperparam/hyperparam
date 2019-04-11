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
    include Indexable(T)

    # Creates Matrix, yielding the linear index for each element to provide an
    # initial value.
    def initialize(&block : Int32 -> T)
      {{ raise("Matrix dimensions must be positive") if M < 0 || N < 0 }}
      @buffer = Pointer(T).malloc(size, &block)
    end

    # Creates a Matrix, invoking *initialiser* with each pair of indices.
    def self.build(&initialiser : UInt32, UInt32 -> T)
      Matrix(T, M, N).new do |idx|
        i = (idx / N).to_u32
        j = (idx % N).to_u32
        initialiser.call i, j
      end
    end

    # Creates a Matrix from elements contained within a StaticArray.
    #
    # The matrix will be filled rows first, such that an array of
    #
    #   [1, 2, 3, 4]
    #
    # becomes
    #
    #   | 1  2 |
    #   | 3  4 |
    #
    def self.from(list : StaticArray(T, A))
      {{ raise("Not enough elements to fill matrix") if A < M * N }}

      Matrix(T, M, N).new do |idx|
        list[idx]
      end
    end

    # Creates a Matrix with each element initialized as *value*.
    def self.of(value : T)
      Matrix(T, M, N).new { value }
    end

    # Equality. Returns `true` if each element in `self` is equal to each
    # corresponding element in *other*.
    def ==(other : Matrix(U, A, B)) forall U
      {% if A == M && B == N %}
        each_with_index do |e, i|
          return false unless e == other[i]
        end
        true
      {% else %}
        false
      {% end %}
    end

    # Equality with another object, or differently sized matrix. Always `false`.
    def ==(other)
      false
    end    

    # Performs a matrix multiplication with *other*.
    def *(other : Matrix(_, A, B))
      {{ raise("Dimension mismatch, cannot multiply a #{M}x#{N} by a #{A}x#{B}") \
        unless N == A }}

      Matrix(typeof(self[0] * other[0]), M, B).build do |i, j|
        pairs = row(i).zip other.col(j)
        pairs.map(&.product).sum
      end
    end
    
    # Retrieves the value of the element at *i*,*j*.
    #
    # Indicies are zero-based. Negative values may be passed for *i* and *j* to
    # enable reverse indexing such that `self[-1, -1] == self[M - 1, N - 1]`
    # (same behaviour as arrays).
    def [](i : Int, j : Int) : T
      to_unsafe[index(i, j)]
    end
    
    # Gets the contents of column *j*.
    def col(j : Int)
      StaticArray(T, M).new { |i| self[i, j] }
    end

    # Count of columns.
    def num_cols
      N
    end

    # Count of rows.
    def num_rows
      M
    end     

    # Gets the contents of row *i*.
    def row(i : Int)
      StaticArray(T, N).new { |j| self[i, j] }
    end   

    # Gets the capacity (total number of elements) of `self`.
    def size
      M * N
    end

    # Map *i*,*j* coords to an index within the buffer.
    protected def index(i : Int, j : Int)
      i += num_rows if i < 0
      j += num_cols if j < 0

      raise IndexError.new if i < 0 || j < 0
      raise IndexError.new unless i < num_rows && j < num_cols

      i * N + j
    end

    # Returns the pointer to the underlying element data.
    protected def to_unsafe : Pointer(T)
      @buffer
    end

    # Returns the element at the given linear index, without doing any bounds
    # check.
    #
    # Used by `Indexable`
    @[AlwaysInline]
    protected def unsafe_fetch(index : Int)
      to_unsafe[index]
    end    
  end
end
