local Config = {}

Config.autosave_interval_sec = 120
Config._dirty = false
Config.data_dir = "perfmesh_v2"
Config.stored = Config.stored or {}

local function ensure_dir()
    if not file.IsDir(Config.data_dir, "DATA") then
        file.CreateDir(Config.data_dir)
    end
end

function Config.mark_dirty()
    Config._dirty = true
end

function Config.save()
    ensure_dir()
    file.Write(Config.data_dir .. "/config.json", util.TableToJSON(Config.stored, true))
    Config._dirty = false
end

function Config.load()
    ensure_dir()
    if file.Exists(Config.data_dir .. "/config.json", "DATA") then
        Config.stored = util.JSONToTable(file.Read(Config.data_dir .. "/config.json", "DATA")) or {}
    end
end

PerfMesh.Config = Config

PerfMesh.safe_call(Config.load)

timer.Create("PerfMesh.ConfigAutosave", Config.autosave_interval_sec, 0, function()
    if Config._dirty then
        PerfMesh.log("[PerfMesh] autosaving config")
        PerfMesh.safe_call(Config.save)
    end
end)

concommand.Add("perfmesh_config_mark_dirty", function(ply)
    if IsValid(ply) then return end
    Config.mark_dirty()
end)
