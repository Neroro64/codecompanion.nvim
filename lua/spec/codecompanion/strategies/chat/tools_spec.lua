local Chat = require("codecompanion.strategies.chat")
local Tools = require("codecompanion.strategies.chat.tools")

local codecompanion = require("codecompanion")
local config = require("codecompanion").config

-- Mock dependencies
config.strategies = {
  agent = {
    tools = {
      ["foo"] = {
        callback = "utils.foo",
        description = "Some foo function",
      },
      ["bar"] = {
        callback = "utils.bar",
        description = "Some bar function",
      },
      ["bar_again"] = {
        callback = "utils.bar_again",
        description = "Some bar_again function",
      },
    },
  },
}

describe("Tools", function()
  local tools
  local chat

  before_each(function()
    codecompanion.setup()
    tools = Tools.new()

    package.loaded["codecompanion.utils.foo"] = "foo"
    package.loaded["codecompanion.utils.bar"] = "bar"
    package.loaded["codecompanion.utils.bar_again"] = "bar_again"
  end)

  describe(":parse", function()
    it("should parse a message with an agent", function()
      local result = tools:parse("@foo let's do some stuff")
      assert.is_not_nil(result)
      assert.equals("foo", result.foo)
    end)

    it("should return nil if no agent is found", function()
      local result = tools:parse("no agent here")
      assert.is_nil(result)
    end)
  end)

  describe(":replace", function()
    it("should replace the agent in the message", function()
      local message = "@foo replace this agent"
      local result = tools:replace(message, "foo")
      assert.equals("replace this agent", result)
    end)
  end)

  it("should resolve a built-in callback", function()
    local result = tools:parse("@bar what is happening?")
    assert.equals("bar", result.bar)
  end)

  it("should resolve a built-in callback which is similar to another", function()
    local result = tools:parse("@bar_again what is happening?")
    assert.equals("bar_again", result.bar_again)
  end)
end)
