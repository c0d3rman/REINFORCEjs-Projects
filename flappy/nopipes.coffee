RL = require '../rl.js'

class HoverEnvironment
	reset: ->
		@y = @maxHeight / 2
		@vy = 0

	constructor: ->
		@maxHeight = 100
		@jumpStrength = 10
		@startingHeight = 50
		@gravity = -3
		@deathReward = -1
		@minReward = -0.5
		@steepness = 3 # 1 to inf
		@resetChance = 1 / 50
		@ticks = -1
		@reset()

	getNumStates: -> 2 # y, vy
	#getNumStates: -> 1 # y
	getMaxNumActions: -> 2 # flap, don't flap
	getState: -> [@y, @vy]
	getReward: -> (1 - @minReward) * ((1 - Math.abs((@y / (@maxHeight / 2)) - 1)) ** @steepness) + @minReward # @minReward to 1
	#getReward: -> if @y < @maxHeight / 2 then (2 - @minReward) ** (2 * @y / @maxHeight) - 1 + @minReward else (2 - @minReward) ** ((-2 * @y  / @maxHeight) + 2) - 1 + @minReward # -0.75 to 1
	#getReward: -> 1 - (Math.abs(@y - (@maxHeight / 2)) / (@maxHeight / 3)) # -0.5 to 1
	#getReward: -> Math.min(Math.max(1 - (Math.abs(@y - (@maxHeight / 2)) / (@maxHeight / 6)), -1), 1) # -1 to 1

	tick: (a) ->
		@ticks++
		# flapping
		@vy = @jumpStrength if a is 1

		# world dynamics
		@vy += @gravity
		@y += @vy

		#reward
		r = @getReward()

		# check death
		if @y <= 0 or @y >= @maxHeight
			@reset()
			r = @deathReward

		#return reward
		r

# create the environment and DQN agent
env = new HoverEnvironment()
spec =
	update: 'qlearn'
	epsilon: 0.5
	num_hidden_units: 50
	gamma: 0.5
agent = new RL.DQNAgent env, spec

a = 1
learningInterval = setInterval -> # start the learning loop
	y = env.y
	vy = env.vy
	action = agent.act env.getState()
	reward = env.tick action
	agent.learn reward # the agent improves its Q,policy,model, etc. reward is a float
	console.log "#{a++}\t| y = #{y} | vy = #{vy} | a = #{if action is 1 then "S" else "-"} | e = #{agent.epsilon} \t | r = #{reward}"
	agent.epsilon *= 0.9995 # decay epsilon
, 0

test = (n) ->
	sumreward = 0
	env.reset()
	agent.epsilon = 0
	for i in [1..n]
		action = agent.act env.getState()
		sumreward += env.tick action
	sumreward / n

dispGame = (n) ->
	env.reset()
	for i in [1..n]
		y = env.y
		vy = env.vy
		action = agent.act env.getState()
		reward = env.tick action
		console.log "#{i}\t| y = #{y} | vy = #{vy} | a = #{if action is 1 then "S" else "-"} | e = #{agent.epsilon} \t | r = #{reward}"

done = ->
	agent.epsilon = 0
	console.log "Trained for #{env.ticks} ticks"
	console.log "Sample game:"
	dispGame(100)
	console.log "Average reward: #{test(10000)}"

setTimeout ->
	clearInterval learningInterval
	done()
, 1000 * 30