Applicants = new Meteor.Collection("applicants")
Interviews = new Meteor.Collection("interviews")
process.env.MAIL_URL = 'smtp://zhenyu%40unitedstack.com:houzhenyu1988@smtp.googlemail.com:465'
DOMAIN = "127.0.0.1:3000"
MAIL_FROM = "mis@unitedstack.com"



interviewText = ( interview ) ->
  return """
    Hello #{interview.interviewer.profile.name} ! Recruit team just asigned a interview task to you.
    Pleace visit http://#{DOMAIN}/hiring/#{interview._id} to see the interview detail.
  """

sendEmail = (to, from, subject, text) ->
  check [to, from, subject, text], [String] 
  # this.unblock()
  Email.send
    to: to
    from: from
    subject: subject
    text: text
  
sendInterviewEmail = ( interview ) ->
  # console.log( interview, interviewText( interview ) )
  sendEmail( interview.interviewer.services.google.email, MAIL_FROM, "New Interview Task", interviewText( interview ) )


Meteor.methods(
	clear:()->
    # console.log("cannot clear")
    # strange!!!this will remove all the documents in Interviews whenever server restart.
    Applicants.remove({})
		# Interviews.remove({})
)

Applicants.find({}).observe
  added: ( applicant )->
    date = new Date()
    Applicants.update({_id:applicant._id},{$set:{createdAt:date.getTime()}})

Interviews.find({}).observe 
  added: ( interview ) ->
    if !interview.emailTime 
      date = new Date()
      # sendInterviewEmail( interview )
      Interviews.update({_id:interview._id},{$set: {emailTime: date.getTime()}} )

      # console.log "added", interview , date.getTime()



  
