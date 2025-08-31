local function open()
    local frame = vgui.Create("DFrame")
    frame:SetSize(300, 200)
    frame:Center()
    frame:SetTitle("PerfMesh v" .. (PerfMesh.__v or "?"))
    frame:MakePopup()

    local status = vgui.Create("DLabel", frame)
    status:SetPos(10, 30)
    status:SetText("ACTIVE")

    timer.Create("PerfMesh.UIStatus", 1, 0, function()
        if not IsValid(status) then return end
        status:SetText(PerfMesh.Controller and PerfMesh.Controller.status() or "ACTIVE")
    end)

    local btnBal = vgui.Create("DButton", frame)
    btnBal:SetPos(10, 60)
    btnBal:SetText("Balanced")
    btnBal.DoClick = function() RunConsoleCommand("perfmesh_preset", "balanced") end

    local btnAgg = vgui.Create("DButton", frame)
    btnAgg:SetPos(100, 60)
    btnAgg:SetText("Aggressive")
    btnAgg.DoClick = function() RunConsoleCommand("perfmesh_preset", "aggressive") end

    local btnCin = vgui.Create("DButton", frame)
    btnCin:SetPos(200, 60)
    btnCin:SetText("Cinematic")
    btnCin.DoClick = function() RunConsoleCommand("perfmesh_preset", "cinematic") end

    local btnCsv = vgui.Create("DButton", frame)
    btnCsv:SetPos(10, 100)
    btnCsv:SetText("Export CSV")
    btnCsv.DoClick = function() RunConsoleCommand("perfmesh_export_metrics") end

    local btnDump = vgui.Create("DButton", frame)
    btnDump:SetPos(100, 100)
    btnDump:SetText("Dump State")
    btnDump.DoClick = function() RunConsoleCommand("perfmesh_dump_state") end

    local chkQuiet = vgui.Create("DCheckBoxLabel", frame)
    chkQuiet:SetPos(10, 140)
    chkQuiet:SetText("Quiet")
    chkQuiet:SetConVar("pm_quiet")
end

concommand.Add("perfmesh_ui", open)
