local com = require("com")
local coil = com.ie_tesla_coil
coilname = "ie_tesla_coil"
local GUI = require("GUI")
local application = GUI.application()
local coils = {}
local countup = 1
local event = require("event")
local term = require("term")
local modem = com.modem

-- Looks like we doin this crap outselves...
print("Loading mother GUI")
print("Searching for coils")

for address, name in com.list("ie_tesla_coil", true) do
    table.insert(coils, com.proxy(address))
    com.invoke(address, "setRSMode", false)
    com.invoke(address, "setPowerMode", false)
    os.sleep(1)
    print("_____:"..countup)
    print(address, name)
    countup = countup + 1
end

os.sleep(2)

--Panel
application:addChild(GUI.panel(1, 1, application.width, application.height, 0x2D2D2D))

-- Tesla panel and functions
application:addChild(GUI.button(3, 2, 36, 3, 0xE1E1E1, 0x4B4B4B, 0xA5A5A5, 0x0, "Tesla Coils")).onTouch = function()
    local container = GUI.addBackgroundContainer(application, true, true, "Tesla Coils")

    --Tesla toggle sub-button
    local teslatoginfo = container.layout:addChild(GUI.text(1, 2, 0xFFFFFF, "Activate:"))
    local teslatog = container.layout:addChild(GUI.switch(1, 3, 8, 0x66DB80, 0x1D1D1D, 0xEEEEEE, false))
    teslatog.onStateChanged = function(state)

        for address, name in com.list("ie_tesla_coil", true) do
            table.insert(coils, com.proxy(address))
            com.invoke(address, "setRSMode", teslatog.state)
        end
    end

    --Tesla overdrive sub-button
    local overdriveinfo = container.layout:addChild(GUI.text(1, 5, 0xFFFFFF, "Overdrive:"))
    local overdrivetog = container.layout:addChild(GUI.switch(1, 6, 8, 0x66DB80, 0x1D1D1D, 0xEEEEEE, false))
    overdrivetog.onStateChanged = function(state)
        if not coil.isActive() then
            for address, name in com.list("ie_tesla_coil", true) do
                table.insert(coils, com.proxy(address))
                com.invoke(address, "setPowerMode", overdrivetog.state)
            end
        else
            overdrivetog:setState(false)
        end
    end
end

--------------------------------------------------------------------------------TESLA COILS END

--Nanomachines

application:addChild(GUI.button(3, 2, 36, 3, 0xE1E1E1, 0x4B4B4B, 0xA5A5A5, 0x0, "NanoMachines")).onTouch = function()


modem.open(1)
modem.broadcast(1, "nanomachines", "setResponsePort", 1)

local lastResponse = ""
local function printResponse()
  local w, h = com.gpu.getResolution()
  com.gpu.fill(1, h, w, h, " ")
  com.gpu.set(1, h, lastResponse)
end
local function handleModemMessage(_, _, _, _, _, header, command, ...)
  if header ~= "nanomachines" then return end
  lastResponse = "Last response: " .. command
  for _, v in ipairs({...}) do
    lastResponse = lastResponse .. ", " .. tostring(v)
  end
  printResponse()
end

event.listen("modem_message", handleModemMessage)

local function send(command, ...)
  com.modem.broadcast(1, "nanomachines", command, ...)
end

local function readNumber(name, validator)
  local index
  while not index do
    io.write(name..": ")
    index = tonumber(io.read())
    if not index or validator and not validator(index) then
      index = nil
      io.write("invalid input\n")
    end
  end
  return index
end

local running = true
local commands = {
  { "Get power state",
    function()
      send("getPowerState")
    end
  },

  { "Get active effects",
    function()
      send("getActiveEffects")
    end
  },
  { "Get input",
    function()
      local index = readNumber("index")
      send("getInput", index)
    end
  },
  { "Set input",
    function()
      local index = readNumber("index")
      io.write("1. On\n")
      io.write("2. Off\n")
      local value = readNumber("state", function(x) return x == 1 or x == 2 end)
      send("setInput", index, value == 1)
    end
  },
  { "Get total input count",
    function()
      send("getTotalInputCount")
    end
  },
  { "Get safe active input count",
    function()
      send("getSafeActiveInputs")
    end
  },
  { "Get max active input count",
    function()
      send("getMaxActiveInputs")
    end
  },

  { "Save Configuration",
    function()
      send("saveConfiguration")
    end
  },

  { "Get health",
    function()
      send("getHealth")
    end
  },
  { "Get hunger",
    function()
      send("getHunger")
    end
  },
  { "Get age",
    function()
      send("getAge")
    end
  },
  { "Get name",
    function()
      send("getName")
    end
  },
  { "Get experience",
    function()
      send("getExperience")
    end
  },
  { "Reset effects",
    function()
      for k,v in getTotalInputCount do
      send("setInput", number, 0)
    end
    end
  },
  { "Exit",
    function()
      running = false
    end
  }
}

function main()
  while running do
    term.clear()
    for i = 1, #commands do
      local command = commands[i]
      io.write(i,". ",command[1],"\n")
    end
    printResponse()

    local command = readNumber("command", function(x) return x > 0 and x <= #commands end)
    commands[command][2]()
  end
end

local result, reason = pcall(main)
if not result then
  io.stderr:write(reason, "\n")
end

event.ignore("modem_message", handleModemMessage)

term.clear()

-- Single inputs:
-- 1: Smoldering effects
-- 3: Resistence
-- 9: Water breathing
-- 12: Slowness 
-- 13: Speed


-- Combos:
-- 1+15 = Poison 2

-- 2+7 = Automining
-- 2+10 = Fire particles
-- 2+16 = Absorption 2

-- 3+9 = Resistence + Water breathing
-- 3+12 = Resistence + Slowness
-- 3+13 = Speed + Resistence

-- 4+nothing.

--5

end
--------------------------------------------------------------------------------Nanomachine END


application:draw(true)
application:start()




