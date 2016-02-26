# Description
#   A simple Pokémon battler.
#
# Configuration:
#   BULBASAUR_EMOJI  - Emoji keyword for Bulbasaur  (default: :bulbasaur:)
#   CHARMANDER_EMOJI - Emoji keyword for Charmander (default: :charmander:)
#   SQUIRTLE_EMOJI   - Emoji keyword for Squirtle   (default: :squirtle:)
#
# Commands:
#   hubot poke battle start   - start a new battle
#   hubot poke battle restart - end the current battle and start a new one
#   hubot poke battle end     - end the current battle
#
# Author:
#   github.com/mattantonelli

env = process.env

# Types (vs grass, fire, water, normal)
TYPE_MODIFIERS = {
  grass:  { grass: 0.5, fire: 0.5, water: 2.0, normal: 1.0 }
  fire:   { grass: 2.0, fire: 0.5, water: 0.5, normal: 1.0 }
  water:  { grass: 0.5, fire: 2.0, water: 0.5, normal: 1.0 }
  normal: { grass: 1.0, fire: 1.0, water: 1.0, normal: 1.0 }
}

# Multipliers for stages of atk/def up/down
STAGE_MULTIPLIERS = [0.25, 0.29, 0.33, 0.40, 0.50, 0.67, 1.00, 1.50, 2.00, 2.50, 3.00, 3.50, 4.00]

# Moves
TACKLE    = { name: 'TACKLE',    type: 'normal', effect: 'attack', power: 50 }
SCRATCH   = { name: 'SCRATCH',   type: 'normal', effect: 'attack', power: 40 }

GROWL     = { name: 'GROWL',     type: 'normal', effect: 'attack down',  power: null }
TAIL_WHIP = { name: 'TAIL WHIP', type: 'normal', effect: 'defense down', power: null }

VINE_WHIP = { name: 'VINE WHIP', type: 'grass', effect: 'special attack', power: 45 }
EMBER     = { name: 'EMBER',     type: 'fire',  effect: 'special attack', power: 40 }
WATER_GUN = { name: 'WATER GUN', type: 'water', effect: 'special attack', power: 40 }

# Pokémon
BULBASAUR = {
  name: "#{env.BULBASAUR_EMOJI || ':bulbasaur:'} Bulbasaur"
  type: 'grass'
  level: 1
  moves: [TACKLE, GROWL, VINE_WHIP]
  hp: 45
  attack: 49
  defense: 49
  sp_attack: 65
  sp_defense: 65
  speed: 45
  attack_stage: 0
  defense_stage: 0
}

CHARMANDER = {
  name: "#{env.CHARMANDER_EMOJI || ':charmander:'} Charmander"
  type: 'fire'
  level: 1
  moves: [SCRATCH, GROWL, EMBER]
  hp: 39
  attack: 52
  defense: 43
  sp_attack: 60
  sp_defense: 50
  speed: 65
  attack_stage: 0
  defense_stage: 0
}

SQUIRTLE = {
  name: "#{env.SQUIRTLE_EMOJI || ':squirtle:'} Squirtle"
  type: 'water'
  level: 1
  moves: [TACKLE, TAIL_WHIP, WATER_GUN]
  hp: 44
  attack: 48
  defense: 65
  sp_attack: 50
  sp_defense: 64
  speed: 43
  attack_stage: 0
  defense_stage: 0
}

module.exports = (robot) ->
  robot.respond /poke battle start/i, (res) ->
    startGame(res)

  robot.respond /poke battle restart/i, (res) ->
    restartGame(res)

  robot.respond /poke battle end/i, (res) ->
    endGame(res)


  startGame = (res) ->
    res.send """
             Welcome to the Hubot Pokémon Stadium!
             Please choose your Pokémon:
             #{SQUIRTLE.name} #{BULBASAUR.name} #{CHARMANDER.name}
             """
    robot.hear /(squirtle|bulbasaur|charmander)/i, (res) ->
      choosePokemon(res, res.match[1])

  choosePokemon = (res, pokemon) ->
    key = brainKey(res, 'attacker')

    if pokemon == 'squirtle'
      robot.brain.set(key, SQUIRTLE)
    else if pokemon == 'bulbasaur'
      robot.brain.set(key, BULBASAUR)
    else if pokemon == 'charmander'
      robot.brain.set(key, CHARMANDER)

    pokemon = robot.brain.get(key)
    res.send "You chose #{pokemon.name}!"

  restartGame = (res) ->
    # Restart

  endGame = (res) ->
    # End

  useMove = (res, attacker, defender, move) ->
    if move.effect == 'attack' || move.effect == 'special attack'
      attack = if move.effect == 'attack' then attacker.attack else attacker.sp_attack
      defense = if move.effect == 'attack' then defender.defense else defender.sp_defense
      attack  *= STAGE_MULTIPLIERS[attacker.attack_stage + 6]
      defense *= STAGE_MULTIPLIERS[defender.defense_stage + 6]
      damage = ( ((2 * attacker.level + 10) / 250) * (attack / defense) * move.power ) * modifier(attacker, defender, move)
      defender.hp = Math.max(defender.hp - damage, 0)
    else if move.effect == 'attack down'
      defender.attack_stage = Math.max(defender.attack_stage - 1, -6)
    else if move.effect == 'defense down'
      defender.defense_stage = Math.max(defender.defense_stage - 1, -6)

  modifier = (attacker, defender, move) ->
    stab = if attacker.type == move.type then 1.5 else 1.0
    type = TYPE_MODIFIERS[move.type][defender.type]
    critical = Math.random() * 100 < 6.25
    random = (Math.floor(Math.random() * 16) + 85) / 100
    stab * type * critical * random

  brainKey = (res, key) ->
    "#{res}-#{key}"
