# Description
#   A simple Pokémon battler.
#
# Configuration:
#   BULBASAUR_EMOJI  - Emoji keyword for Bulbasaur  (e.g. :bulbasaur:)
#   CHARMANDER_EMOJI - Emoji keyword for Charmander (e.g. :charmander:)
#   SQUIRTLE_EMOJI   - Emoji keyword for Squirtle   (e.g. :squirtle:)
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

# Moves
TACKLE    = { name: 'TACKLE',    type: 'normal', effect: 'damage', power: 50 }
SCRATCH   = { name: 'SCRATCH',   type: 'normal', effect: 'damage', power: 40 }

GROWL     = { name: 'GROWL',     type: 'normal', effect: 'damage down',  power: null }
TAIL_WHIP = { name: 'TAIL WHIP', type: 'normal', effect: 'defense down', power: null }

VINE_WHIP = { name: 'VINE WHIP', type: 'grass', effect: 'special damage', power: 45 }
EMBER     = { name: 'EMBER',     type: 'fire',  effect: 'special damage', power: 40 }
WATER_GUN = { name: 'WATER GUN', type: 'water', effect: 'special damage', power: 40 }

# Pokémon
BULBASAUR = {
  name: 'BULBASAUR'
  emoji: env.BULBASAUR_EMOJI
  type: 'grass'
  moves: [TACKLE, GROWL, VINE_WHIP]
  hp: 45
  attack: 49
  defense: 49
  sp_attack: 65
  sp_defense: 65
  speed: 45
}

CHARMANDER = {
  name: 'CHARMANDER'
  emoji: env.CHARMANDER_EMOJI
  type: 'fire'
  moves: [SCRATCH, GROWL, EMBER]
  hp: 39
  attack: 52
  defense: 43
  sp_attack: 60
  sp_defense: 50
  speed: 65
}

SQUIRTLE = {
  name: 'SQUIRTLE'
  emoji: env.SQUIRTLE_EMOJI
  type: 'water'
  moves: [TACKLE, TAIL_WHIP, WATER_GUN]
  hp: 44
  attack: 48
  defense: 65
  sp_attack: 50
  sp_defense: 64
  speed: 43
}

module.exports = (robot) ->
  robot.respond /poke battle start/i, (msg) ->
    startGame(msg)

  robot.respond /poke battle restart/i, (msg) ->
    restartGame(msg)

  robot.respond /poke battle end/i, (msg) ->
    endGame(msg)
