local utf8 = require("utf8")
require "highscore"

function love.load()
    highscore.set("data", 10, "untitled", 0)
    gameCanvas = love.graphics.newCanvas(love.window.getWidth(), love.window.getHeight())
    name = ""
    newPoint()

    blink = 0
    math.randomseed(os.time())
    roomName()
    love.graphics.setBackgroundColor(0, 0, 0)
end

function love.update(dt)
    if room == "name" then
        blink = blink + dt
        if blink > 1 then blink = blink - 1 end
    elseif room == "game" then
        if point.Started then
            point.OldX = point.X
            point.OldY = point.Y
            point.X = point.X + math.cos(math.rad(point.Direction)) * dt * point.Speed
            point.Y = point.Y - math.sin(math.rad(point.Direction)) * dt * point.Speed
            point.Score = point.Score + math.floor(math.abs(point.X - point.OldX) + math.abs(point.Y - point.OldY))
            love.window.setTitle("Score: " .. point.Score)
            local r, g, b = gameCanvas:getPixel(point.X, point.Y)
            if r + g + b > 0 then
                local highscoreName = (string.len(name) > 0) and name or "<no name>"
                highscore.add(highscoreName, point.Score)
                highscore.save()
                room = "highscore"
            end
        end
    elseif room == "highscore" then
    end
end

function love.draw()
    if room == "name" then
        love.graphics.print("Dot Dash\nVersion 0.1\nby Naser Mirzaei\n" ..
                "\nInstruction:\nUse arrows to start playing\nMove dot to fill all the room\nDon't meet red places" ..
                "\nin game press [F2] to change name",
            10, 10)
        love.graphics.print("Enter your name and press [Enter]:", 10, 160)
        blinkName = (blink > .5) and "_" or ""
        love.graphics.print(name .. blinkName, 10, 180)
    elseif room == "game" then
        love.graphics.setCanvas(gameCanvas)
        love.graphics.line(point.OldX, point.OldY, point.X, point.Y)
        love.graphics.setCanvas()
        love.graphics.draw(gameCanvas)
    elseif room == "highscore" then
        for i, score, sname in highscore() do
            love.graphics.printf(i, 24, i * 20, 0, "right")
            if (sname == name and score == point.Score) then sname = sname .. "*" end
            love.graphics.print(sname, 60, i * 20)
            love.graphics.print(score, 160, i * 20)
            love.graphics.line(10, 16 + i * 20, love.window.getWidth() - 10, 16 + i * 20)
        end
        love.graphics.printf("Press [Enter] to continue", 0, 220, love.window.getWidth(), "center")
    end
end

function love.keypressed(key, unicode)
    if key == "escape" then
        love.event.quit()
    end

    if key == "f2" then
        roomName()
    end

    if room == "name" then
        if key == "backspace" then
            -- get the byte offset to the last UTF-8 character in the string.
            local byteoffset = utf8.offset(name, -1)

            if byteoffset then
                -- remove the last UTF-8 character.
                -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
                name = string.sub(name, 1, byteoffset - 1)
            end
        end
        if key == "return" then
            roomGame()
        end
    elseif room == "game" then
        if key == "left" and point.Direction ~= 0 then
            point.Started = true
            point.Direction = 180
        end

        if key == "right" and point.Direction ~= 180 then
            point.Started = true
            point.Direction = 0
        end

        if key == "up" and point.Direction ~= 270 then
            point.Started = true
            point.Direction = 90
        end

        if key == "down" and point.Direction ~= 90 then
            point.Started = true
            point.Direction = 270
        end
    elseif room == "highscore" then
        if key == "return" then
            roomName()
        end
    end
end

function love.textinput(t)
    if room == "name" then
        if string.len(name) < 10 then
            name = name .. string.lower(t)
        end
    end
end

function newPoint()
    point = {
        X = love.window.getWidth() / 2,
        Y = love.window.getHeight() / 2,
        OldX = love.window.getWidth() / 2,
        OldY = love.window.getHeight() / 2,
        Speed = 160,
        Direction = 1,
        Started = false,
        Score = 0
    }
end

function roomGame()
    room = "game"
    gameCanvas:clear()
    love.graphics.setCanvas(gameCanvas)
    love.graphics.rectangle("line", 0, 0, love.window.getWidth(), love.window.getHeight())
    love.graphics.setCanvas()
    newPoint()
end

function roomName()
    room = "name"
    love.graphics.setColor(fromHSL(math.random(256), 255, 192, 255))
end

function fromHSV(h, s, v, a)
    if s <= 0 then return v, v, v, a end
    h, s, v = h / 256 * 6, s / 255, v / 255
    local c = v * s
    local x = (1 - math.abs((h % 2) - 1)) * c
    local m, r, g, b = (v - c), 0, 0, 0
    if h < 1 then r, g, b = c, x, 0
    elseif h < 2 then r, g, b = x, c, 0
    elseif h < 3 then r, g, b = 0, c, x
    elseif h < 4 then r, g, b = 0, x, c
    elseif h < 5 then r, g, b = x, 0, c
    else r, g, b = c, 0, x
    end return (r + m) * 255, (g + m) * 255, (b + m) * 255, a
end

function fromHSL(h, s, l, a)
    if s <= 0 then return l, l, l, a end
    h, s, l = h / 256 * 6, s / 255, l / 255
    local c = (1 - math.abs(2 * l - 1)) * s
    local x = (1 - math.abs(h % 2 - 1)) * c
    local m, r, g, b = (l - .5 * c), 0, 0, 0
    if h < 1 then r, g, b = c, x, 0
    elseif h < 2 then r, g, b = x, c, 0
    elseif h < 3 then r, g, b = 0, c, x
    elseif h < 4 then r, g, b = 0, x, c
    elseif h < 5 then r, g, b = x, 0, c
    else r, g, b = c, 0, x
    end return (r + m) * 255, (g + m) * 255, (b + m) * 255, a
end