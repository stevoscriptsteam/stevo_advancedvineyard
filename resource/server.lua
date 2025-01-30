if not lib.checkDependency('stevo_lib', '1.7.2') then error('stevo_lib 1.7.2 required for stevo_advancedvineyard') end
lib.versionCheck('stevoscriptsteam/stevo_advancedvineyard')
lib.locale()
local stevo_lib = exports['stevo_lib']:import()
local config = lib.require('config')
local WineProcessing = {}
local CurrentlyBottling = {}


lib.callback.register('stevo_advancedvineyard:grapePicked', function(source)
    local nearPoint = false 
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)

    for i = 1, #config.grapePicking.points do 
        local point = config.grapePicking.points[i]
        local dist = #(point - coords)
        if dist < config.grapePicking.interactDistance then 
            nearPoint = true
            break 
        end
    end

    if not nearPoint then
        local name = GetPlayerName(source)
        local identifier = stevo_lib.GetIdentifier(source)

        lib.print.info(('User: %s (%s) tried to exploit stevo_vineyard'):format(name, identifier))
        if config.dropCheaters then 
            DropPlayer(source, 'Trying to exploit stevo_vineyard')
        end
        return false
    end

    math.randomseed(os.time())

    local grapeItem = config.grapePicking.items[math.random(1, #config.grapePicking.items)]
    local grapeAmount = math.random(config.grapePicking.pickChance.min, config.grapePicking.pickChance.max)

    stevo_lib.AddItem(source, grapeItem, grapeAmount)

    if config.debug then
        local name = GetPlayerName(source)
        local identifier = stevo_lib.GetIdentifier(source)
        lib.print.info(('Added %s %s to %s (%s) via stevo_vineyard:grapePicked'):format(grapeAmount, grapeItem, name, identifier))
    end

    return true
end)

lib.callback.register('stevo_advancedvineyard:getWineProcess', function(source)
    local identifier = stevo_lib.GetIdentifier(source)

    if not WineProcessing[identifier] then 
        if config.debug then
            local name = GetPlayerName(source)
            local identifier = stevo_lib.GetIdentifier(source)
            lib.print.info(('Tried to retrieve wine process for %s (%s) but no process was active.'):format(name, identifier))
        end

        return false 
    end

    if config.debug then
        local name = GetPlayerName(source)
        local identifier = stevo_lib.GetIdentifier(source)
        lib.print.info(('Retrieved wine process for %s (%s)'):format(name, identifier))
    end

    return WineProcessing[identifier], os.time()
end)

lib.callback.register('stevo_advancedvineyard:startWineProcess', function(source)
    local identifier = stevo_lib.GetIdentifier(source)
    local whiteGrapes = stevo_lib.HasItem(source, 'whitegrape') or 0
    local redGrapes = stevo_lib.HasItem(source, 'redgrape') or 0
    local totalGrapes = redGrapes + whiteGrapes
    local whiteBottles = math.floor(whiteGrapes / config.grapeProcessing.grapesPerBottle)
    local redBottles = math.floor(redGrapes / config.grapeProcessing.grapesPerBottle)


    if whiteBottles < 1 and redBottles < 1 then
        if config.debug then
            local name = GetPlayerName(source)
            lib.print.info(('%s (%s) Tried to start processing wine but didnt have any grapes'):format(name, identifier))
        end
        return false 
    end
    

    stevo_lib.RemoveItem(source, 'whitegrape', whiteBottles * config.grapeProcessing.grapesPerBottle)
    stevo_lib.RemoveItem(source, 'redgrape', redBottles * config.grapeProcessing.grapesPerBottle)

    local processTime = config.grapeProcessing.processDuration * totalGrapes
    local time = os.time()
    local finishTime = time + processTime
    local grapeData = {
        whiteGrapes = whiteGrapes,
        whiteBottles = whiteBottles,
        redGrapes = redGrapes,
        redBottles = redBottles,
        totalGrapes = totalGrapes,
        startTime = time,
        finishTime = finishTime
    }

    MySQL.insert.await('INSERT INTO `stevo_vineyard_processing` (identifier, data) VALUES (?, ?)', {
        identifier, json.encode(grapeData)
    })

    local processTable = {
        identifier = identifier,
        data = grapeData
    }

    WineProcessing[identifier] = processTable

    if config.debug then
        local name = GetPlayerName(source)
        local identifier = stevo_lib.GetIdentifier(source)
        lib.print.info(('Started wine process for %s (%s)'):format(name, identifier))
    end

    return true
end)

lib.callback.register('stevo_advancedvineyard:bottleWine', function(source)
    local identifier = stevo_lib.GetIdentifier(source)
    local wineProcess = WineProcessing[identifier]
    local totalBottles = wineProcess.data.whiteBottles + wineProcess.data.redBottles
    local hasBottles = stevo_lib.HasItem(source, config.bottleItem) 

    if not hasBottles or hasBottles < totalBottles then 
        if config.debug then
            local name = GetPlayerName(source)
            local identifier = stevo_lib.GetIdentifier(source)
            lib.print.info(('%s (%s) Tried to bottle wine but didnt have enough bottles'):format(name, identifier))
        end
        return false 
    end

    stevo_lib.RemoveItem(source, config.bottleItem, totalBottles)

    CurrentlyBottling[source] = {white = wineProcess.data.whiteBottles, red = wineProcess.data.redBottles}
    WineProcessing[identifier] = nil

    MySQL.rawExecute.await('DELETE FROM `stevo_vineyard_processing` WHERE identifier = ?', {
        identifier
    })


    if config.debug then
        local name = GetPlayerName(source)
        local identifier = stevo_lib.GetIdentifier(source)
        lib.print.info(('Started wine bottling process for %s (%s)'):format(name, identifier))
    end

    return true
end)

lib.callback.register('stevo_advancedvineyard:sellWine', function(source)
    local wineSold = 0 
    local profit = 0
    local soldWine = false
    local wineItems = {'redwinebottle', 'whitewinebottle'}

    for _, wine in pairs(wineItems) do
        local amount = stevo_lib.HasItem(source, wine)

        if not amount or amount > 0 then
            local salePrice = config.wineBoss.buyItems[wine].sale
            local payout = amount * salePrice

            stevo_lib.RemoveItem(source, wine, amount)

            wineSold = wineSold + amount
            profit = profit + payout
            soldWine = true
        end
    end

    if soldWine then
        stevo_lib.AddItem(source, config.moneyItem, profit)
    end

    return soldWine, profit, wineSold
end)

lib.callback.register('stevo_advancedvineyard:buyEmptyBottles', function(source, bottleCount)
    local identifier = stevo_lib.GetIdentifier(source)
    local bottleCost = config.wineBoss.emptyBottleCost
    local totalCost = bottleCount * bottleCost
    local playerMoney = stevo_lib.HasItem(source, config.moneyItem)

    if playerMoney >= totalCost then
        stevo_lib.RemoveItem(source, config.moneyItem, totalCost)
        stevo_lib.AddItem(source, config.bottleItem, bottleCount)

        if config.debug then
            local name = GetPlayerName(source)
            lib.print.info(('%s (%s) purchased %s bottles for %s money.'):format(name, identifier, bottleCount, totalCost))
        end

        return bottleCount
    else
        if config.debug then
            local name = GetPlayerName(source)
            lib.print.info(('%s (%s) tried to buy %s bottles but lacked enough money. Required: %s, Available: %s'):format(name, identifier, bottleCount, totalCost, playerMoney))
        end

        return false
    end
end)



RegisterNetEvent('stevo_advancedvineyard:bottledWine', function()
    if not CurrentlyBottling[source] then return end

    stevo_lib.AddItem(source, 'redwinebottle', CurrentlyBottling[source].red)
    stevo_lib.AddItem(source, 'whitewinebottle', CurrentlyBottling[source].white)

    if config.debug then
        local name = GetPlayerName(source)
        local identifier = stevo_lib.GetIdentifier(source)
        lib.print.info(('%s (%s) Finished Bottling process and got %s red wine bottles and %s white wine bottles'):format(name, identifier, CurrentlyBottling[source].red, CurrentlyBottling[source].white))
    end
end)


AddEventHandler('onResourceStart', function(resource)
    if resource ~= cache.resource then return end

    
    local tableExists, _ = pcall(MySQL.scalar.await, 'SELECT 1 FROM stevo_vineyard_processing')

    if not tableExists then
        MySQL.query([[CREATE TABLE IF NOT EXISTS `stevo_vineyard_processing` (
        `id` INT NOT NULL AUTO_INCREMENT,
        `identifier` VARCHAR(50) NOT NULL,
        `data` longtext NOT NULL,
        PRIMARY KEY (`id`)
        )]])

        lib.print.info('[Stevo Scripts] Deployed database table for stevo_advancedvineyard')
    end

    local wineProcesses = MySQL.query.await('SELECT * FROM `stevo_vineyard_processing`', {})

    if wineProcesses then
        for i = 1, #wineProcesses do
            local wineProcess =  wineProcesses[i]

            local processTable = {
                identifier = wineProcess.identifier,
                data = json.decode(wineProcess.data),
            }

            WineProcessing[wineProcess.identifier] = processTable
        end
    end
end)


AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
end)



 
