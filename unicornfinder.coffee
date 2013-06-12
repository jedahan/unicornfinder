Skills = new Meteor.Collection "skills"

if Meteor.isClient
  Template.hello.greeting = ->
    if Session.get('username')
      "Hello #{Session.get('username')}"
    else
      "Welcome to unicorn finder"

  Template.skills.allSkills = ->
    Skills.find()

  Template.skills.events
    'click #skillAdd': (ev, template) ->
      skill = template.find('#skillText').value
      Skills.insert {skill}