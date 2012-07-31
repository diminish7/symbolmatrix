require "symbolmatrix/symbolmatrix"

describe SymbolMatrix do

  describe "#validate_key" do
    context "an not convertible to Symbol key is passed" do
      it "should raise a SymbolMatrix::InvalidKeyException" do
        m = SymbolMatrix.new
        o = Object.new
        expect { m.validate_key o
        }.to raise_error SymbolMatrix::InvalidKeyException, "The key '#{o}' does not respond to #to_sym, so is not a valid key for SymbolMatrix"
      end
    end
  end
  
  describe "#store" do
    context "a key is stored using a symbol" do
      it "should be foundable with #[<symbol]" do
        a = SymbolMatrix.new
        a.store :a, 2
        a[:a].should == 2
      end
    end
    
    context "the passed value is a Hash" do
      it "should be converted into a SymbolTable" do
        a = SymbolMatrix.new
        a.store :b, { :c => 3 }
        a[:b].should be_a SymbolMatrix
      end
    end
  end
  
  shared_examples_for "any merging operation" do
    it "should call :store for every item in the passed Hash" do
      m = SymbolMatrix.new
      m.should_receive(:store).exactly(3).times
      m.send @method, { :a => 1, :b => 3, :c => 4 }
    end
  end

  describe "#merge!" do
    before { @method = :merge! }
    it_behaves_like "any merging operation"
  end  
  
  describe "#update" do
    before { @method = :update }
    it_behaves_like "any merging operation"
  end

  describe "#merge" do
    it "should call #validate_key for each passed item" do
      m = SymbolMatrix.new
      m.should_receive(:validate_key).exactly(3).times.and_return(true)
      m.merge :a => 2, :b => 3, :c => 4
    end
  end

  describe "#[]" do
    context "the matrix is empty" do
      it "should raise a SymbolMatrix::KeyNotDefinedException" do
        m = SymbolMatrix.new
        expect { m['t']
        }.to raise_error SymbolMatrix::KeyNotDefinedException, "The key :t is not defined"
      end
    end
    
    context "the matrix has a key defined using a symbol" do
      it "should return the same value when called with a string" do
        m = SymbolMatrix.new
        m[:s] = 3
        m["s"].should == 3
      end
    end
  end

  describe "#to_hash" do
    it "should return an instance of Hash" do
      m = SymbolMatrix[:b, 1]
      m.to_hash.should be_instance_of Hash
    end
    
    it "should have the same keys" do
      m = SymbolMatrix[:a, 1]
      m.to_hash[:a].should == 1
    end
    
    context "there is some SymbolMatrix within this SymbolMatrix" do
      it "should recursively call #to_hash in it" do
        inside = SymbolMatrix.new
        inside.should_receive :to_hash
        
        m = SymbolMatrix[:a, inside]
        m.to_hash
      end
      
      context "and recursive is set to false" do
        it "should not call #to_hash on values" do
          inside = SymbolMatrix.new
          inside.should_not_receive :to_hash
          
          m = SymbolMatrix[:a, inside]
          m.to_hash false
        end
      end
    end
  end

  describe ".new" do
    context "a Hash is passed as argument" do
      it "should accept it" do
        m = SymbolMatrix.new :a => 1
        m["a"].should == 1
        m[:a].should == 1
      end
    end
  end    

  describe "method_missing" do
    it "should store in a key named after the method without the '=' sign" do
      m = SymbolMatrix.new
      m.a = 4
      m[:a].should == 4
    end
    
    it "should return the same as the symbol representation of the method" do
      m = SymbolMatrix.new
      m.a = 3
      m[:a].should == 3
      m["a"].should == 3
      m.a.should == 3
    end

    it "should preserve the class of the argument" do
      class A < SymbolMatrix; end
      class B < SymbolMatrix; end
      
      a = A.new
      b = B.new

      a.a = b

      a.a.should be_instance_of B
    end
  end
end