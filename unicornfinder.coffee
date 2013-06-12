@Unicorns = new Meteor.Collection "unicorns"
@Skills = new Meteor.Collection "skills"

allSkills = -> Skills.find()
allUnicorns = -> Unicorns.find()

if Meteor.isClient
  Template.hello.username = Template.unicorn.username = username = -> Meteor.user()?.profile?.name

  Template.unicorn.mySkills = ->
    skills = []
    for skillId in Unicorns.find(Meteor.userId()).fetch().skills
      skills.push Skills.find(skillId).name
    skills

  getAttributeId = (attr, name) ->
    attr.find({name}).fetch()?._id or
    attr.insert {name, unicornIds: [Meteor.userId()]}

  getUnicornId = ->
    Unicorns.find(Meteor.userId()).fetch()?._id or
    Unicorns.insert {_id: Meteor.userId(), name: username()}

  Template.unicorn.events
    'click #skillAdd': (ev, template) ->
      unicornId = getUnicornId()
      skillId = getAttributeId Skills, template.find('#skillText').value
      
      Unicorns.update unicornId, {$addToSet: {skillIds: skillId}}
      Skills.update skillId, {$addToSet: {unicornIds: unicornId}}

if Meteor.isServer
  Meteor.startup ->
    Unicorns.remove {}
    Skills.remove {}

  onlyId = (id, doc) -> doc.unicornIds is [id]
  addId = (id, doc, fields, modifier) -> modifier is {$addToSet: {unicornIds: id}}
  Skills.allow
    insert: onlyId
    update: addId
    remove: onlyId

  # You can only update your own unicorn row
  sameId = (id, doc) -> doc._id is id
  Unicorns.allow
    insert: sameId
    update: sameId
    remove: sameId