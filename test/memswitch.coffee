RL = require '../rl.js'

class Environment
	constructor: ->
		@currentState = 0
		@targetState = 1
		@memBit = 0
		@rightReward = 1
		@wrongReward = -1
		@flipChance = 0.2
		@ticks = 0

	getNumStates: -> 2 # membit, targetState
	getMaxNumActions: -> 4 # switch, don't switch, switch and flip mem bit, switch and don't flip mem bit
	getState: -> [@memBit, @targetState]
	getReward: -> if @currentState is @targetState then @rightReward else @wrongReward

	tick: (a) ->
		@ticks++

		#action
		if a is 1 or a is 3
			if @currentState is 0
				@currentState = 1
			else
				@currentState = 0

		if a is 2 or a is 3
			if @memBit is 0
				@memBit = 1
			else
				@memBit = 0

		#reward
		r = @getReward()

		if Math.random() < @flipChance
			if @targetState is 0
				@targetState = 1
			else
				@targetState = 0
		
		#return reward
		r

# create the environment and DQN agent
env = new Environment()
spec =
	update: 'qlearn'
	epsilon: 0.5
	num_hidden_units: 20
	gamma: 0.7
agent = new RL.DQNAgent env, spec

a = 1
act =
	0: "--"
	1: "S-"
	2: "-F"
	3: "SF"
learningInterval = setInterval -> # start the learning loop
	current = env.currentState
	target = env.targetState
	memBit = env.memBit
	action = agent.act env.getState()
	reward = env.tick action
	agent.learn reward # the agent improves its Q,policy,model, etc. reward is a float
	console.log "#{a++}\t| s = #{current} | t = #{target} | m = #{memBit} | a = #{act[action]} | e = #{agent.epsilon} \t| r = #{reward}"
	agent.epsilon *= 0.9999 # decay epsilon
, 0

test = (n) ->
	sumreward = 0
	for i in [1..n]
		action = agent.act env.getState()
		sumreward += env.tick action
	sumreward / n

dispGame = (n) ->
	for i in [1..n]
		current = env.currentState
		target = env.targetState
		memBit = env.memBit
		action = agent.act env.getState()
		reward = env.tick action
		console.log "#{i}\t| s = #{current} | t = #{target} | m = #{memBit} | a = #{act[action]} | e = #{agent.epsilon} \t| r = #{reward}"

done = ->
	console.log "Trained for #{env.ticks} ticks"
	agent.epsilon = 0
	console.log "Sample game:"
	dispGame(100)
	console.log "Average reward: #{test(10000)}"

setTimeout ->
	clearInterval learningInterval
	done()
, 1000 * 120