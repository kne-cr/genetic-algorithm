Math.randomNumber = (max) ->
  this.floor(this.random() * max)

Math.randomBoolean = ->
  0.5 < this.random()

Math.upOrDown = ->
  if this.randomBoolean()
    1
  else
    -1

class Sentence
  constructor: (@goal) ->
    @usable = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz .!?".split("");

  random: ->
    @usable[Math.randomNumber @usable.length]

  change: (char) ->
    index = @usable.indexOf(char) + Math.upOrDown() - @usable.length
    @usable.slice(index, index + 1)[0] ? @usable.slice(-1)[0]

  diff: (compareTo) ->
    diffs = for i in [0...compareTo.length]
      Math.abs(@usable.indexOf(compareTo[i]) - @usable.indexOf(@goal[i]))
    diffs.reduce (a, b) -> a + b

class Gene
  constructor: (@code, @sentence) ->

  cost: ->
    @sentence.diff @code

  mate: (another) ->
    child1code = ""
    child2code = ""
    for i in [0...@code.length]
      if Math.random()
        child1code += @code[i]
        child2code += another.code[i]
      else
        child1code += another.code[i]
        child2code += @code[i]
    
    [new Gene(child1code, @sentence), new Gene(child2code, @sentence)]

  mutate: ->
    return if 0.3 < Math.random()
    indexes = Math.randomNumber(@code.length) for i in [0...3]
    newCode = for s, i in @code
      if 0 <= indexes.indexOf i
        @sentence.change s
      else
        s
    @code = newCode.join ""

class Population
  constructor: (@sentence) ->
    @generationNumber = 0
    @members = for i in [0...20]
      code = for i in [0...@sentence.goal.length]
        @sentence.random()
      new Gene code.join(""), @sentence

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
    genes = for member in @members
      member.code
    $("#result").html("#{@generationNumber}世代\r\n" + genes.join("\r\n") + "\r\n\r\n" + $("#result").html())

  hasGoalGene: ->
    bools = for member in @members
      member.cost() is 0
    bools.some (isSameAsGoal) -> isSameAsGoal

  generate: ->
    @mate()
    @mutate()
    @sort()
    @display()
    return if @hasGoalGene()
    @generationNumber++
    @generate()

$("#search").click ->
  new Population(new Sentence $("#input").val()).generate()
