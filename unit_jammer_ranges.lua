function widget:GetInfo()
    return {
        name      = "Radar Jammer Ranges v1",
        desc      = "Displays radar jammer ranges",
        author    = "[teh]decay",
        date      = "08 jan 2014",
        license   = "The BSD License",
        layer     = 0,
        version   = 1,
        enabled   = true  -- loaded by default
    }
end

-- project page on github: https://github.com/jamerlan/unit_jammer_ranges

-- Changelog
-- v2 (for future)

local GetUnitPosition     = Spring.GetUnitPosition
local glColor = gl.Color
local glDepthTest = gl.DepthTest
local glDrawGroundCircle  = gl.DrawGroundCircle
local GetUnitDefID = Spring.GetUnitDefID
local spGetAllUnits = Spring.GetAllUnits
local spGetSpectatingState = Spring.GetSpectatingState
local spGetMyPlayerID		= Spring.GetMyPlayerID
local spGetPlayerInfo		= Spring.GetPlayerInfo

local blastCircleDivs = 100
local udefTab				= UnitDefs

local radarJammers = {}

local radarJammerIds = {}
radarJammerIds[UnitDefNames["armjamt"].id] = true
radarJammerIds[UnitDefNames["armveil"].id] = true
radarJammerIds[UnitDefNames["armaser"].id] = true
radarJammerIds[UnitDefNames["corshroud"].id] = true
radarJammerIds[UnitDefNames["corjamt"].id] = true
radarJammerIds[UnitDefNames["corspec"].id] = true

function isJammer(unitDefID)
    return radarJammerIds[unitDefID] ~= nil
end

function widget:UnitFinished(unitID, unitDefID, unitTeam)
    if isJammer(unitDefID) then
        radarJammers[unitID] = true
    end
end

function widget:UnitDestroyed(unitID, unitDefID, unitTeam)
    if radarJammers[unitID] then
        radarJammers[unitID] = nil
    end
end

function widget:UnitEnteredLos(unitID, unitTeam)
    if not spectatorMode then
        local unitDefID = GetUnitDefID(unitID)
        if isJammer(unitDefID) then
            radarJammers[unitID] = true
        end
    end
end

function widget:UnitCreated(unitID, unitDefID, teamID, builderID)
    if isJammer(unitDefID) then
        radarJammers[unitID] = true
    end
end

function widget:UnitTaken(unitID, unitDefID, unitTeam, newTeam)
    if isJammer(unitDefID) then
        radarJammers[unitID] = true
    end
end


function widget:UnitGiven(unitID, unitDefID, unitTeam, oldTeam)
    if isJammer(unitDefID) then
        radarJammers[unitID] = true
    end
end

function widget:UnitLeftLos(unitID, unitDefID, unitTeam)
    if not spectatorMode then
        if radarJammers[unitID] then
            radarJammers[unitID] = nil
        end
    end
end



function widget:DrawWorldPreUnit()
    local _, specFullView, _ = spGetSpectatingState()

    if not specFullView then
        notInSpecfullmode = true
    else
        if notInSpecfullmode then
            detectSpectatorView()
        end
        notInSpecfullmode = false
    end

    glDepthTest(true)

    for unitID in pairs(radarJammers) do
        local x,y,z = GetUnitPosition(unitID)
        local udefId = GetUnitDefID(unitID);
        if udefId ~= nil then
            local udef = udefTab[udefId]

            glColor(1, 0, 1, .4)

            glDrawGroundCircle(x, y, z, udef.jammerRadius, blastCircleDivs)
        end
    end
    glDepthTest(false)
end

function widget:PlayerChanged(playerID)
    detectSpectatorView()
    return true
end

function widget:Initialize()
    detectSpectatorView()
    return true
end

function detectSpectatorView()
    local _, _, spec, teamId = spGetPlayerInfo(spGetMyPlayerID())

    if spec then
        spectatorMode = true
    end

    local visibleUnits = spGetAllUnits()
    if visibleUnits ~= nil then
        for _, unitID in ipairs(visibleUnits) do
            local udefId = GetUnitDefID(unitID)
            if udefId ~= nil then
                if isJammer(udefId) then
                    radarJammers[unitID] = true
                end
            end
        end
    end
end
