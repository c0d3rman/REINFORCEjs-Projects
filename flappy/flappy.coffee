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
		@ticks = -1
		@reset()

	#getNumStates: -> 2 # y, vy
	getNumStates: -> 1 # y
	getMaxNumActions: -> 2 # flap, don't flap
	#getState: -> [@y, @vy]
	getState: -> @y
	getReward: -> 1 - (Math.abs(@y - (@maxHeight / 2)) / (@maxHeight / 3)) # -0.5 to 1

	tick: (a) ->
		@ticks++
		# flapping
		@vy = @jumpStrength if a is 1

		# world dynamics
		@vy += @gravity
		@y += @vy

		# reward
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
	alpha: 0.01
	gamma: 0
	update: 'qlearn'
agent = new RL.DQNAgent env, spec

learningInterval = setInterval -> # start the learning loop
	action = agent.act env.getState()
	reward = env.tick action
	agent.learn reward # the agent improves its Q,policy,model, etc. reward is a float
, 0

test = (n) ->
	sumticks = 0
	for a in [1..n] 
		env.reset()
		i = 0
		while true
			action = agent.act env.getState()
			r = env.tick action
			i++
			if r == env.deathReward
				sumticks += i
				break
	sumticks / n

dispGame = ->
	env.reset()
	i = 0
	while true
		action = agent.act env.getState()
		r = env.tick action
		#console.log "FLAP | #{i} | y = #{env.y} | vy = #{env.vy} | r = #{r}" if action is 1
		console.log "#{i} | y = #{env.y} | vy = #{env.vy} | action = #{if action is 1 then "flap" else "don't flap"} | r = #{r}"
		i++
		if r == env.deathReward
			console.log "DIED AFTER #{i} ticks"
			break

done = ->
	console.log "Trained for #{env.ticks} ticks"
	console.log "Average survival time: #{test(100)} ticks"
	console.log "Sample game:"
	dispGame()

setTimeout ->
	clearInterval learningInterval
	done()
, 1000 * 5