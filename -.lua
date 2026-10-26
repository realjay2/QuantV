local B = {}

B.char = string.char
B.ton = tonumber
B.dec = function(s)
	return (s:gsub("%x%x", function(c) return B.char(B.ton(c, 16)) end))
end

if getgenv().BypassRan_v2 then return end
getgenv().BypassRan_v2 = true

B.GetService = game[B.dec("47657453657276696365")]
B.Players = B.GetService(game, B.dec("506c6179657273"))
B.LogService = B.GetService(game, B.dec("4c6f6753657276696365"))
B.ReplicatedStorage = B.GetService(game, B.dec("5265706c69636174656453746f72616765"))

B.LocalPlayer = B.Players.LocalPlayer
if not B.LocalPlayer then
	repeat task.wait() until B.Players.LocalPlayer
	B.LocalPlayer = B.Players.LocalPlayer
end

B.rawFindService = game.FindService
B.rawGetHistory = B.LogService.GetLogHistory
B.rawKick = B.LocalPlayer.Kick
B.rawError = B.LogService.Error
B.realFireServer = Instance.new("RemoteEvent").FireServer

B.lodTag = B.dec("5b4c4f445d204d697373696e672067656f6d65747279206368756e6b2049443a20")
B.lastLOD = nil

B.wrapped = setmetatable({}, { __mode = "k" })
B.shadows = setmetatable({}, { __mode = "k" })

B.wrap = function(meta)
	if B.wrapped[meta] then return end
	B.wrapped[meta] = true

	local baseIndex = meta.__index
	local baseNamecall = meta.__namecall
	local indexIsFn = type(baseIndex) == "function"

	if baseIndex then
		meta.__index = function(self, key)
			local map = B.shadows[self]
			if map and map[key] ~= nil then return map[key] end
			if indexIsFn then return baseIndex(self, key) end
			return baseIndex[key]
		end
	end

	if baseNamecall then
		meta.__namecall = function(self, ...)
			local map = B.shadows[self]
			if map then
				local method = getnamecallmethod and getnamecallmethod() or debug.info(1, "n")
				local fn = map[method]
				if fn then return fn(self, ...) end
			end
			return baseNamecall(self, ...)
		end
	end
end

B.shadow = function(instance, key, fn)
	local map = B.shadows[instance]
	if not map then map = {}; B.shadows[instance] = map end
	map[key] = fn
	local meta = getmetatable(instance)
	if meta then B.wrap(meta) end
end

B.MASKED_SERVICES = {
	[B.dec("4170705570646174655365727669636500")] = true,
	[B.dec("55474356616c69646174696f6e53657276696365")] = true,
}

B.findServiceHook = function(self, name, ...)
	if B.MASKED_SERVICES[name] then return nil end
	return B.rawFindService(self, name, ...)
end

B.fireServerHook = function(remote, category, ...)
	if category == "HeartbeatAck" then
		return B.realFireServer(remote, category, ...)
	end
	return nil
end

B.kickHook = function() end

B.errorHook = function(self, message, ...)
	if type(message) == "string" and message:sub(1, #B.lodTag) == B.lodTag then
		B.lastLOD = message
		return
	end
	return B.rawError(self, message, ...)
end

B.historyHook = function(self)
	if type(self) ~= "userdata" then
		return B.rawGetHistory(B.LogService)
	end

	local history = B.rawGetHistory(self)

	if B.lastLOD then
		for i = #history, math.max(1, #history - 60), -1 do
			local entry = history[i]
			if entry and entry.message == B.lastLOD then
				return history
			end
		end

		local copy = {}
		for i = 1, #history do copy[i] = history[i] end
		copy[#copy + 1] = {
			message = B.lastLOD,
			messageType = Enum.MessageType.MessageError,
			timestamp = os.clock(),
		}
		return copy
	end

	return history
end

B.shadow(game, "FindService", B.findServiceHook)
B.shadow(B.LogService, "GetLogHistory", B.historyHook)
B.shadow(B.LogService, "Error", B.errorHook)
B.shadow(B.LocalPlayer, "Kick", B.kickHook)

B.FLAG_KEYS = {
	"InstanceMetatableIndexWrapped",
	"InstanceMetatableNamecallWrapped",
	"KnitReportDetectionOverwritten",
	"GameFindServiceShadowed",
	"LogServiceGetLogHistoryShadowed",
	"LocalPlayerKickShadowed",
	"GetLogHistoryBehaviorHooked",
	"BypassConsoleWatermark",
	"LODHandlerDestroyed",
}

B.BY_NAME = {
	FireServer = B.fireServerHook,
	FindService = B.findServiceHook,
	GetLogHistory = B.historyHook,
	Kick = B.kickHook,
}
B.BY_VALUE = {
	[B.realFireServer] = B.fireServerHook,
	[B.rawFindService] = B.findServiceHook,
	[B.rawGetHistory] = B.historyHook,
	[B.rawKick] = B.kickHook,
}

B.scan = function()
	local list = {}
	if type(getgc) ~= "function" then return list end
	local ok, gc = pcall(getgc, true)
	if not ok then return list end
	for _, obj in ipairs(gc) do
		if type(obj) == "function" then
			local ok2, src = pcall(debug.info, obj, "s")
			if ok2 and type(src) == "string" and src:find("AntiCheatController", 1, true) then
				list[#list + 1] = obj
			end
		end
	end
	return list
end

B.upcount = function(fn)
	local ok, n = pcall(debug.info, fn, "u")
	if ok and type(n) == "number" then return n end
	local i = 0
	while true do
		i += 1
		local ok2 = pcall(debug.getupvalue, fn, i)
		if not ok2 then return i - 1 end
	end
end

B.hook = function()
	local closures = B.scan()
	if #closures == 0 then return false end

	for _, fn in ipairs(closures) do
		local n = B.upcount(fn)
		for i = 1, n do
			local name, val = debug.getupvalue(fn, i)
			if type(val) == "function" then
				local repl = B.BY_NAME[name] or B.BY_VALUE[val]
				if repl and val ~= repl then
					pcall(debug.setupvalue, fn, i, repl)
				end
			end
		end
	end

	local counts, best, bestN = {}, nil, 0
	for _, fn in ipairs(closures) do
		local n = B.upcount(fn)
		for i = 1, n do
			local _, val = debug.getupvalue(fn, i)
			if type(val) == "table" then
				counts[val] = (counts[val] or 0) + 1
			end
		end
	end
	for t, n in pairs(counts) do
		if n > bestN then best, bestN = t, n end
	end
	if best then
		for _, k in ipairs(B.FLAG_KEYS) do best[k] = true end
		getgenv().BypassFlags = best
	end

	for _, fn in ipairs(closures) do
		if B.upcount(fn) == 1 then
			local _, val = debug.getupvalue(fn, 1)
			if type(val) == "boolean" then
				pcall(debug.setupvalue, fn, 1, false)
				break
			end
		end
	end

	return true
end

B.killLOD = function()
	local holder = B.LocalPlayer:FindFirstChild("PlayerScripts")
	if not holder then return end
	for _, nm in ipairs({ "LODHandler", "Entry" }) do
		local h = holder:FindFirstChild(nm)
		if h then pcall(function() h:Destroy() end) end
	end
end

B.repointLOD = function()
	if type(getgc) ~= "function" then return end
	local ok, gc = pcall(getgc, true)
	if not ok then return end
	for _, obj in ipairs(gc) do
		if type(obj) == "function" then
			local ok2, src = pcall(debug.info, obj, "s")
			if ok2 and type(src) == "string" and src:find("LOD", 1, true) then
				local n = B.upcount(obj)
				for i = 1, n do
					local _, val = debug.getupvalue(obj, i)
					if val == B.rawGetHistory then
						pcall(debug.setupvalue, obj, i, B.historyHook)
					end
				end
			end
		end
	end
end

pcall(B.killLOD)
pcall(B.hook)
task.spawn(function()
	for _ = 1, 10 do
		task.wait(0.5)
		pcall(B.hook)
	end
end)
task.spawn(B.repointLOD)

warn("bitblocker v2 installed")
