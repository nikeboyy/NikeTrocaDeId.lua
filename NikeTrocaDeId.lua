-----------------------------------------------------------------------------------------------------------------------------------------
-- PREPARES
-----------------------------------------------------------------------------------------------------------------------------------------
vRP._prepare('nikeboy/trocadeid/checkids', "SELECT * FROM vrp_user_ids WHERE user_id = @user_id")
vRP._prepare('nikeboy/trocadeid/checkvehicles', "SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id")
vRP._prepare('nikeboy/trocadeid/checkhomes', "SELECT * FROM vrp_homes_permissions WHERE user_id = @user_id")
vRP._prepare('nikeboy/trocadeid/checkpriority', "SELECT * FROM vrp_priority WHERE passport = @user_id")
vRP._prepare('nikeboy/trocadeid/checkvip', "SELECT * FROM fstore_appointments")

vRP._prepare('nikeboy/trocadeid/updateids', "UPDATE vrp_user_ids SET user_id = @user_id WHERE user_id = @nid")
vRP._prepare('nikeboy/trocadeid/updatedata', "UPDATE vrp_user_data SET user_id = @user_id WHERE user_id = @nid")
vRP._prepare('nikeboy/trocadeid/updateidentities', "UPDATE vrp_user_identities SET user_id = @user_id WHERE user_id = @nid")
vRP._prepare('nikeboy/trocadeid/updatemoneys', "UPDATE vrp_user_moneys SET user_id = @user_id WHERE user_id = @nid")
vRP._prepare('nikeboy/trocadeid/updatevehicles', "UPDATE vrp_user_vehicles SET user_id = @user_id WHERE user_id = @nid")
vRP._prepare('nikeboy/trocadeid/updatehomes', "UPDATE vrp_homes_permissions SET user_id = @user_id WHERE user_id = @nid")
vRP._prepare('nikeboy/trocadeid/updatepriority', "UPDATE vrp_priority SET user_id = @passport WHERE user_id = @nid")
vRP._prepare('nikeboy/trocadeid/updatevips', "UPDATE fstore_appointments SET command = @command WHERE command = @oldcommand")

vRP._prepare('nikeboy/trocadeid/removeids', "DELETE FROM vrp_user_ids WHERE user_id = @user_id")
vRP._prepare('nikeboy/trocadeid/removedatas', "DELETE FROM vrp_user_data WHERE user_id = @user_id")
vRP._prepare('nikeboy/trocadeid/removeidentities', "DELETE FROM vrp_user_identities WHERE user_id = @user_id")
vRP._prepare('nikeboy/trocadeid/removemoneys', "DELETE FROM vrp_user_moneys WHERE user_id = @user_id")

-----------------------------------------------------------------------------------------------------------------------------------------
-- CODE
-----------------------------------------------------------------------------------------------------------------------------------------
local trocadeidlog = ""

RegisterCommand('trocarid',function(source,args)
    local user_id = vRP.getUserId(source)
    if vRP.hasGroup(user_id,'Owner') or vRP.hasGroup(user_id,'Admin') or vRP.hasGroup(user_id,'Cm') or source == 0 then
        local n_id = tonumber(args[1])
        local newid = tonumber(args[2])
        local nsource = vRP.getUserSource(n_id)
        local ids = vRP.query('nikeboy/trocadeid/checkids', {user_id = newid})
        local vehicles = vRP.query('nikeboy/trocadeid/checkvehicles', {user_id = n_id})
        local homes = vRP.query('nikeboy/trocadeid/checkhomes', {user_id = n_id})
        local priority = vRP.query('nikeboy/trocadeid/checkpriority', {passport = n_id})
        local vips = vRP.query('nikeboy/trocadeid/checkvip')

        if nsource then
            vRP.kick(nsource,'O seu ID está sendo alterado.')
        end

        if tostring(ids[1]) == 'nil' then
            kushUpdates(newid, n_id)
        else
            kushDeletes(newid)
            Wait(1000)
            kushUpdates(newid, n_id)
        end

        if tostring(vehicles[1]) ~= 'nil' then
            vRP.execute('nikeboy/trocadeid/updatevehicles',{user_id = newid, nid = n_id})
        end

        if tostring(homes[1]) ~= 'nil' then
            vRP.execute('nikeboy/trocadeid/updatehomes',{user_id = newid, nid = n_id})
        end

        if tostring(priority[1]) ~= 'nil' then
            vRP.execute('nikeboy/trocadeid/updatepriority',{passport = newid, nid = n_id})
        end

        local aspas = '"'
        local idvip = ""..aspas..""..n_id..""..aspas
        local idvip2 = ""..aspas..""..newid..""..aspas
        for k,v in pairs(vips) do
            if string.find(v.command,idvip) then
                local newtext = string.gsub(v.command,idvip,idvip2)
                vRP.execute('nikeboy/trocadeid/updatevips',{command = newtext, oldcommand = v.command})
            end
        end

        TriggerClientEvent('Notify',source,'sucesso','ID '..n_id..' Trocado para o '..newid)
        SendWebhookMessage(trocadeidlog, "```prolog\n[ID]: "..user_id.."\n[TROCOU O ID]: "..args[1].."\n[PARA O ID]: "..args[2]..""..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
    end
end)
