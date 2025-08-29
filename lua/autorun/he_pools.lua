-- he_pools.lua (shared, safe)
_G.pf = _G.pf or {}
pf.NPCPools = pf.NPCPools or pf.NPCPools or {}

-- only define SpawnFromPool if not present
if not pf.SpawnFromPool then
    function pf.SpawnFromPool(poolName, pos, ang)
        local pool = pf.NPCPools and pf.NPCPools[poolName]
        if not pool or #pool == 0 then return nil, "pool not found or empty" end
        local class = pool[math.random(#pool)]
        local ent = ents.Create(class)
        if not IsValid(ent) then return nil, "failed to create "..tostring(class) end
        ent:SetPos(pos or Vector(0,0,0))
        ent:SetAngles(ang or Angle(0,0,0))
        ent:Spawn()
        return ent, class
    end
end
