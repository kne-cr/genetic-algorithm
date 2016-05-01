SETTING = {
  USABLE_STRING: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz .!?"
  POPULATION_MEMBER_COUNT: 20
  MUTATION_RATE: 0.3
  MUTATION_COUNT: 3
}

Math.randomNumber = (max) ->
  this.floor(this.random() * max)

Math.upOrDown = ->
  if 0.5 < this.random()
    1
  else
    -1

class Sentence
  constructor: (@goal) ->
    @usable = SETTING.USABLE_STRING.split ""

  random: ->
    @usable[Math.randomNumber @usable.length]

  change: (char) ->
    index = @usable.indexOf(char) + Math.upOrDown() - @usable.length
    @usable.slice(index, index + 1)[0] ? @usable.slice(-1)[0]

  diff: (compareTo) ->
    diffs = 0
    for i in [0...compareTo.length]
      diffs += Math.abs(@usable.indexOf(compareTo[i]) - @usable.indexOf(@goal[i]))
    diffs

  goalLength: ->
    @goal.length

class Gene
  constructor: (@code, @sentence) ->

  cost: ->
    @sentence.diff @code

  mate: (another) ->
    pivot = Math.randomNumber @code.length
    child1code = @code.slice(0, pivot).concat(another.code.slice pivot)
    child2code = another.code.slice(0, pivot).concat(@code.slice pivot)
    [new Gene(child1code, @sentence), new Gene(child2code, @sentence)]

  mutate: ->
    return if SETTING.MUTATION_RATE < Math.random()
    changeCodeIndexes = (Math.randomNumber(@code.length) for i in [0...SETTING.MUTATION_COUNT])
    newCode = for s, i in @code
      if 0 <= changeCodeIndexes.indexOf i
        @sentence.change s
      else
        s
    @code = newCode

  isGoal: ->
    @cost() is 0

class Population
  constructor: (@sentence) ->
    @generationNumber = 0
    @members = for i in [0...SETTING.POPULATION_MEMBER_COUNT]
      code = for i in [0...@sentence.goalLength()]
        @sentence.random()
      new Gene code, @sentence

  mate: ->
    children = @members[0].mate @members[1]
    @members.splice @members.length - 2, 2, children[0], children[1]

  mutate: ->
    for member in @members
      member.mutate()

  sort: ->
    @members.sort (a, b) ->
      a.cost() - b.cost()

  display: ->
    message = ""
    for member, i in @members
      message += "#{@generationNumber}世代 No.#{i + 1} #{member.code.join('')} <br>"
    $("#result").html(message + $("#result").html())

  hasGoalGene: ->
    for member in @members
      return true if member.isGoal()
    false

  generate: ->
    @mate()
    @mutate()
    @sort()
    @display()
    return if @hasGoalGene()
    @generationNumber++
    scope = @
    setTimeout ->
      scope.generate()
    , 10

getInvalidChars = ->
  char for char in $("#input").val().split "" when SETTING.USABLE_STRING.indexOf(char) < 0

$("#search").click ->
  invalidChars = getInvalidChars()
  if 0 < invalidChars.length
    alert("入力できない文字#{invalidChars}が含まれています")
    return
  $("#result").empty()
  new Population(new Sentence $("#input").val()).generate()