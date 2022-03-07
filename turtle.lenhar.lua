-- {program="aTreeFarm",version="1.05br",date="2020-08-27"}
---------------------------------------
-- aTreeFarm           by Kaikaku
-- 2020-08-27, v1.05br Translated to Brazilian Portuguese, bugfix (turtle won't cut stubs when 2 trees side-by-side) by goga
-- 2018-01-07, v1.04   bugfix (turtle start position)
-- 2018-01-05, v1.03   bugfix (turtle digged drop chest)
-- 2017-12-02, v1.02   start with craft fuel and empty to allow tHome
-- 2015-01-31, v1.01   fixed initial refuelling
-- 2015-01-31, v1.00   finalized UI + counter
-- 2015-01-30, v0.80   auto set-up option
-- 2015-01-26, v0.70   preparing for video
-- 2014-01-12, v0.61   replant limited tries
-- 2014-01-04, v0.60   redstone stop
-- 2013-12-15, v0.51   initial
---------------------------------------
---------------------------------------
---- DESCRIPTION ---------------------- 
---------------------------------------
-- Turtle-automated tree farm.
-- Details see information during program
--   execution or YouTube video.
---------------------------------------
---- NOTE -----------------------------
---------------------------------------
-- Hi I'm goga "founder" of NonaCept
-- I'm a programmer from Brazil that loves
-- Minecraft and Computers.
-- The Kaikaku's code was very good and I
-- like to bring this to more people, so
-- I decide to translate this to pt_BR
-- and do a little improvement in the movements
-- of the turtle when diging
---------------------------------------
---- PARAMETERS ----------------------- 
---------------------------------------
local cVersion = "1.05br"
local cPrgName = "aTreeFarm"
local cMinFuel = 960 * 2 -- 2 stacks of planks

local minRandomCheckSapling = 0.1 -- below this will check replant
local actRandomCheckSapling = minRandomCheckSapling * 2
local cIncreaseCheckSapling_Sapling = 0.02
local cIncreaseCheckSapling_Stub = 0.04
local cMaxCheckSapling = 0.6
local strC = "tReeTreESdig!diG;-)FaRmKaIKAKUudIgYdIgyTreEAndsOrRygUYsd"

local cSlotChest = 16 -- chest for crafty turtle
local cCraftRefuelMaxItems = 32 -- use how many logs to refuel at max
local cSlotRefuel = 15 -- where to put fuel
local cExtraDigUp = 1 -- go how many extra levels to reach jungle branches
local cLoopEnd = 56 -- one loop
local cWaitingTime = 20 -- if redstone signal in back is on

---------------------------------------
---- VARIABLES ------------------------ 
---------------------------------------
local strC_now = ""
local strC_next = ""

local tmpResult = ""
local blnAskForParameters = true
local blnShowUsage = false
local blnAutoSetup = false
local strSimpleCheck = "Aperte ENTER para iniciar:"
local intCounter = 0
local maxCounter = 0

---------------------------------------
---- tArgs ----------------------------
---------------------------------------
local tArgs = {...}
if #tArgs >= 1 then -- no error check
    blnAskForParameters = false
    if tArgs[1] == "help" then
        blnShowUsage = true
    end
    if tArgs[1] == "setup" then
        blnAutoSetup = true
    end
    if tArgs[1] == "set-up" then
        blnAutoSetup = true
    end
    if tonumber(tArgs[1]) ~= nil then
        maxCounter = tonumber(tArgs[1])
    end
end

if blnShowUsage then
    print("+-------------------------------------+")
    print("  " .. cPrgName .. ", by Kaikaku")
    print("  Trad. e rework: goga")
    print("+-------------------------------------+")
    print("Uso: aTreeFarm setup/set-up")
    print("   ou: aTreeFarm [maxCounter]")
    print("setup ou set-up:")
    print("   Vai iniciar a configuração")
    print("maxCounter:")
    print("   0=vai farmar infinitamente")
    print("   x=vai farmar x vezes")
    print("Mais detalhes no YouTube (Inglês)")
    return
end

---------------------------------------
-- BASIC FUNCTIONS FOR TURTLE CONTROL -
---------------------------------------
local function gf(n)
    if n == nil then
        n = 1
    end
    for i = 1, n, 1 do
        while not turtle.forward() do
        end
    end
end
local function gb(n)
    if n == nil then
        n = 1
    end
    for i = 1, n, 1 do
        while not turtle.back() do
        end
    end
end
local function gu(n)
    if n == nil then
        n = 1
    end
    for i = 1, n, 1 do
        while not turtle.up() do
        end
    end
end
local function gd(n)
    if n == nil then
        n = 1
    end
    for i = 1, n, 1 do
        while not turtle.down() do
        end
    end
end
local function gl(n)
    if n == nil then
        n = 1
    end
    for i = 1, n, 1 do
        while not turtle.turnLeft() do
        end
    end
end
local function gr(n)
    if n == nil then
        n = 1
    end
    for i = 1, n, 1 do
        while not turtle.turnRight() do
        end
    end
end
local function pf(n)
    -- moves backwards if n>1
    if n == nil then
        n = 1
    end
    for i = 1, n, 1 do
        if i ~= 1 then
            gb()
        end
        turtle.place()
    end
end
local function pu()
    turtle.placeUp()
end
local function pd()
    turtle.placeDown()
end
local function df()
    return turtle.dig()
end
local function du()
    turtle.digUp()
end
local function dd()
    turtle.digDown()
end
local function sf()
    turtle.suck()
end
local function su()
    turtle.suckUp()
end
local function sd(n)
    if n == nil then
        while turtle.suckDown() do
        end
    else
        for i = 1, n do
            turtle.suckDown()
        end
    end
end
local function Df()
    turtle.drop()
end
local function Du(n)
    if n == nil then
        n = 64
    end
    turtle.dropUp(n)
end
local function Dd(n)
    if n == nil then
        n = 64
    end
    turtle.dropDown(n)
end
local function ss(s)
    turtle.select(s)
end
local function df2()
    ss(2)
    local retorno = false
    if not turtle.compare() then
        ss(1)
        retorno = turtle.dig()
    end
    ss(1)
    return retorno
end

local function askForInputText(textt)
    local at = ""
    -- check prompting texts
    if textt == nil then
        textt = "Digite algo:"
    end

    -- ask for input
    write(textt)
    at = read()
    return at
end

local function checkFuel()
    local tmp = turtle.getFuelLevel()
    return tmp
end

function checkRefuel(minFuel, slotFuel)
    if slotFuel == nil then
        slotFuel = 16
    end
    if minFuel == nil then
        minFuel = 1000
    end
    local tmpFuel = 0
    tmpFuel2 = 0
    local tmpItems = 65 -- turtle.getItemCount(slotFuel) 
    local cSleep = 5

    -- step 1 check if more fuel is required
    tmpFuel = turtle.getFuelLevel()
    tmpFuel2 = tmpFuel - 1 -- triggers print at least once
    if tmpFuel < minFuel then
        ss(slotFuel)
        -- step 2 refuel loop
        while tmpFuel < minFuel do
            -- step 2.1 need to update fuel level?
            if tmpFuel2 ~= tmpFuel then -- tmpItems~=turtle.getItemCount(slotFuel) then
                -- fuel still too low and there have been items consumed
                print("Precisa de mais combustivel (" .. tmpFuel .. "/" .. minFuel .. ") no slot " .. slotFuel)
            end
            -- step 2.2 try to refuel
            if tmpItems > 0 then
                -- try to refuel this items
                turtle.refuel()
            else
                os.sleep(cSleep)
            end
            -- step 2.3 update variables
            tmpItems = turtle.getItemCount(slotFuel)
            tmpFuel2 = tmpFuel
            tmpFuel = turtle.getFuelLevel()
        end
    end
    -- step 3 either no need to refuel 
    --        or successfully refuelled
    print("Nível de combustivel ok  (" .. tmpFuel .. "/" .. minFuel .. ")")
end

---------------------------------------
---- functions ------------------------
---------------------------------------

local function cutTree()
    local tmpExtraDigUp = cExtraDigUp

    ---- assumptions
    -- turtle faces trunk one block below bottom
    ---- variables
    local intUpCount = 0
    local intFace = 0 -- -1=left, 1=right
    local blnDigSomething = false

    term.write("  cortando árvore: ")

    -- get into tree column
    df()
    while not turtle.forward() do
        df()
    end
    gr()
    df2()
    gl()
    df2()
    gl()
    df2()
    local intFace = -1

    -- cut and go up
    repeat
        blnDigSomething = false
        du()
        while not turtle.up() do
            du()
        end
        if intUpCount > 0 then
            blnDigSomething = df() or blnDigSomething
        else
            blnDigSomething = df2() or blnDigSomething
        end
        if intFace == -1 then
            gr()
            if intUpCount > 0 then
                blnDigSomething = df() or blnDigSomething
            else
                blnDigSomething = df2() or blnDigSomething
            end
            gr()
        elseif intFace == 1 then
            gl()
            if intUpCount > 0 then
                blnDigSomething = df() or blnDigSomething
            else
                blnDigSomething = df2() or blnDigSomething
            end
            gl()
        end
        intFace = intFace * -1
        if intUpCount > 0 then
            blnDigSomething = df() or blnDigSomething
        else
            blnDigSomething = df2() or blnDigSomething
        end
        intUpCount = intUpCount + 1
        term.write(".")

        -- check for 2 conditions
        -- either
        -- 1) nothing above the turtle
        -- or
        -- 2) nothing dig on the other columns blnDigSomething
        if not (turtle.detectUp() or blnDigSomething) then
            tmpExtraDigUp = tmpExtraDigUp - 1
        else
            tmpExtraDigUp = cExtraDigUp -- restore it	
           
        end
    until tmpExtraDigUp < 0 -- not (turtle.detectUp() or blnDigSomething) ----- NOT kai_2 

    -- go off tree column  
    if intFace == -1 then
        gl()
    elseif intFace == 1 then
        gr()
    end
    df()
    while not turtle.forward() do
        df()
    end
    gl()
    intFace = 0

    intFace = 1 -- 1=forward,-1=backwards
    -- go back down  
    -- hint: only digging front and back in order
    --       to not cut into larger neighbouring,
    --       as this may leave upper tree parts left
    for i = 1, intUpCount + 1 do
        dd()
        df()
        gl(2)
        df()
        intFace = intFace * -1
        while not turtle.down() do
            dd()
        end
    end
    if intFace == 1 then
        gl()
    elseif intFace == -1 then
        gr()
    end
    sf()
    df()
    term.write(".")
    print(" feito!")

    -- plant new
    plantTree()
    while not turtle.up() do
        du()
    end
    sd()
end

---------------------------------------
function plantTree()
    local tmpCount = 0
    ---- assumptions
    -- turtle faces place to plant

    -- check for enough saplings
    sf()
    if turtle.getItemCount(1) > 1 then
        -- plant
        print("  plantando")
        while not turtle.place() do
            print("  dificil plantar aqui...")
            tmpCount = tmpCount + 1
            if tmpCount > 3 then
                break
            end
            os.sleep(1)
        end -- NOT kai_2
    else
        -- error
        print("  Sem mudas (saplings)...") -- prog name
        os.sleep(5)
        actRandomCheckSapling = cMaxCheckSapling
        return
    end
end

---------------------------------------
local function replantStub()
    ss(2) -- compare with wood in slot 2
    if turtle.compare() then
        -- assumption: there is only a stub left, so replant
        -- if there is a tree on top of it, it will be harvested next round
        print("  Replantando um toco")
        df()
        ss(1)
        if pf() then
            actRandomCheckSapling = actRandomCheckSapling + cIncreaseCheckSapling_Stub
        else
            print("    falha!")
        end
    else
        ss(1)
    end
end
local function eS(sI, sA, eA)
    local sO = ""
    local sR = ""
    if sA == nil then
        sA = 1
    end
    if eA == nil then
        eA = string.len(sI)
    end
    for i = sA, eA, 1 do
        sO = string.sub(sI, i, i)
        if sR ~= "" then
            break
        end
        if sO == "a" then
            gl()
        elseif sO == "d" then
            gr()
        else
            while not turtle.forward() do
                df()
            end
        end
    end
    return sR
end

---------------------------------------
local function randomReplant()
    local intSuccess = 0
    if turtle.getItemCount(1) > 10 then
        -- try to plant
        while not turtle.down() do
            dd()
        end
        sf()
        gl()
        sf()
        if turtle.place() then
            actRandomCheckSapling = actRandomCheckSapling + cIncreaseCheckSapling_Sapling
        else
            if turtle.detect() then
                replantStub()
            end
        end
        gl()
        sf()
        gl()
        sf()
        if turtle.place() then
            actRandomCheckSapling = actRandomCheckSapling + cIncreaseCheckSapling_Sapling
        else
            if turtle.detect() then
                replantStub()
            end
        end
        gl()
        sf()
        while not turtle.up() do
            du()
        end
        -- ensure min probability and max 100%
        actRandomCheckSapling = math.max(actRandomCheckSapling - 0.01, minRandomCheckSapling)
        actRandomCheckSapling = math.min(actRandomCheckSapling, cMaxCheckSapling)
        print((actRandomCheckSapling * 100) .. "% probabilidade de checar")
    else
        -- extra suck
        while not turtle.down() do
            dd()
        end
        sf()
        gr()
        sf()
        gr()
        sf()
        gr()
        sf()
        gr()
        sf()
        while not turtle.up() do
            du()
        end
        sd()
    end
end

---------------------------------------
local function craftFuel()
    local tmpFuelItems = turtle.getItemCount(2)

    -- step 1 need fuel?
    if (turtle.getFuelLevel() < cMinFuel) and (turtle.getItemCount(cSlotChest) == 1) then
        -- no refuelling if not exactly 1 item in slot cSlotChest (=chest)
        print("Abastecimento automático    (" .. turtle.getFuelLevel() .. "/" .. cMinFuel .. ") ...")

        -- step 2 enough mats to refuel?
        --        assumption: slot 2 has wood 
        if tmpFuelItems > 1 then
            -- step 2 store away stuff!
            ss(cSlotChest)
            while not turtle.placeUp() do
                du()
            end

            for i = 1, 15, 1 do
                ss(i)
                if i ~= 2 then
                    Du()
                else
                    -- cCraftRefuelMaxItems
                    Du(math.max(1, turtle.getItemCount(2) - cCraftRefuelMaxItems)) -- to keep the wood
                end
            end

            -- step 3 craft planks!
            turtle.craft()

            -- step 4 refuel!
            for i = 1, 16, 1 do
                ss(i)
                turtle.refuel()
            end
            print("Novo nível de combustivel (" .. turtle.getFuelLevel() .. "/" .. cMinFuel .. ")")

            -- step 5 get back stuff!
            ss(1) -- su(64) 
            while turtle.suckUp() do
            end
            ss(cSlotChest)
            du()
            ss(1)
        else
            print("Ops, sem madeira suficiente para abastecimento automático!")
        end
    end
end

---------------------------------------
local function emptyTurtle()
    print("  Largando o que eu colhi!")
    while not turtle.down() do
        dd()
    end
    ss(2)

    if turtle.compareTo(1) then
        print("Erro: Ops, no slot 2 tem o mesmo que no slot 1???")
        -- Dd()
    else
        -- if slot 2 has other item (wood) than slot 1
        --   keep one of them for comparison
        if turtle.getItemCount(2) > 1 then
            Dd(math.max(turtle.getItemCount(2) - 1, 0))
        end
    end
    for i = 3, 15, 1 do
        -- assumption slot 16 contains a chest
        ss(i)
        Dd()
    end
    os.sleep(0)
    ss(1)
end

-- goga' code
local function thereIsTree()
    ss(2)
    if turtle.compare() then
        ss(1)
        cutTree()
    end
    ss(1)
end

---------------------------------------
---- main -----------------------------
---------------------------------------
-- step 0 info and initial check
term.clear()
term.setCursorPos(1, 1)
repeat
    print("+-------------------------------------+")
    print("| aTreeFarm " .. cVersion .. ", by Kaikaku (1/2)    |")
    print("|     Trad. e rework: goga         |")
    print("+-------------------------------------+")
    print("| Configuração: Coloque crafty felling|")
    print("|   turtle (e.g. canto inferior       |")
    print("|   esquerdo do chunk). Rode com o    |")
    print("|   parametro 'setup' (uma vez).      |")
    print("| Materiais para configuração:        |")
    print("|   slot 3: (1) chest (baú)           |")
    print("|   slot 4: (47) cobblestone          |")
    print("|   slot 5: (8) tochas                |")
    print("+-------------------------------------+")

    if blnAutoSetup then
        if turtle.getItemCount(3) ~= 1 or turtle.getItemCount(4) < 47 or turtle.getItemCount(5) < 8 then
            -- inventory not ready for set-up
            strSimpleCheck = "Preencha os slots 3-5 e aperte ENTER:"
        else
            strSimpleCheck = "Aperte ENTER para iniciar:"
        end
    else
        strSimpleCheck = "Aperte ENTER para iniciar:"
    end
    if not blnAskForParameters and strSimpleCheck == "Aperte ENTER para iniciar:" then
        break
    end
until askForInputText(strSimpleCheck) == "" and strSimpleCheck == "Aperte ENTER para iniciar:"

term.clear()
term.setCursorPos(1, 1)
repeat
    print("+-------------------------------------+")
    print("| aTreeFarm " .. cVersion .. ", by Kaikaku (2/2)    |")
    print("|     Trad. e rework: goga         |")
    print("+-------------------------------------+")
    print("| Rodando a farm:                     |")
    print("|   A turtle deve estar sobre a baú   |")
    print("|   (como ao fim da config.). Turtle  |")
    print("|   precisa de combustivel inicial.   |")
    print("| Inventário da Turtle:               |")
    print("|   slot  1: (20+) saplings (mudas)   |")
    print("|   slot  2: (1+) madeira das saplings|")
    print("|   slot 16: (1) chest (baú)          |")
    print("+-------------------------------------+")

    if turtle.getItemCount(1) < 11 or turtle.getItemCount(2) == 0 or turtle.getItemCount(16) ~= 1 then
        -- inventory not ready
        strSimpleCheck = "Forneça os materiais e aperte ENTER:"
    else
        strSimpleCheck = "Aperte ENTER para iniciar:"
    end
    -- strSimpleCheck="Press enter to start:"
    if not blnAskForParameters and strSimpleCheck == "Aperte ENTER para iniciar:" then
        break
    end
    if blnAutoSetup then
        strSimpleCheck = "Aperte ENTER para iniciar:"
    end
until askForInputText(strSimpleCheck) == "" and strSimpleCheck == "Aperte ENTER para iniciar:"

---------------------------------------
---- set-up farm ----------------------
---------------------------------------
-- set-up = not running the farm
if blnAutoSetup then
    write("Configurando local...")
    checkRefuel(cMinFuel, cSlotRefuel)
    -- chest
    gf(3)
    gr()
    gf(3)
    gl()
    ss(3)
    dd()
    pd()
    -- path
    ss(4)
    for i = 1, 9, 1 do
        gf()
        dd()
        pd()
    end
    gr()
    for i = 1, 3, 1 do
        gf()
        dd()
        pd()
    end
    gr()
    for i = 1, 6, 1 do
        gf()
        dd()
        pd()
    end
    gl()
    for i = 1, 3, 1 do
        gf()
        dd()
        pd()
    end
    gl()
    for i = 1, 6, 1 do
        gf()
        dd()
        pd()
    end
    gr()
    for i = 1, 3, 1 do
        gf()
        dd()
        pd()
    end
    gr()
    for i = 1, 9, 1 do
        gf()
        dd()
        pd()
    end
    gr()
    for i = 1, 8, 1 do
        gf()
        dd()
        pd()
    end
    -- torches
    ss(5)
    gf(2)
    gl()
    pf()
    gu()
    gb(10)
    pd()
    gl()
    gf(5)
    pd()
    gf()
    pd()
    gf(5)
    pd()
    gr()
    gf(11)
    pd()
    gb(3)
    gr()
    gf(3)
    pd()
    gf(5)
    pd()
    gf(2)
    gr()
    gb(2)
    gd()
    print(" Feito!")
    print("Agora você pode rodar a farm com : ", cPrgName)
    return
end

---------------------------------------
---- tree farm ------------------------
---------------------------------------
strC_next = string.sub(strC, 1, 1)

-- initial up
while not turtle.up() do
    du()
end

while true do

    -- step 6 need to craft some fuel?
    craftFuel()

    -- step 7 empty into chest
    emptyTurtle()

    -- step 0 check exit 
    if maxCounter > 0 then
        if intCounter == maxCounter then
            print("Todos as ", maxCounter, "  foram farmadas ")
            print("Esperando novos comandos")
            -- while not turtle.up() do du() end
            return
        end
    end

    -- step 1 check fuel
    checkRefuel(cMinFuel, cSlotRefuel)

    -- step 2 wait if redstone signal
    while rs.getInput("back") do
        print("Esperando ", cWaitingTime, "s devido ao sinal de redstone.")
        os.sleep(cWaitingTime)
    end

    -- step 3 new round 
    while not turtle.up() do
        du()
    end
    ss(1)
    intCounter = intCounter + 1
    print("Comçando a vez ", intCounter, " com " .. turtle.getItemCount(1) .. " mudas (saplings).")

    for i = 1, cLoopEnd, 1 do

        -- update commands
        strC_now = strC_next
        if i < cLoopEnd then
            strC_next = string.sub(strC, i + 1, i + 1)
        else
            strC_next = string.sub(strC, 1, 1)
        end

        -- step 4 one step on the road
        tmpResult = eS(strC, i, i)
        if tmpResult ~= "" then
            print("comando especial encontrado: " .. tmpResult)
        end

        -- step 5 check for blocks
        -- step 5.1 check left hand side
        if strC_now ~= "a" and strC_next ~= "a" then
            -- now  a=>just turned left
            -- next a=>will turned left
            gl()
            thereIsTree()
            if turtle.detect() then
                df()
            end
            gr()
        end
        -- step 5.2 check right hand side
        if strC_now ~= "d" and strC_next ~= "d" then
            -- now  d=>just turned right
            -- next d=>will turn right
            gr()
            thereIsTree()
            if turtle.detect() then
                df()
            end
            gl()
        end
        sd()

        if math.random() <= actRandomCheckSapling then
            if strC_now ~= "d" and strC_now ~= "a" then
                randomReplant()
            end
        end
    end
end
