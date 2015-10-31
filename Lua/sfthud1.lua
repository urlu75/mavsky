--
--  Copyright (c) Scott Simpson
--
-- 	This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  A copy of the GNU General Public License is available at <http://www.gnu.org/licenses/>.
--    
-------------------------------------------------------------------------------------------------------------------------------------
--  imperialUnits = 0 for metric
--  imperialUnits = 1 for imperial
--
local imperialUnits = 0

-------------------------------------------------------------------------------------------------------------------------------------    

local gpsName = "GPS"  
local rpmName = "RPM"
local vfasName = "VFAS"
local currentName = "Curr"
local altitudeName = "Alt"
local speedName = "GSpd"
local headingName = "Hdg"            
local rssiName = "RSSI"            
local consumptionName = "CTot"         -- Need to add this in telemetry configuration screen

local FlightMode = {}
local AsciiMap={}

local MESSAGEBUFFERSIZE = 5
local messageBuffer = ""
local messageBufferSize = 0
local previousMessageWord = 0
local messageArray = {}
local messageFirst = 0
local messageNext = 0
local messageLatestTimestamp = 0

extensionValue = {}
gpsData = {}

--local function getTelemetryId(name)
--  field = getFieldInfo(name)
--  if field then
--    return field.id
--  else
--    return -1
--  end
--end

function initialize()
    local i  
    for i=1, 17 do
        FlightMode[i] = {}
        FlightMode[i].Name=""
    end

    FlightMode[1].Name="Stabilize"
    FlightMode[2].Name="Acro"
    FlightMode[3].Name="Altitude Hold"
    FlightMode[4].Name="Auto"
    FlightMode[5].Name="Guided"
    FlightMode[6].Name="Loiter"
    FlightMode[7].Name="Return to launch"
    FlightMode[8].Name="Circle"
    FlightMode[9].Name="Invalid Mode"
    FlightMode[10].Name="Land"
    FlightMode[11].Name="Optical Loiter"
    FlightMode[12].Name="Drift"
    FlightMode[13].Name="Invalid Mode"
    FlightMode[14].Name="Sport"
    FlightMode[15].Name="Flip Mode"
    FlightMode[16].Name="Auto Tune"
    FlightMode[17].Name="Position Hold"
    
    AsciiMap[1] ="A"
    AsciiMap[2] ="B"
    AsciiMap[3] ="C"
    AsciiMap[4] ="D"
    AsciiMap[5] ="E"
    AsciiMap[6] ="F"
    AsciiMap[7] ="G"
    AsciiMap[8] ="H"
    AsciiMap[9] ="I"
    AsciiMap[10] ="J"
    AsciiMap[11] ="K"
    AsciiMap[12] ="L"
    AsciiMap[13] ="M"
    AsciiMap[14] ="N"
    AsciiMap[15] ="O"
    AsciiMap[16] ="P"
    AsciiMap[17] ="Q"
    AsciiMap[18] ="R"
    AsciiMap[19] ="S"
    AsciiMap[20] ="T"
    AsciiMap[21] ="U"
    AsciiMap[22] ="V"
    AsciiMap[23] ="W"
    AsciiMap[24] ="X"
    AsciiMap[25] ="Y"
    AsciiMap[26] ="Z"
    AsciiMap[27] ="0"
    AsciiMap[28] ="1"
    AsciiMap[29] ="2"
    AsciiMap[30] ="3"
    AsciiMap[31] ="4"
    AsciiMap[32] ="5"
    AsciiMap[33] ="6"
    AsciiMap[34] ="7"
    AsciiMap[35] ="8"
    AsciiMap[36] ="9"
    AsciiMap[37] =" "
    AsciiMap[38] ="."
    AsciiMap[39] =","
    AsciiMap[40] ="="
    AsciiMap[41] =":"
    AsciiMap[42] ="!"    
    AsciiMap[43] ="-"    
    AsciiMap[44] ="+"    
end

initialize()
      
function char6(c) 
    if c >= 1 and c <= 44 then
        return AsciiMap[c]    
    elseif c == 0 then
        return 0
    else
        return "?"
    end
end

function checkForExtensionMessage()
    local messageWord = getValue(rpmName)

    if messageWord ~= previousMessageWord then
        local extensionCommand = bit32.rshift(messageWord, 12)
        extensionCommand = bit32.band(extensionCommand, 15)
        local extensionData = bit32.band(messageWord, 4095)
        if extensionCommand == 0 then
            local highByte = bit32.rshift(extensionData, 6)     
            local lowByte  = bit32.band(extensionData, 63)                            
            if highByte ~= 0 then
                if messageBuffer ~= "" then                             -- first char is severity number so remove it    
                    messageBuffer = messageBuffer .. char6(highByte)
                    messageBufferSize = messageBufferSize + 1
                end
            end
            if lowByte ~= 0 then
                messageBuffer = messageBuffer .. char6(lowByte)
                messageBufferSize = messageBufferSize + 1
            end
            if highByte == 0 or lowByte == 0 then           
                messageArray[(messageNext % MESSAGEBUFFERSIZE) + 1] = messageBuffer
                messageBuffer = ""
                messageNext = messageNext + 1
                if (messageNext - messageFirst) >= MESSAGEBUFFERSIZE then
                    messageFirst = messageNext - MESSAGEBUFFERSIZE
                end
                messageLatestTimestamp = getTime() 
            end                
        elseif extensionCommand == 1 then
            extensionValue["sequence"] = extensionData     
        elseif extensionCommand == 2 then
            extensionValue["roll_angle"] = extensionData                
        elseif extensionCommand == 3 then
           extensionValue["pitch_angle"] = extensionData        
        elseif extensionCommand == 4 then
           extensionValue["hdop"] = extensionData        
        elseif extensionCommand == 5 then
           extensionValue["fix_type"] = extensionData        
        elseif extensionCommand == 6 then
           extensionValue["sats_visible"] = extensionData        
        elseif extensionCommand == 7 then
           extensionValue["base_mode"] = extensionData
        elseif extensionCommand == 8 then
           extensionValue["custom_mode"] = extensionData 
        elseif extensionCommand == 9 then
           extensionValue["bar_altitude"] = extensionData 
        elseif extensionCommand == 10 then
           extensionValue["ranger_dist"] = extensionData 
        elseif extensionCommand == 11 then
           extensionValue["batt_remain"] = extensionData 
        elseif extensionCommand == 12 then
           extensionValue["cur_consumed"] = extensionData 
        end           
        previousMessageWord = messageWord     
    end
end

function getArmedValue()
    local baseMode = extensionValue["base_mode"]
    local armedBit                                             -- nil if unknown, 1 if armed, 0 if disarmed
    if baseMode ~= nil then
        armedBit = bit32.rshift(baseMode, 7) 
        armedBit = bit32.band(armedBit, 1)
        return armedBit
    else
        return nil
    end
end

function getDistanceFromCoordinates(lat1, lon1, lat2, lon2)
    if lat1 == nil or lon1 == nil or lat2 == nil or lon2 == nil then
        return nil
    end
    local dlat = math.rad(lat2-lat1)
    local dlon = math.rad(lon2-lon1)
    local sinDlat = math.sin(dlat/2)
    local sinDlon = math.sin(dlon/2)
    local a = sinDlat * sinDlat + math.cos(math.rad(lat1)) * math.cos(math.rad(lat2)) * sinDlon * sinDlon
    local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    local d = 6378000 * c
    return d
end

function loadGpsData()
    local gpsLatLon = getValue(gpsName)
    if (type(gpsLatLon) == "table") then
        gpsData["lat"] = gpsLatLon["lat"]
        gpsData["lon"] = gpsLatLon["lon"]
        if gpsData["armed_lat"] == nil then
            if getArmedValue() == 1 then
                gpsData["armed_lat"] = gpsData["lat"]
                gpsData["armed_lon"] = gpsData["lon"]
            end 
        else
            if getArmedValue() ~= 1 then
                gpsData["armed_lat"] = nil
                gpsData["armed_lon"] = nil 
            end
        end
        gpsData["horiz-distance"] = getDistanceFromCoordinates(gpsData["lat"], gpsData["lon"], gpsData["armed_lat"], gpsData["armed_lon"])     
    end
end

function getLatestMessage()
    if messageFirst == messageNext then
        return ""
    end
    return messageArray[((messageNext - 1) % MESSAGEBUFFERSIZE) + 1]
end
  
local function drawBatteryVoltage(x,y)
	local batteryVoltage = getValue(vfasName)
    lcd.drawNumber(x,y,batteryVoltage,MIDSIZE+PREC1)
    lcd.drawText(lcd.getLastPos(),y+5,"V",SMLSIZE)
end

local function drawCurrent(x,y)
	local current = getValue(currentName)
    lcd.drawNumber(x,y,current,MIDSIZE+PREC1)
    lcd.drawText(lcd.getLastPos(),y+5,"A",SMLSIZE)
end

local function drawTotalCurrent(x,y)
	local totalCurrent = getValue(consumptionName)
    lcd.drawNumber(x, y, totalCurrent, MIDSIZE)
    lcd.drawText(lcd.getLastPos(), y+5, "mAh", SMLSIZE)
end

local function drawSpeed(x,y)
    local speed = getValue(speedName)               -- originally in m/s * 10
    speed = speed * 3.6                             -- now in km/hr
    if imperialUnits == 1 then
        speed = speed * 0.621                       -- to mi/hr
    end
    lcd.drawText(x, y + 5, "Spd", SMLSIZE)
    lcd.drawNumber(x + 37, y, speed, MIDSIZE)
    local t = lcd.getLastPos() + 1

    if imperialUnits == 1 then
        lcd.drawText(t, y, "mi", SMLSIZE)
    else
        lcd.drawText(t, y, "km", SMLSIZE)
    end    
    lcd.drawText(t, y+5, "hr", SMLSIZE)
end

local function drawAltitude(x, y)
	local altitude = getValue(altitudeName)
    if imperialUnits == 1 then
        altitude = altitude * 3.28
    end
    lcd.drawText(x, y + 5, "Alt", SMLSIZE)
    lcd.drawNumber(x + 36, y, altitude, MIDSIZE)
    local t = lcd.getLastPos() + 1
    if imperialUnits == 1 then
        lcd.drawText(t, y + 5, "ft", SMLSIZE)
    else
        lcd.drawText(t, y + 5, "m", SMLSIZE)
    end
end

local function drawDistance(x, y)
	local distance = gpsData["horiz-distance"]
    if distance == nil then
        distance = 0
    end
    if imperialUnits == 1 then
        distance = distance * 3.28
    end    
    lcd.drawText(x, y + 5, "Dst", SMLSIZE)
    lcd.drawNumber(x + 36, y, distance, MIDSIZE)
    local t = lcd.getLastPos() + 1
    if imperialUnits == 1 then
        lcd.drawText(t, y + 5, "ft", SMLSIZE)
    else
        lcd.drawText(t, y + 5, "m", SMLSIZE)
    end    
end

local function drawHdop(x,y)
	local hdop = extensionValue["hdop"]
    if hdop == nil then
        return
    end
    hdop = hdop / 10
    if hdop >= 99 then
        lcd.drawText(x-22, y+3, ">", SMLSIZE)  
        lcd.drawNumber (x, y, 99, MIDSIZE)
    else
        lcd.drawNumber (x, y, hdop, PREC1 + MIDSIZE)
    end

    local t = lcd.getLastPos() + 1
    lcd.drawText(t, y, "hd", SMLSIZE)  
    lcd.drawText(t, y + 6, "op", SMLSIZE)  
end	

local function drawSats(x, y)
	local fixType = extensionValue["fix_type"]
    if fixType == nil then
        return
    end
	local satellitesVisible = extensionValue["sats_visible"]
    if satellitesVisible == nil then
        return
    end

    if fixType == 3 then
        lcd.drawNumber(x + 6, y, satellitesVisible, MIDSIZE)
        lcd.drawText(x + 7, y + 5, "sats", SMLSIZE)                  
    elseif fixType == 2 then
        lcd.drawText(x + 8, y, "2D", MIDSIZE)
    elseif fixType == 1 then
        lcd.drawText(x, y + 5, "Search", SMLSIZE)
    elseif fixType == 0 then
        lcd.drawText(x, y + 5, "No Fix", SMLSIZE)
    end
end

local function getRelativeGroundDirection()
    local vehicleHeading = getValue(headingName)
    if vehicleHeading ~= nil then 
        local headingToVehicle = getDirectionToVehicle()
        if headingToVehicle >= 0 then
            local relativeHeading = vehicleHeading - headingToVehicle
            if(relativeHeading < 0) then
                relativeHeading = relativeHeading + 360
            end   
			return relativeHeading
		end
	end
	return -1
end

function getDirectionFromTo(fromLat, fromLon, toLat, toLon)
    if fromLat == nil or fromLon == nil or toLat == nil or toLon == nil then
        return -1
    end
    if(fromLat == toLat and fromLon == toLon) then
        return -1
    end
    local z1 = math.sin(math.rad(toLon) - math.rad(fromLon)) * math.cos(math.rad(toLat))
    local z2 = math.cos(math.rad(fromLat)) * math.sin(math.rad(toLat)) - math.sin(math.rad(fromLat)) * math.cos(math.rad(toLat)) * math.cos(math.rad(toLon) - math.rad(fromLon))
    local directionTo = math.deg(math.atan2(z1, z2))
    if directionTo < 0 then
        directionTo=directionTo+360
    end
    return directionTo
end

function getDirectionToVehicle()
    local directionToVehicle = -1
   
    if gpsData["lat"] ~= nil and gpsData["lon"] ~= nil and gpsData["armed_lat"] ~= nil and gpsData["armed_lon"] ~= 0 then 
        directionToVehicle = getDirectionFromTo(gpsData["armed_lat"], gpsData["armed_lon"], gpsData["lat"], gpsData["lon"])
    end
	return directionToVehicle
end  

function getXYAtAngle(x, y, angle, length)
	if angle < 0 then
		angle = angle + 360
	elseif angle >= 360 then
		angle = angle - 360
	end
    local x2 = x + math.sin(math.rad(angle)) * length
    local y2 = y - math.cos(math.rad(angle)) * length
	return x2, y2
end

local function drawHeadingHud(x, y)
    local arrowSide = 5
    local arrowTail = 5
    local arrowLength = 16
    local arrowSideAngle = 120
    local headingHudOuterRadius = 15

    local vehicleHeading = getValue(headingName)
    local headingToVehicle = getDirectionToVehicle()
    if headingToVehicle >= 0 then
        local relativeHeading = vehicleHeading - headingToVehicle
        if(relativeHeading < 0) then
            relativeHeading = relativeHeading + 360	
		end			
		local xTail, yTail = getXYAtAngle(x, y, relativeHeading - 180, arrowTail)	
		local xLeft, yLeft = getXYAtAngle(xTail, yTail, relativeHeading-arrowSideAngle, arrowSide)
		local xRight, yRight = getXYAtAngle(xTail, yTail, relativeHeading+arrowSideAngle, arrowSide)
		local xNose, yNose = getXYAtAngle(xTail, yTail, relativeHeading, arrowLength)
		lcd.drawLine(xTail, yTail, xLeft, yLeft, SOLID, FORCE)
		lcd.drawLine(xLeft, yLeft, xNose, yNose, SOLID, FORCE)
		lcd.drawLine(xTail, yTail, xRight, yRight, SOLID, FORCE)
		lcd.drawLine(xRight, yRight, xNose, yNose, SOLID, FORCE)
	end
end

local function drawTopPanel()
    lcd.drawFilledRectangle(0, 0, 212, 9, 0)
    
    local flightModeNumber = extensionValue["custom_mode"]
    if flightModeNumber then
        flightModeNumber = flightModeNumber + 1
        if flightModeNumber < 1 or flightModeNumber > 17 then
            flightModeNumber = 13
        end
        lcd.drawText(1, 1, FlightMode[flightModeNumber].Name, INVERS)
    end

    lcd.drawTimer(lcd.getLastPos() + 5, 1, model.getTimer(0).value, INVERS)

    lcd.drawText(lcd.getLastPos() + 5, 1, "TX:", INVERS)
    lcd.drawNumber(lcd.getLastPos() + 16, 1, getValue("tx-voltage"), PREC1 + INVERS)

    lcd.drawText(lcd.getLastPos(), 1, "v", INVERS)

    lcd.drawText(lcd.getLastPos() + 5, 1, "rssi:", INVERS)
    local rssiValue = getValue(rssiName)
    lcd.drawNumber(lcd.getLastPos() + 10, 1, rssiValue, 0+INVERS)
end

local function drawBottomPanel()
	local baseMode = extensionValue["base_mode"]
    local armedBit                                             -- nil if unknown, 1 if armed, 0 if disarmed
    if baseMode ~= nil then
        armedBit = bit32.rshift(baseMode, 7) 
        armedBit = bit32.band(armedBit, 1)
    end
    
    local textAttributes = 0
    if armedBit == 1 then
        textAttributes = INVERS
        lcd.drawFilledRectangle(0, 54, 211, 63, BLINK)
    else
        lcd.drawLine(0, 53, 211, 53, SOLID, FORCE)
    end

    if getTime() < (messageLatestTimestamp + 1000) then
        local footerMessage = getLatestMessage()
        lcd.drawText(1, 55, footerMessage, textAttributes)
    else    
        if armedBit == 1 then
            lcd.drawText(1, 55, "Armed", textAttributes)
        elseif armedBit == 0 then
            lcd.drawText(1, 55, "Disarmed", textAttributes)
        end            
    end
end

local function background() 
end

local function run(event)
    lcd.clear()
    checkForExtensionMessage()
    loadGpsData()

    drawTopPanel()
    drawBottomPanel()

    drawBatteryVoltage(32, 12)
    drawCurrent(32, 26)
    drawTotalCurrent(32, 40)

    drawSats(72, 40)	
    drawHdop(130, 40)
    
    drawHeadingHud(107, 26)
    
    drawSpeed(159, 12)
    drawAltitude(160, 26)
    drawDistance(160, 40)	
end

return {run=run}