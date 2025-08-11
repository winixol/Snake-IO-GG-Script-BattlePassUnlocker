-- 🐍 Snake.io Battle Pass Hack Script 🐍
-- 🏗️ Assumes ARM64 architecture
-- 💻 DEVELOPER : JUMEL

gg.setVisible(false)

-- Function to show fake loading animation
function showLoading(message, duration)
    local dots = {".  ", ".. ", "..."}
    for i = 1, duration do
        for _, dot in ipairs(dots) do
            gg.toast(message .. dot)
            gg.sleep(200)
        end
    end
end

-- Function to get base address of libil2cpp.so
function getLibBase(libName)
    showLoading("🔍 Searching for " .. libName, 2)
    local ranges = gg.getRangesList(libName)
    if #ranges == 0 then
        gg.toast("❌ Error: " .. libName .. " not found!")
        os.exit()
    end
    return ranges[1]["start"]
end

showLoading("⚙️ Initializing hack engine", 1)
local il2cppBase = getLibBase("libil2cpp.so")
local isSubscribedOffset = 0x13A779C
local isSubscribedAddr = il2cppBase + isSubscribedOffset
local unsubscribeOffset = 0x13A7A60
local unsubscribeAddr = il2cppBase + unsubscribeOffset

-- Original bytes storage
local originalIsSubscribed = {}
local originalUnsubscribe = {}

-- Main menu loop
while true do
    local menuChoice = gg.choice({
        "🚀 Start Hack (Unlock Battle Pass)",
        "🛑 Deactivate Hack (Restore Original)",
        "❌ Quit"
    }, nil, "🐍 Snake.io Battle Pass Hack Menu 🛠️")

    if menuChoice == nil then
        break  -- Exit if canceled
    elseif menuChoice == 1 then
        -- Save original bytes if not already saved
        if #originalIsSubscribed == 0 then
            showLoading("💾 Backing up original data", 1)
            originalIsSubscribed = gg.getValues({
                {address = isSubscribedAddr, flags = gg.TYPE_DWORD},
                {address = isSubscribedAddr + 4, flags = gg.TYPE_DWORD}
            })
            originalUnsubscribe = gg.getValues({
                {address = unsubscribeAddr, flags = gg.TYPE_DWORD}
            })
        end
        
        showLoading("🔧 Applying patches", 2)
        -- Patch IsSubscribed to return true (MOV W0, #1; RET)
        gg.setValues({
            {address = isSubscribedAddr, flags = gg.TYPE_DWORD, value = 0x52800020},
            {address = isSubscribedAddr + 4, flags = gg.TYPE_DWORD, value = 0xD65F03C0}
        })
        -- Patch Unsubscribe to do nothing (RET)
        gg.setValues({
            {address = unsubscribeAddr, flags = gg.TYPE_DWORD, value = 0xD65F03C0}
        })
        gg.toast("🎉 Battle Pass Unlocked! Hack Activated. ✅")
        gg.sleep(1000)
        gg.alert("🔥 Hack Successfully Activated! 🔥\n\nEnjoy your unlocked Battle Pass features! 🐍💎")
    elseif menuChoice == 2 then
        if #originalIsSubscribed > 0 then
            showLoading("🔄 Restoring original code", 2)
            -- Restore original bytes
            gg.setValues({
                {address = isSubscribedAddr, flags = gg.TYPE_DWORD, value = originalIsSubscribed[1].value},
                {address = isSubscribedAddr + 4, flags = gg.TYPE_DWORD, value = originalIsSubscribed[2].value}
            })
            gg.setValues({
                {address = unsubscribeAddr, flags = gg.TYPE_DWORD, value = originalUnsubscribe[1].value}
            })
            gg.toast("🛡️ Hack Deactivated. Original restored. ✅")
        else
            gg.toast("⚠️ Hack not activated yet!")
        end
    elseif menuChoice == 3 then
        showLoading("👋 Exiting script", 1)
        gg.toast("🚪 Exiting script. Goodbye! 👋")
        os.exit()
    end
end