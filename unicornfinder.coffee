Unicorns = new Meteor.Collection "unicorns"
Projects = new Meteor.Collection "projects"
Skills = new Meteor.Collection "skills"

mapSkills = ->
  for skill in this.skills
    emit null, skill

mapProjects = ->
  for skill in this.skills
    emit null, skill

unique = (key, values) ->
  skills = []
  for value in values
    skills.concat values
  return skills

if Meteor.isClient
  Template.hello.userId = ->
    Meteor.userId

  Meteor.subscribe "unicorns"

  Template.hello.events "click input": ->
    if typeof console isnt "undefined"
      console.log Unicorns.find().fetch()

    Meteor.call "add_skill", skill, (error, user_id) ->
      console.log error, user_id


if Meteor.isServer
  Meteor.methods
    add_skill: (skill) ->
      console.log skill
      return skill+" back"

  Meteor.startup ->
    if Unicorns.find({name: "Jonathan Dahan"}).count() > 1
      Unicorns.remove name: "Jonathan Dahan"

    if Unicorns.find({name: "Jonathan Dahan"}).count() is 0
      Unicorns.insert
        name: "Jonathan Dahan"
        website: "http://jonathan.is"
        skills: ["coffeescript"]
        projects: ["unicornfinder"]

  Meteor.publish "skills", ->
    Unicorns.find().mapReduce mapSkills, unique
  
  Meteor.publish "projects", ->
    Unicorns.find().mapReduce mapProjects, unique

  Meteor.publish "unicorns", ->
    Unicorns.find()
