RL = require '../rl.js'

class HoverEnvironment
	reset: ->
		@y = @maxHeight / 2
		@vy = 0

	constructor: ->
		@maxHeight = 100
		@jumpStrength = 20
		@startingHeight = 50
		@gravity = -3
		@deathReward = -1
		@ticks = -1
		@reset()

	getNumStates: -> 1 # y
	getMaxNumActions: -> 2 # flap, don't flap
	getState: -> [@y]
	getReward: -> if @y <= 0 or @y >= @maxHeight then @deathReward else 0

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
	console.log "#{a++}\t| y = #{y} | vy = #{vy} | a = #{if action is 1 then "F" else "-"} | e = #{agent.epsilon} \t | r = #{reward}"
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
		console.log "#{i}\t| y = #{y} | vy = #{vy} | a = #{if action is 1 then "F" else "-"} | e = #{agent.epsilon} \t | r = #{reward}"

done = ->
	agent.epsilon = 0
	console.log "Trained for #{env.ticks} ticks"
	console.log "Sample game:"
	dispGame(1000)
	console.log "Average reward: #{test(10000)}"

setTimeout ->
	clearInterval learningInterval
	done()
, 1000 * 10