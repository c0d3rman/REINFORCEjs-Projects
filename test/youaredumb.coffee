RL = require '../rl.js'

class Environment
	constructor: ->
		@currentState = 0
		@targetState = 1
		@rightReward = 1
		@wrongReward = -1
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

		#return reward
		r

# create the environment and DQN agent
env = new Environment()
spec =
	update: 'qlearn'
	#num_hidden_units: 5
agent = new RL.DQNAgent env, spec

a = 1
learningInterval = setInterval -> # start the learning loop
	action = agent.act env.getState()
	reward = env.tick action
	agent.learn reward # the agent improves its Q,policy,model, etc. reward is a float
	console.log "#{a++} | state = #{env.currentState} | action = #{if action is 1 then "switch" else "don't switch"} | r = #{reward}"
, 0

test = (n) ->
	sumreward = 0
	agent.epsilon = 0
	for i in [1..n]
		action = agent.act env.getState()
		sumreward += env.tick action
	sumreward / n

dispGame = (n) ->
	for i in [1..n]
		action = agent.act env.getState()
		r = env.tick action
		#console.log "FLAP | #{i} | y = #{env.y} | vy = #{env.vy} | r = #{r}" if action is 1
		console.log "#{i++} | state = #{env.currentState} | action = #{if action is 1 then "switch" else "don't switch"} | r = #{r}"

done = ->
	console.log "Trained for #{env.ticks} ticks"
	console.log "Sample game:"
	console.log "Average reward: #{test(10000)}"
	dispGame(100)

setTimeout ->
	clearInterval learningInterval
	done()
, 1000 * 10