--[[
   
   @author: Mohamed Aziz Knani (medazizknani@gmail.com)
   @since: 16/07/2016

   NOTE: This my first project using lua and love2d, so I have
   no prior knowledge of lua and love2d.
   I also build a simple AI that will just follow the ball when
   the velocity is positive (the ball is going toward the oponnent)
--]]

choice = {-1, 1}

-- this is our paddle

paddle = {}

function paddle:init(speed, step, position)
   -- this is our class constructer
   -- @speed is the constant speed of the paddle (pixel per second)
   -- @step is the paddle move step size (in pixels of course)
   -- @position is the rectangle upper-left corner position
   -- TODO: Set max speed for the AI player.

   newObj = {speed = speed, position = position, moving = false}
   self.defaultSpeed = speed
   self.score = 0
   self.__index = self
   return setmetatable(newObj, self)
end

function paddle:moveUp(dt)
   -- This method  moves the paddle up
   -- basically if the paddle is moving and still in the box
   if self.moving and self.position.y-self.speed*dt>=0 then
      self.position.y = self.position.y - self.speed * dt
   end   
end

function paddle:moveDown(dt)
   -- This method  moves the paddle down
   if self.moving and self.position.y+self.speed*dt+100<=love.graphics.getHeight() then
      self.position.y = self.position.y + self.speed * dt
   end
end

function paddle:draw()
   -- This method draws our paddle to the screen
   love.graphics.rectangle("fill", self.position.x, self.position.y, 20, 100)
end

-- This is our ball
ball = {}
function ball:init(speed, side, position, nshadowed)
   -- @speed is the "ball" constant speed
   -- @side is the "ball"side (it's square like the classic pong not a circle)
   -- @position is the "ball" position
   -- @nshadowed is the number of shadowed balls - 1
   
   myObj = {side=side, speed=speed, position=position, shadowed=nshadowed+1, ballsPos={}}
   self.defaultSpeed = speed
   self.color = {222, 219, 220}
   self.vx = 1
   self.vy = 1
   self.__index = self
   return setmetatable(myObj, self)
end

function ball:draw()
   -- Draws our ball to the screen
   for key, value in pairs(self.ballsPos) do
      love.graphics.setColor(self.color[1], self.color[2], self.color[3], 255 - key * 30)
      love.graphics.rectangle("fill", value.x, value.y, key*4, key*4)
   end
   love.graphics.setColor(self.color[1], self.color[2], self.color[3], 255)
   love.graphics.rectangle("fill", self.position.x, self.position.y, self.side, self.side)
end


function love.load()
   -- This is where is laod all my assets

   font = love.graphics.newFont("Semi-Casual.ttf", 20)
   love.graphics.setFont(font)
   love.graphics.setBackgroundColor(20, 40, 70)
   paddleOne = paddle:init(400, 10, {x=0, y=0})
   paddleOponnent = paddle:init(400, 10, {x=love.graphics.getWidth()-10*2, y=0})
   ourBall = ball:init(400, 20, {x=love.graphics.getWidth()/2, y=love.graphics.getHeight()/2}, 3)

   powerUps = {
      -- time is in seconds
      -- screenName is string to be displayed
      ["turboball"]={
	 ["screenName"]="Turbo-Ball",
	 ["used"]=false,
	 ["time"]=10,
	 ["done"]=false,
	 ["shortcut"]="t",
	 ["positionx"]=150
      },

      ["block"]={
	 ["screenName"]="Block-oponnent",
	 ["used"]=false,
	 ["time"]=10,
	 ["done"]=false,
	 ["shortcut"]="b",
	 ["positionx"]=270
      }
   }
end


function love.keypressed(key)
   -- This moves the user's paddle (paddleOne)
   -- change the state of moving
   if key == "up" or key == "down" then
      paddleOne.moving = true
      paddleOne.movingDirection = key
   end

   if key==powerUps["turboball"]["shortcut"] and not powerUps["turboball"]["done"] then
      powerUps["turboball"]["used"] = true
      ourBall.speed = 600
      ourBall.color = {204, 74, 20}
   end

   if key==powerUps["block"]["shortcut"] and not powerUps["block"]["done"] then
      powerUps["block"]["used"] = true
      paddleOponnent.speed = 0
   end
   
end


function love.keyreleased(key)
   -- This stops moving the user's paddle (paddleOne)
   -- change the state of moving
   paddleOne.moving = false
end

counter = 0  
function love.update(dt)
   
   -- Main logic is here   
   if paddleOne.moving then
      if paddleOne.movingDirection == "up" then
	 paddleOne:moveUp(dt)
      elseif paddleOne.movingDirection == "down" then
	 paddleOne:moveDown(dt)
      end
   end

   if ourBall.vx>0 then
      -- This will basically follow the ball ?
      if paddleOponnent.position.y+50>ourBall.position.y then
	 paddleOponnent.moving = true
	 paddleOponnent:moveUp(dt)
      end
      
      if paddleOponnent.position.y+50<ourBall.position.y then
	 paddleOponnent.moving = true
	 paddleOponnent:moveDown(dt)
      end
   else
      -- The oponnent will wait in the middle so he have higher chance
      -- to get the ball
      if paddleOponnent.position.y+50<love.graphics.getHeight()/2 then
	 paddleOponnent.moving = true
	 paddleOponnent:moveDown(dt)
      end
      if paddleOponnent.position.y+50>love.graphics.getHeight()/2 then
	 paddleOponnent.moving = true
	 paddleOponnent:moveUp(dt)
      end
   end
   
   counter = counter + dt
   if counter>=0.08 then -- that's about 5 frames under my intel gpu with linux4.6
      if table.getn(ourBall.ballsPos) == ourBall.shadowed then
	 -- remove last ball and queue the current position (does lua have buily-in queue?)
	 table.remove(ourBall.ballsPos, 1)
	 table.insert(ourBall.ballsPos, {x=ourBall.position.x, y=ourBall.position.y})
      else
	 -- if the queue is not filled (this dosen't occur unless we are statring out)
	 table.insert(ourBall.ballsPos, {x=ourBall.position.x, y=ourBall.position.y})
      end
      counter = 0
   end

   -- Simple boxtobox collision detection
   -- check collision with walls
   if (ourBall.position.y + ourBall.side >= love.graphics.getHeight())then
      ourBall.vy = ourBall.vy * -1
      ourBall.position.y = love.graphics.getHeight() - ourBall.side 
   end

   if (ourBall.position.y<=0) then
      ourBall.vy = ourBall.vy * -1
      ourBall.position.y = 0
   end

   if (ourBall.position.x + ourBall.side >= love.graphics.getWidth()) then
      paddleOne.score = 1 + paddleOne.score
      ourBall.position.x = love.graphics.getWidth() / 2
      ourBall.position.y = love.graphics.getHeight() / 2
      ourBall.vx = choice[math.random(1, 2)]
   end

   if (ourBall.position.x<=0) then
      paddleOponnent.score = 1 + paddleOponnent.score
      ourBall.position.x = love.graphics.getWidth() / 2
      ourBall.position.y = love.graphics.getHeight() / 2
      ourBall.vx = choice[math.random(1, 2)]
   end

   if powerUps["turboball"]["used"] and not powerUps["turboball"]["done"] then
      powerUps["turboball"]["time"] =  powerUps["turboball"]["time"] - dt
      if powerUps["turboball"]["time"] <= 0 then
	 powerUps["turboball"]["done"] = true
	 powerUps["turboball"]["used"] = false
	 ourBall.speed = ourBall.defaultSpeed
	 ourBall.color = {222, 219, 220}
      end
   end


   if powerUps["block"]["used"] and not powerUps["block"]["done"] then
      powerUps["block"]["time"] = powerUps["block"]["time"] - dt
      if powerUps["block"]["time"] <= 0 then
	 powerUps["block"]["done"] = true
	 powerUps["block"]["used"] = false
	 paddleOponnent.speed = paddleOponnent.defaultSpeed
      end
   end
   
   -- check collision with paddles
   if (ourBall.position.x<=20) then
      if (ourBall.position.y>=paddleOne.position.y) and (ourBall.position.y<=paddleOne.position.y+100) then
	 ourBall.vx = ourBall.vx * -1
	 ourBall.position.x = 20
      end
   end

   if (ourBall.position.x+ourBall.side>=love.graphics.getWidth() - 20) then
      if (ourBall.position.y>=paddleOponnent.position.y) and (ourBall.position.y<=paddleOponnent.position.y+100) then
	 ourBall.vx = ourBall.vx * -1
	 ourBall.position.x = love.graphics.getWidth() - 10 * 2 - ourBall.side
      end
   end
   
   ourBall.position.x = ourBall.position.x + ourBall.speed * dt * ourBall.vx
   ourBall.position.y = ourBall.position.y + ourBall.speed * dt * ourBall.vy
end


function love.draw()
   -- This is where I draw to the screen

   love.graphics.setColor(255, 255, 255)
   paddleOne:draw()
   paddleOponnent:draw()
   ourBall:draw()
   love.graphics.setColor(222, 219, 220, 255)
   love.graphics.print(paddleOne.score .. " - " .. paddleOponnent.score, love.graphics.getWidth()/2 - 20)
   love.graphics.print("Power ups:", 30, love.graphics.getHeight() - 30)
   for _, value in pairs(powerUps) do
      if value["used"] then
	 love.graphics.setColor(84, 204, 20)
      elseif value["done"] then
	 love.graphics.setColor(204, 74, 20)
      else
	 love.graphics.setColor(222, 219, 220, 255)
      end
      love.graphics.print(value["screenName"], value["positionx"], love.graphics.getHeight() - 30)
   end
end
