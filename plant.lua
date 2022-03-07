-- {program="turtle.plantar",version="0.50",date="2020-08-28"}
---------------------------------------
---turtle.plantar by goga
---2020-08-28, v0.50    initial
---
local programName = "Plantador"
local programVersion = "0.50"

local sSeed = 1
local waitTime = 60
local x = 8
local y = 8
local useSlot2 = false;

local function tr(n)
    if n == nil then
        n = 0
    end
    for i = 0, n, 1 do
        turtle.turnRight()
    end
end

local function tl(n)
    if n == nil then
        n = 0
    end
    for i = 0, n, 1 do
        turtle.turnLeft()
    end
end

local function tf(n)
    if n == nil then
        n = 0
    end
    for i = 0, n, 1 do
        turtle.forward()
    end
end

local function tb(n)
    if n == nil then
        n = 0
    end
    for i = 0, n, 1 do
        turtle.back()
    end
end

local function dD()
    turtle.digDown()
end

local function pD()
    turtle.placeDown()
end

local function meiaVolta()
    tl(1)
end

local function ss(n)
    turtle.select(n)
end

local function sK(n)
    if n == nil then
        n = 64
    end
    turtle.suck(n)
end

local function pause(n)
    if n == nil or n == 0 then
        n = waitTime
    end
    os.sleep(n)
end

local function sair(motivo)
    if motivo == nil then
        motivo = "erro desconhecido!"
    end
    print(motivo)
    print("Saindo...")
    os.exit(0, true)
end

local function getSeeds(n)
    local atual_seeds = turtle.getItemCount(sSeed) + turtle.getItemCount(sSeed + 1)
    if x * y > 64 then
        useSlot2 = true
    end
    meiaVolta()
    local tries = 0
    while turtle.getItemCount(sSeed) + turtle.getItemCount(sSeed + 1) == atual_seeds and tries <= 2 do
        if n == nil then
            print("   buscando mais sementes:...")
        end
        ss(sSeed)
        sK(64 - turtle.getItemCount(sSeed))
        if useSlot2 then
            ss(sSeed + 1)
            sK(64 - turtle.getItemCount(sSeed + 1))
        end
        pause(1)
        tries = tries + 1
    end
    meiaVolta()
    if n == nil then
        if turtle.getItemCount(sSeed) == atual_seeds then
            sair("   sem sementes!")
        end
    end
end

local function virarCorreto(n)
    if math.fmod(n, 2) == 0 then
        tr()
    else
        tl()
    end
end

local function retornar()
    tb()
    tr()
    tf(x - 2)
    tr()
end

local function semear()
    if useSlot2 and turtle.getItemCount(sSeed + 1) > 1 then
        ss(sSeed + 1)
    else
        ss(sSeed)
    end
    if not turtle.detectDown() then
        if turtle.getItemCount(sSeed) > 1 then
            dD()
            pD()
        else

        end
    end
    tf()
end

local function campear()
    os.sleep(waitTime)
    write("Plantando:")
    ss(sSeed)
    for i = 0, x - 1, 1 do
        for j = 0, y - 2, 1 do
            semear()
        end
        write(".")
        if i < x - 1 then
            virarCorreto(i)
            semear()
            virarCorreto(i)
        else
            semear()
        end
    end
    print("\n retornando...")
    retornar()
end

local function verificarReq()
    local valido = false
    if turtle.getItemCount(sSeed) > 11 and turtle.getFuelLevel() > 100 then
        valido = true
    else
        valido = false
    end
    return valido
end

local function start()
    local e = 1
    while e == 1 do
        if not turtle.detectDown() then
            campear()
        end
        if useSlot2 then
            if turtle.getItemCount(sSeed) + turtle.getItemCount(sSeed + 1) < 22 then
                getSeeds()
            elseif turtle.getItemCount(sSeed) + turtle.getItemCount(sSeed + 1) < x * y then
                getSeeds(1)
            end
        else
            if turtle.getItemCount(sSeed) < 11 then
                getSeeds()
            elseif turtle.getItemCount(sSeed) < x * y then
                getSeeds(1)
            end
        end
        if turtle.getFuelLevel() < 30 then
            sair("   sem combustivel")
        end
    end
end

local function verificarLimites()
    if x < 2 or y < 2 then
        sair("\n  tamanho minimo: 2x2")
    elseif x > 10 or y > 12 then
        sair("\n  tamanho maximo: 10x12")
    end
    if math.fmod(x, 2) ~= 0 then
        x = x + 1
    end
end

shell.run('clear')
write("Iniciando " .. programName .. " v" .. programVersion .. "...")
verificarLimites()
getSeeds(1)
if verificarReq() then
    write("OK!\n")
    print("Tamanho da plantação: " .. x .. "x" .. y)
    start()
else
    sair("Verifique se você possui ao menos 11 sementes no slot " .. sSeed .. " e se há combustível")
end
