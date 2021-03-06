Given /^"(.+?)"$/ do |serialization|
  @serialization = serialization
end

When /^I parse it$/ do 
  @parsed = SymbolMatrix.new @serialization
end

Then /^I should see \(serialized in yaml\)$/ do |data|
  @parsed.to.hash.should include SymbolMatrix.new(data).to.hash
end