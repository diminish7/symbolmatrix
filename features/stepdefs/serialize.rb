Given /^the SymbolMatrix:$/ do |yaml| 
  @symbolmatrix = SymbolMatrix yaml
end

When /^I serialize it$/ do 
  @serialization = @symbolmatrix.to.serialization
end

Then /^I should get "(.+?)"$/ do |serialization|
  @serialization.should == serialization
end