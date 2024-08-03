--X
---The time that has past in ticks since last reset.
function ticksSinceReset()
	return memory.readInt(memory.getBaseAddress() + 0x443f3c0c)
end

---Library for creating networked events.
events = {}

--X
---Get the number of events.
---@return integer count How many Event objects there are.
function events.getCount()
	return server.numEvents
end

--X
---Add a message to chat using the engine's expected values.
---@param speakerType integer The type of message. 0 = dead chat, 1 = human speaking, 2 = item speaking, 3 = MOTD, 4 = to admins, 5 = billboard, 6 = to player.
---@param message string The message to send. Max length 63.
---@param speakerIndex integer The index of the speaker object of the corresponding type, if applicable, or -1.
---@param volumeLevel integer The volume to speak at. 0 = whisper, 1 = normal, 2 = yell.
function events.createMessage(speakerType,message,speakerIndex,volumeLevel)
	chat.addRaw(speakerType,message,speakerIndex,volumeLevel)
end

--X
---Play a sound.
---@param soundType integer The type of the sound.
---@param position Vector The position of the sound.
---@param volume number The volume of the sound, where 1.0 is standard.
---@param pitch number The pitch of the sound, where 1.0 is standard.
function events.createSound(soundType,position,volume,pitch)
	if not volume and not pitch then
		volume, pitch = 1,1
	end
    event.sound(soundType,position,volume,pitch)
end

--X
---@param position Vector
function events.createExplosion(position)
    event.explosion(position)
end

--X
---@param bulletType integer The type of bullet.
---@param position Vector The initial position the bullet.
---@param velocity Vector The initial velocity of the bullet.
---@param item? Item The item the bullet came from.
function events.createBullet(bulletType, position, velocity,item)
	event.bullet(bulletType,position,velocity,item)
end

--X
---@param hitType integer The type of hit. 0 = bullet hole (stays until round reset), 1 = human hit (blood), 2 = car hit (metal), 3 = blood drip (bleeding).
---@param position Vector The position the bullet hit.
---@param normal Vector The normal of the surface the bullet hit.
function events.createBulletHit(hitType,position,normal)
	event.bulletHit(hitType,position,normal)
end


--X
---Cast a ray on any human or vehicle.
---@param posA Vector The start point of the ray.
---@param posB Vector The end point of the ray.
---@param ignoreHuman Human|nil The human to ignore during raycast.
---@return Human|Vehicle? object The nearest human or vehicle that the ray hit, or nil if it hit the level or nothing.
function physics.lineIntersectAnyQuick(posA, posB, ignoreHuman)
	for _,human in ipairs(humans.getAll()) do
		if human ~= ignoreHuman then
			local res = physics.lineIntersectHuman(human,posA,posB)
			if res then
				return human
			end
		end
	end

	for _,vehicle in ipairs(vehicles.getAll()) do
		local res = physics.lineIntersectVehicle(vehicle,posA,posB)
		if res then
			return vehicle
		end
	end
end

--X
---Get all players that are bots.
---@return Player[] bots A list of all Player objects that are bots.
function players.getBots()
	local allPlayers = players.getAll()
	local bots = {}

	for _,ply in ipairs(allPlayers) do
		if ply.isBot then
			table.insert(bots,ply)
		end
	end

	return bots
end

--Types

--X
Vector3 = {}
---Calculate the length of a vector
---@param vector Vector The vector to calculate the length of.
---@return number length The length of the vector.
function Vector3.length(vector)
	return vector:dist(Vector())
end

--X
---Calculate the length of the vector, squared.
---Much faster as it does not square root the value.
---@param vector Vector The vector to calculate the length of.
---@return number length The length of the vector, squared.
function Vector3.lengthSquare(vector)
	return vector:distSquare(Vector())
end

--X
---Normalize the vector's values so that it has a length of 1.
---@param vector Vector The vector to normalize.
---@return Vector vector The normalized vector
function Vector3.normalize(vector)
	local length = Vector3.length(vector)
	local x = vector.x / length
	local y = vector.y / length
	local z = vector.z / length
	return Vector(x,y,z)
end

--X
---Calculate the dot product of vector and otherVector.
---@param vector Vector The vector to calculate the dot product with.
---@param otherVector Vector The other vector to calculate the dot product with.
---@return number dotProduct The dot product of self and other.
function Vector3.dotProduct(vector,otherVector)
	local x = vector.x * otherVector.x
	local y = vector.y * otherVector.y
	local z = vector.z * otherVector.z
	return x+y+z
end

--Allow Spawning Traffic Cars
local ffi = require("ffi")
trafficCars = {}
trafficCars.createMany = nil

local base = memory.getBaseAddress()

do
    trafficCars.createMany = ffi.cast("void (*)(int amount)", base + 0x902a0)
end