local com = require("component")
local coil = com.ie_tesla_coil
coilname = "ie_tesla_coil"
local GUI = require("GUI")
local application = GUI.application()
local modem = com.modem
local coils = {}
local countup = 1

-- Looks like we doin this crap outselves...
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

-- Tesla mother panel
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

--------------------------------------------------------------------------------

application:draw(true)
application:start()
