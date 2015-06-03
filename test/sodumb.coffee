RL = require '../rl.js'

class Environment
	constructor: ->
		@ticks = 0
		@target = 4

	getNumStates: -> 1
	getMaxNumActions: -> 100
	getState: -> [0]
	getReward: (a) -> Math.max 1 - (Math.abs a - @target) / 10, -1

	tick: (a) ->
		@ticks++

		#reward
		r = @getReward a

		#return reward
		r

# create the environment and DQN agent
env = new Environment()
spec =
	update: 'qlearn'
	epsilon: 0.5
	#num_hidden_units: 5
agent = new RL.DQNAgent env, spec

a = 1
learningInterval = setInterval -> # start the learning loop
	action = agent.act env.getState()
	reward = env.tick action
	agent.learn reward # the agent improves its Q,policy,model, etc. reward is a float
	console.log "#{a++} | action = #{action} | r = #{reward}"
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
		reward = env.tick action
		console.log "#{i++} | action = #{action} | r = #{reward}"

done = ->
	console.log "Trained for #{env.ticks} ticks"
	console.log "Sample game:"
	console.log "Average reward: #{test(10000)}"
	dispGame(100)

setTimeout ->
	clearInterval learningInterval
	done()
, 1000 * 10