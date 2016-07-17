--[[
   
   @author: Mohamed Aziz Knani (medazizknani@gmail.com)
   @since: 16/07/2016

   NOTE: This my first project using lua and love2d, so I have
   no prior knowledge of lua and love2d.
--]]


-- this is our paddle
paddle = {}

function paddle:init(speed, step, position)
   -- this is our class constructer
   -- @speed is the constant speed of the paddle (pixel per second)
   -- @step is the paddle move step size (in pixels of course)
   -- @position is the rectangle upper-left corner position
   -- TODO: Set max speed for the AI player.

   newObj = {speed = speed, position = position, moving = false}
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
   self.vx = 1
   self.vy = 1
   self.__index = self
   return setmetatable(myObj, self)
end

function ball:draw()
   -- Draws our ball to the screen
   for key, value in pairs(self.ballsPos) do
      love.graphics.setColor(222, 219, 220, 255 - key * 30)
      love.graphics.rectangle("fill", value.x, value.y, key*4, key*4)
   end
   love.graphics.setColor(222, 219, 220, 255)
   love.graphics.rectangle("fill", self.position.x, self.position.y, self.side, self.side)
end


function love.load()
   -- This is where is laod all my assets
   love.graphics.setBackgroundColor(20, 40, 70)
   paddleOne = paddle:init(400, 10, {x=0, y=0})
   paddleOponnent = paddle:init(400, 10, {x=love.graphics.getWidth()-10*2, y=0})
   ourBall = ball:init(100, 20, {x=20, y=100}, 3)
end


function love.keypressed(key)
   -- This moves the user's paddle (paddleOne)
   -- change the state of moving
   if key == "up" or key == "down" then
      paddleOne.moving = true
      paddleOne.movingDirection = key
   end
   if key == "a" or key == "q" then
      paddleOponnent.moving = true
      paddleOponnent.movingDirection = key
   end
   
end


function love.keyreleased(key)
   -- This stops moving the user's paddle (paddleOne)
   -- change the state of moving
   paddleOne.moving = false
   paddleOponnent.moving = false
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

   if paddleOponnent.moving then
      if paddleOponnent.movingDirection == "a" then
	 paddleOponnent:moveUp(dt)
      elseif paddleOponnent.movingDirection == "q" then
	 paddleOponnent:moveDown(dt)
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
      ourBall.vx = ourBall.vx * -1
      ourBall.position.x = love.graphics.getWidth() - ourBall.side
   end

   if (ourBall.position.x<=0) then
      ourBall.vx = ourBall.vx * -1
      ourBall.position.x = 0
   end

   -- check collision with paddles
   if (ourBall.position.x<=20) then
      if (ourBall.position.y>=paddleOne.position.y) and (ourBall.position.y<=paddleOne.position.y+100) then
	 ourBall.vx = ourBall.vx * -1
	 ourBall.position.x = 20
      end
   end

   if (ourBall.position.x+ourBall.side>=love.graphics.getWidth()) then
      if (ourBall.position.y>=paddleOponnent.position.y) and (ourBall.position.y<=paddleOponnent.position.y+100) then
	 print("HYA")
	 ourBall.vx = ourBall.vx * -1
	 ourBall.position.x = love.graphics.getWidth() - 20
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
end
