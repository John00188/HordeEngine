if not CLIENT then return end

local UI = {}
UI.hist = {}
UI.maxHist = 120
UI.last = { used = 0, budget = 4, hold=false, quiet=false, ragdolls=0, npc=0, preset="balanced" }

-- receive live metrics from server
net.Receive("perfmesh_metrics2", function()
  UI.last.used   = net.ReadFloat()
  UI.last.budget = net.ReadFloat()
  UI.last.hold   = net.ReadUInt(1) == 1
  UI.last.quiet  = net.ReadUInt(1) == 1
  UI.last.ragdolls = net.ReadUInt(16)
  UI.last.npc      = net.ReadUInt(16)
  UI.last.preset   = net.ReadString()

  table.insert(UI.hist, UI.last.used)
  if #UI.hist > UI.maxHist then table.remove(UI.hist, 1) end

  -- live-refresh labels if panel is open
  if IsValid(UI.frame) then UI:updateLabels() end
end)

-- fonts
surface.CreateFont("PM_Title",  { font="Tahoma", size=20, weight=800 })
surface.CreateFont("PM_Text",   { font="Tahoma", size=16, weight=500 })
surface.CreateFont("PM_Small",  { font="Tahoma", size=13, weight=500 })

-- simple sparkline panel
local function Sparkline(parent)
  local pnl = vgui.Create("DPanel", parent)
  pnl:SetTall(42)
  pnl.Paint = function(self,w,h)
    surface.SetDrawColor(20,20,25,230)
    surface.DrawRect(0,0,w,h)
    -- axes
    surface.SetDrawColor(60,60,70,255)
    surface.DrawLine(0,h-1,w,h-1)
    -- draw history
    local B = math.max(0.1, UI.last.budget or 4)
    local n = #UI.hist
    if n < 2 then return end
    local step = w / (UI.maxHist-1)
    surface.SetDrawColor(255,255,255,255)
    local lastx, lasty
    for i=1,n do
      local v = math.Clamp(UI.hist[i]/B, 0, 1)
      local x = (i-1) * step
      local y = h - v*h
      if lastx then surface.DrawLine(lastx,lasty,x,y) end
      lastx, lasty = x, y
    end
    -- budget line
    local by = h - math.Clamp(1.0,0,1)*h
    surface.SetDrawColor(120,180,255,180)
    surface.DrawLine(0, by, w, by)
  end
  return pnl
end

function UI:updateLabels()
  if not IsValid(self.frame) then return end
  local used   = self.last.used or 0
  local budget = self.last.budget or 4
  local head   = math.max(0, budget - used)

  self.lblBudget:SetText(string.format("Budget: %.2f ms", budget))
  self.lblUsed:SetText(string.format("Used (EMA): %.2f ms", used))
  self.lblHead:SetText(string.format("Headroom: %.2f ms", head))
  self.lblRag:SetText("Ragdolls: "..tostring(self.last.ragdolls))
  self.lblNPC:SetText("NPCs: "..tostring(self.last.npc))

  local status = self.last.hold and "HOLD" or "ACTIVE"
  self.pill:SetText(status)
  self.pill:SetTextColor(self.last.hold and Color(255,220,120) or Color(180,255,180))
  self.btnQuiet:SetText(self.last.quiet and "Quiet: ON" or "Quiet: OFF")
  self.btnPreset:SetText("Preset: "..tostring(self.last.preset))
end

local function MakePill(parent)
  local btn = vgui.Create("DButton", parent)
  btn:SetTall(24)
  btn:SetText("ACTIVE")
  btn:SetFont("PM_Small")
  btn.Paint = function(self,w,h)
    draw.RoundedBox(12, 0,0,w,h, Color(40,40,45,230))
    local col = self:GetText() == "HOLD" and Color(130,100,30) or Color(40,120,50)
    draw.RoundedBox(12, 1,1,w-2,h-2, col)
  end
  return btn
end

-- build UI
local function BuildUI()
  if IsValid(UI.frame) then UI.frame:Remove() end

  local f = vgui.Create("DFrame")
  f:SetSize(460, 310)
  f:Center()
  f:SetTitle("")
  f:ShowCloseButton(true)
  f:MakePopup()
  f.Paint = function(self,w,h)
    surface.SetDrawColor(25,25,30,245)
    surface.DrawRect(0,0,w,h)
    draw.SimpleText("PerfMesh v0.2.1", "PM_Title", 12, 8, Color(255,255,255))
  end
  UI.frame = f

  UI.pill = MakePill(f)
  UI.pill:SetPos(330, 10)
  UI.pill:SetWide(110)
  UI.pill.DoClick = function() RunConsoleCommand("pm_pid_hold", UI.last.hold and "0" or "1") end

  local y0 = 48
  UI.lblBudget = vgui.Create("DLabel", f); UI.lblBudget:SetFont("PM_Text"); UI.lblBudget:SetPos(12, y0);     UI.lblBudget:SetText("Budget: --")
  UI.lblUsed   = vgui.Create("DLabel", f); UI.lblUsed:SetFont("PM_Text");   UI.lblUsed:SetPos(12, y0+22);   UI.lblUsed:SetText("Used: --")
  UI.lblHead   = vgui.Create("DLabel", f); UI.lblHead:SetFont("PM_Text");   UI.lblHead:SetPos(12, y0+44);   UI.lblHead:SetText("Headroom: --")

  UI.lblRag    = vgui.Create("DLabel", f); UI.lblRag:SetFont("PM_Small");   UI.lblRag:SetPos(320, y0+22);   UI.lblRag:SetText("Ragdolls: --")
  UI.lblNPC    = vgui.Create("DLabel", f); UI.lblNPC:SetFont("PM_Small");   UI.lblNPC:SetPos(320, y0+44);   UI.lblNPC:SetText("NPCs: --")

  local spark = Sparkline(f)
  spark:SetPos(12, y0+72)
  spark:SetWide(436)

  -- Preset cycle button
  UI.btnPreset = vgui.Create("DButton", f)
  UI.btnPreset:SetPos(12, y0+124)
  UI.btnPreset:SetSize(140, 28)
  UI.btnPreset:SetText("Preset: balanced")
  UI.btnPreset.DoClick = function()
    local order = { "balanced", "aggressive", "cinematic" }
    local cur = UI.last.preset or "balanced"
    local idx = 1
    for i,n in ipairs(order) do if n==cur then idx=i break end end
    local nextn = order[(idx%#order)+1]
    RunConsoleCommand("perfmesh_preset", nextn)
  end

  -- Quiet toggle
  UI.btnQuiet = vgui.Create("DButton", f)
  UI.btnQuiet:SetPos(168, y0+124)
  UI.btnQuiet:SetSize(120, 28)
  UI.btnQuiet:SetText("Quiet: OFF")
  UI.btnQuiet.DoClick = function()
    RunConsoleCommand("pm_quiet", UI.last.quiet and "0" or "1")
  end

  -- Export / Dump
  local btnCSV = vgui.Create("DButton", f)
  btnCSV:SetPos(300, y0+124)
  btnCSV:SetSize(70, 28)
  btnCSV:SetText("CSV")
  btnCSV.DoClick = function() RunConsoleCommand("perfmesh_export_metrics") end

  local btnDump = vgui.Create("DButton", f)
  btnDump:SetPos(378, y0+124)
  btnDump:SetSize(70, 28)
  btnDump:SetText("Dump")
  btnDump.DoClick = function() RunConsoleCommand("perfmesh_dump_state") end

  -- footer hint
  local hint = vgui.Create("DLabel", f)
  hint:SetPos(12, 282)
  hint:SetFont("PM_Small")
  hint:SetText("Tip: HOLD toggles controller outputs. CSV/Dump files -> garrysmod/data/perfmesh_v2/")
  hint:SizeToContents()

  UI:updateLabels()
end

-- console toggle
concommand.Add("perfmesh_ui_toggle", function()
  if IsValid(UI.frame) then
    UI.frame:Close()
  else
    BuildUI()
  end
end)
