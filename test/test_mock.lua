return function()
	local mock = require "deftest.mock"
	
	local function get_mock_module()
		return {
			var = 123,
			fn1 = function()
				return "foo"
			end,
			fn2 = function()
				return "bar"
			end,
		}
	end
	
	describe("mock.lua", function()
		before(function()
		end)
		
		after(function()
		end)

		it("should not modify the behaviour of functions unless explicitly requested", function()
			local m = get_mock_module()
			mock.mock(m)
			assert(m.fn1() == "foo")
			assert(m.fn2() == "bar")
			assert(m.var == 123)
		end)

		it("should keep track of the number of calls to functions", function()
			local m = get_mock_module()
			mock.mock(m)
			assert(m.fn1.calls == 0)
			assert(m.fn2.calls == 0)
			m.fn1()
			m.fn1()
			assert(m.fn1.calls == 2)
			assert(m.fn2.calls == 0)
			m.fn2()
			assert(m.fn1.calls == 2)
			assert(m.fn2.calls == 1)
		end)

		it("should be able to replace functions in a mocked module and then restore them", function()
			local m = get_mock_module()
			mock.mock(m)
			m.fn1.replace(function() return "oh boy" end)
			assert(m.fn1() == "oh boy")
			assert(m.fn1() == "oh boy")
			assert(m.fn1.calls == 2)
			mock.unmock(m)
			assert(m.fn1() == "foo")
		end)

		it("should be able to call the original function when a function has been replaced", function()
			local m = get_mock_module()
			mock.mock(m)
			m.fn1.replace(function() return "oh boy" end)
			assert(m.fn1() == "oh boy")
			assert(m.fn1.original() == "foo")
		end)

		it("should be able to restore individual functions", function()
			local m = get_mock_module()
			mock.mock(m)
			m.fn1.replace(function() return "oh boy" end)
			m.fn2.replace(function() return "oh yes" end)
			assert(m.fn1() == "oh boy")
			assert(m.fn2() == "oh yes")
			m.fn1.restore()
			assert(m.fn1() == "foo")
			assert(m.fn2() == "oh yes")
			mock.unmock(m)
			assert(m.fn1() == "foo")
			assert(m.fn2() == "bar")
		end)
		
		it("should be able to return a pre-defined return value for each function", function()
			local m = get_mock_module()
			mock.mock(m)
			m.fn1.always_returns(987)
			m.fn2.always_returns(654)
			for i=1,100 do
				assert(m.fn1() == 987)
				assert(m.fn2() == 654)
			end
			assert(m.fn1.calls == 100)
			assert(m.fn2.calls == 100)
			mock.unmock(m)
			assert(m.fn1() == "foo")
			assert(m.fn2() == "bar")
		end)
		
		it("should be able to return a set of pre-defined return values for a function and revert to the original function return value when out of pre-defined return values", function()
			local m = get_mock_module()
			mock.mock(m)
			m.fn1.returns({ 1, 2, 3, 4 })
			m.fn2.returns(20, 30)
			assert(m.fn1() == 1)
			assert(m.fn1() == 2)
			assert(m.fn1() == 3)
			assert(m.fn1() == 4)
			assert(m.fn1() == "foo")
			assert(m.fn1.calls == 5)
			assert(m.fn2() == 20)
			assert(m.fn2() == 30)
			assert(m.fn2() == "bar")
			assert(m.fn2.calls == 3)
			mock.unmock(m)
			assert(m.fn1() == "foo")
			assert(m.fn2() == "bar")
		end)
	end)
end