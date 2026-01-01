local setNotoMonoText = require("@libs/notoMonoText")
local tableAppend = require("@libs/tableAppend")

local function getLinksFromNames()
    local result = {}

    for i = 1, ll.GetNumberOfPrims() do
        local name = ll.GetLinkName(i)

        local a, b = name:match("^line%s+(%d+)_(%d+)$")

        if a and b then
            a = tonumber(a)
            b = tonumber(b)

            result[a] = result[a] or {}
            result[a][b] = i
        end
    end

    return result
end

local SORT_BY_SCRIPT_TIME = 4
local function getAgentsStats(sortBy: number?): {any}
    sortBy = sortBy or SORT_BY_SCRIPT_TIME
    local agents = ll.GetAgentList(AGENT_LIST_REGION, {})
    for i, agent in ipairs(agents) do
        local stats = ll.GetObjectDetails(agent, {
            OBJECT_NAME,
            OBJECT_RUNNING_SCRIPT_COUNT,
            OBJECT_SCRIPT_TIME,
            OBJECT_SCRIPT_MEMORY,
            OBJECT_RENDER_WEIGHT
        })
        agents[i] = {agent}
        tableAppend(agents[i], stats)
    end
    -- agentID, name, scriptcount, scripttime, scriptmemory, renderweight
    table.sort(agents, function(a, b)
        return a[sortBy] > b[sortBy]
    end)
    return agents
end

local function getFormattedStats(name: string, scriptCount: number, scriptTime: number, scriptMemory: number, renderWeight: number)
    scriptTime *= 1000000
    if scriptTime > 9999 then scriptTime = 9999 end
    scriptMemory /= 1024*1024
    if scriptMemory > 9999 then scriptMemory = 9999 end

    local divisions = 1
    while renderWeight > 999 do
        renderWeight /= 1000
        divisions += 1
    end
    local divisors = {" ", "K", "M"}
    local renderWeight2 = math.round(renderWeight) .. (divisors[divisions])
    return string.format(
        "%- 32s% 4s% 4s% 4s% 4s",
        name,
        scriptCount,
        string.sub(tostring(scriptTime), 1, 4),
        string.sub(tostring(scriptMemory), 1, 4),
        string.sub(tostring(renderWeight2), 1, 4)
    )
end

local function setBoardStats(agents: {any}, lines: {any}): nil
    local result = {}
    for i = 1, #lines do
        local str = ""
        if agents[i] ~= nil then
            str = getFormattedStats(agents[i][2], agents[i][3], agents[i][4], agents[i][5], agents[i][6])
        end
        tableAppend(result, setNotoMonoText(str, lines[i]))
    end
    ll.SetLinkPrimitiveParamsFast(0, result)
    return
end

LLTimers:every(1, function()
    local lines = getLinksFromNames()
    local agents = getAgentsStats()
    setBoardStats(agents, lines)
end)
