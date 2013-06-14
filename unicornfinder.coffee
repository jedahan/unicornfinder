@Unicorns = new Meteor.Collection "unicorns"
@Skills = new Meteor.Collection "skills"
@Projects = new Meteor.Collection "projects"

username = -> Meteor.user()?.profile?.name

if Meteor.isClient
  Template.hello.username = username

  Template.allProjects.allProjects = ->
    projects = []
    for project in Projects.find().fetch()
      name = project.name
      unicorns = []
      for unicorn in Unicorns.find({projectIds: {$in: [project._id]}}).fetch()
        unicorns.push unicorn.name
      projects.push {name, unicorns}
    projects

  Template.allSkills.allSkills = ->
    skills = []
    for skill in Skills.find().fetch()
      name = skill.name
      unicorns = []
      for unicorn in Unicorns.find({skillIds: {$in: [skill._id]}}).fetch()
        unicorns.push unicorn.name
      skills.push {name, unicorns}
    skills

  Template.allUnicorns.allUnicorns = ->
    ({name: unicorn.name} for unicorn in Unicorns.find().fetch())

  Template.skills.mySkills = ->
    skillIds = Unicorns.findOne(Meteor.userId())?.skillIds
    if skillIds? then skills = ({name: Skills.findOne(skillId).name} for skillId in skillIds)
    skills

  Template.projects.myProjects = ->
    projectIds = Unicorns.findOne(Meteor.userId())?.projectIds
    if projectIds? then projects = ({name: Projects.findOne(projectId).name} for projectId in projectIds)
    projects

  getUnicornId = ->
    Unicorns.findOne(Meteor.userId())?._id or Unicorns.insert {_id: Meteor.userId(), name: username()}

  getSkillId = (name) ->
    Skills.findOne({name})?._id or Skills.insert {name, unicornIds: [Meteor.userId()]}

  getProjectId = (name) ->
    Projects.findOne({name})?._id or Projects.insert {name, unicornIds: [Meteor.userId()]}

  Template.skills.events
    'click #skillAdd': (ev, template) ->
      unicornId = getUnicornId()
      skillId = getSkillId template.find('#skillText').value
      
      Unicorns.update unicornId, {$addToSet: {skillIds: skillId}}
      Skills.update skillId, {$addToSet: {unicornIds: unicornId}}

  Template.projects.events
    'click #projectAdd': (ev, template) ->
      unicornId = getUnicornId()
      projectId = getProjectId template.find('#projectText').value
      
      Unicorns.update unicornId, {$addToSet: {projectIds: projectId}}
      Projects.update projectId, {$addToSet: {unicornIds: unicornId}}

if Meteor.isServer
  Meteor.startup ->
    Unicorns.remove {}
    Skills.remove {}
    Projects.remove {}

  onlyId = (userId, doc) -> doc.unicornIds.length is 1 and doc.unicornIds[0] is userId
  addId = (userId, doc, fields, modifier) -> true or modifier is {$addToSet: {unicornIds: userId}}
  Skills.allow
    insert: onlyId
    update: addId
    remove: onlyId

  Projects.allow
    insert: onlyId
    update: addId
    remove: onlyId

  # You can only update your own unicorn row
  sameId = (userId, doc) -> doc._id is userId
  Unicorns.allow
    insert: sameId
    update: sameId
    remove: sameId