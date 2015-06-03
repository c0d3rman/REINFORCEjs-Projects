RL = require '../rl.js'

class Environment
	constructor: ->
		@currentState = 0
		@targetState = 1
		@rightReward = 1
		@wrongReward = -1
		@flipChance = 0.2
		@ticks = 0

	getNumStates: -> 2 # currentState, targetState
	getMaxNumActions: -> 2 # switch, don't switch
	getState: -> [@currentState, @targetState]
	getReward: -> if @currentState is @targetState then @rightReward else @wrongReward

	tick: (a) ->
		@ticks++

		#action
		if a is 1
			if @currentState is 0
				@currentState = 1
			else
				@currentState = 0

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
	num_hidden_units: 5
	gamma: 0
agent = new RL.DQNAgent env, spec

a = 1
learningInterval = setInterval -> # start the learning loop
	current = env.currentState
	target = env.targetState
	action = agent.act env.getState()
	reward = env.tick action
	agent.learn reward # the agent improves its Q,policy,model, etc. reward is a float
	console.log "#{a++}\t| s = #{current} | t = #{target} | a = #{if action is 1 then "S" else "-"} | e = #{agent.epsilon} \t| r = #{reward}"
	agent.epsilon *= 0.999 # decay epsilon
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
		action = agent.act env.getState()
		reward = env.tick action
		console.log "#{i}\t| s = #{current} | t = #{target} | a = #{if action is 1 then "S" else "-"} | e = #{agent.epsilon}\t| r = #{reward}"

done = ->
	console.log "Trained for #{env.ticks} ticks"
	agent.epsilon = 0
	console.log "Sample game:"
	dispGame(100)
	console.log "Average reward: #{test(10000)}"

setTimeout ->
	clearInterval learningInterval
	done()
, 1000 * 20