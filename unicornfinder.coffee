@Unicorns = new Meteor.Collection "unicorns"
@Skills = new Meteor.Collection "skills"

allSkills = -> Skills.find()
allUnicorns = -> Unicorns.find()

if Meteor.isClient
  Template.hello.username = username = -> Meteor.user()?.profile?.name

  Template.allSkills.allSkills = ->
    ({name: skill.name} for skill in Skills.find().fetch())

  Template.allUnicorns.allUnicorns = ->
    ({name: unicorn.name} for unicorn in Unicorns.find().fetch())

  Template.skills.mySkills = ->
    skillIds = Unicorns.findOne(Meteor.userId())?.skillIds
    if skillIds? then skills = ({name: Skills.findOne(skillId).name} for skillId in skillIds)
    skills

  getUnicornId = ->
    Unicorns.findOne(Meteor.userId())?._id or Unicorns.insert {_id: Meteor.userId(), name: username()}

  getSkillId = (name) ->
    Skills.findOne({name})?._id or Skills.insert {name, unicornIds: [Meteor.userId()]}

  Template.skills.events
    'click #skillAdd': (ev, template) ->
      unicornId = getUnicornId()
      skillId = getSkillId template.find('#skillText').value
      
      Unicorns.update unicornId, {$addToSet: {skillIds: skillId}}
      Skills.update skillId, {$addToSet: {unicornIds: unicornId}}

if Meteor.isServer
  Meteor.startup ->
    Unicorns.remove {}
    Skills.remove {}

  onlyId = (userId, doc) -> doc.unicornIds.length is 1 and doc.unicornIds[0] is userId
  addId = (userId, doc, fields, modifier) -> true or modifier is {$addToSet: {unicornIds: userId}}
  Skills.allow
    insert: onlyId
    update: addId
    remove: onlyId

  # You can only update your own unicorn row
  sameId = (userId, doc) -> doc._id is userId
  Unicorns.allow
    insert: sameId
    update: sameId
    remove: sameId