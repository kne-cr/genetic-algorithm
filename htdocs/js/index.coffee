Math.randomNumber = (max) ->
  this.floor(this.random() * max)

Math.upOrDown = ->
  if 0.5 < this.random()
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
    pivot = Math.randomNumber @code.length
    child1code = @code.substr(0, pivot) + another.code.substr pivot
    child2code = another.code.substr(0, pivot) + @code.substr pivot
    [new Gene(child1code, @sentence), new Gene(child2code, @sentence)]

  mutate: ->
    return if 0.3 < Math.random()
    index1 = Math.randomNumber @code.length
    index2 = Math.randomNumber @code.length
    index3 = Math.randomNumber @code.length
    newCode = for s, i in @code
      if i is index1 or i is index2 or i is index3
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
      member.code is @sentence.goal
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