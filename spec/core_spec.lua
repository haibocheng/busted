assert(type(describe) == "function")
assert(type(it) == "function")
assert(type(before_each) == "function")
assert(type(after_each) == "function")
assert(type(spy) == "table")
assert(type(stub) == "table")
assert(type(mock) == "function")


local test_val = false

assert.is_not_nil(_TEST)  -- test on file-level

describe("testing global _TEST", function()
  
  assert.is_not_nil(_TEST)
  
  setup(function()
    assert.is_not_nil(_TEST)
  end)
  
  before_each(function()
    assert.is_not_nil(_TEST)
  end)
  
  after_each(function()
    assert.is_not_nil(_TEST)
  end)
  
  teardown(function()
    assert.is_not_nil(_TEST)
  end)

  it("Tests the _TEST global in an it() block", function()
    assert.is_not_nil(_TEST)
  end)

end)

describe("Test Case", function()
  local test_val = true
  assert(test_val)
end)

describe("Test case", function()
  local test_val = false
  it("changes test_val to true", function()
    test_val = true
    assert(test_val)
  end)
end)

describe("Before each", function()
  local test_val = false

  before_each(function()
    test_val = true
  end)

  it("is called", function()
    assert(test_val)
  end)
end)

describe("After each", function()
  local test_val = false

  after_each(function()
    test_val = true
  end)

  it("runs once to fire an after_each and then", function() end)
  it("checks if after_each was called", function()
   assert(test_val)
  end)
end)

describe("Both before and after each", function()
  local test_val = 0

  before_each(function()
    test_val = test_val + 1
  end)

  after_each(function()
    test_val = test_val + 1
  end)

  it("checks if both were called", function() end)
  it("runs again just to be sure", function() end)

  it("checks the value", function() 
    assert(test_val == 5)
  end)
end)

describe("Before_each on describe blocks", function()
  local test_val = 0

  before_each(function()
    test_val = test_val + 1
  end)

  describe("A block", function()
    it("derps", function()
      assert(test_val == 1)
    end)

    it("herps", function()
      assert(test_val == 2)
    end)
  end)
end)

describe("Before_each on describe blocks, part II", function()
  local test_val = 0

  before_each(function()
    test_val = test_val + 1
  end)

  it("checks the value", function()
    assert.are.equal(1, test_val)
  end)

  describe("A block", function()
    before_each(function()
      test_val = test_val + 1
    end)

    it("derps", function() end) --add two: two before-eaches
    it("herps", function() end)

    it("checks the value", function()
      assert(test_val == 7)
    end)
  end)
end)

describe("A failing test", function()
  it("explodes", function()
    assert.has.error(function() assert(false, "this should fail") end)
  end)
end)

describe("tagged tests #test", function()
  it("runs", function()
    assert(true)
  end)
end)


describe("Testing test order", function()
  
  local testorder, level = "", 0
  local function report_level(desc)
    testorder = testorder .. string.rep(" ", level * 2) .. desc .. "\n"
  end

  describe("describe, level A", function()
  
    setup(function()
      report_level("setup A")
      level = level + 1
    end)

    teardown(function()
      level = level - 1
      report_level("teardown A")
    end)

    before_each(function()
      report_level("before_each A")
      level = level + 1
    end)

    after_each(function()
      level = level - 1
      report_level("after_each A")
    end)

    it("tests A one", function()
      report_level("test A one")        
    end)
    
    it("tests A two", function()
      report_level("test A two")        
    end)

    describe("describe level B", function()

      setup(function()
        report_level("setup B")
        level = level + 1
      end)

      teardown(function()
        level = level - 1
        report_level("teardown B")
      end)

      before_each(function()
        report_level("before_each B")
        level = level + 1
      end)

      after_each(function()
        level = level - 1
        report_level("after_each B")
      end)

      it("tests B one", function()
        report_level("test B one")
      end)
      
      it("tests B two", function()
        report_level("test B two")        
      end)
          
    end)
  
    it("tests A three", function()
      report_level("test A three")        
    end)

  end)
    
  describe("Test testorder", function()
    it("verifies order of execution", function()
local expected = [[setup A
  before_each A
    test A one
  after_each A
  before_each A
    test A two
  after_each A
  setup B
    before_each A
      before_each B
        test B one
      after_each B
    after_each A
    before_each A
      before_each B
        test B two
      after_each B
    after_each A
  teardown B
  before_each A
    test A three
  after_each A
teardown A
]]        
      assert.is.equal(expected, testorder)
    end)

  end)

end)

it("Malformated Lua code gets reported correctly", function()
  local filename = ".malformed_test.lua"
  local f = io.open(filename,"w")
  f:write("end)") -- write some non-sense which will cause a parse error
  f:close()
  local statuses = busted.run_internal_test(filename)
  assert.is_equal(#statuses,1)
  local status = statuses[1]
  assert.is_equal(status.type, "failure")
  assert.is_equal(status.description, "Failed executing testfile; "..filename)
  assert.is_truthy(status.err:match("expected"))
end)
