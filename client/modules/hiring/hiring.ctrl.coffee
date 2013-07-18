angular.module( APP.angular.moduleName )
.controller('hiring', ['$scope','$meteor','$timeout', ($scope,$meteor, $timeout)->

  Deps.autorun( ()->
    if Meteor.user()
      $scope.$apply( ($scope)-> $scope.user = Meteor.user() )

    if $meteor("applicants").find({},{sort:{createdAt:-1}})?.length
      $scope.applicants = $meteor("applicants").find({},{sort:{createdAt:-1}})
      console.log "applicants", $scope.applicants

    console.log("applicants", $scope.applicants)
  );

  $scope.createApplicantAndInterviews = ( rawApplicant, rawInterviews )->
    console.log( "creating ", rawApplicant, rawInterviews )
    #for client sorting
    date = new Date()
    angular.extend rawApplicant, { createdAt : date.getTime() }
    applicant = angular.extend {}, rawApplicant, {"_id":$meteor("applicants").insert( rawApplicant, ( err, res )->
      return console.log("insert applicant error!") if err
      interviews = for rawInterview in rawInterviews
        angular.extend( {}, rawInterview, 
          {"_id": $meteor("interviews").insert(
            angular.extend( {}, rawInterview, {"applicant" : applicant }) 
          )}
        )
      console.log( "interviews", interviews )
      # console.log applicant
      # applicant.interviews = interviews;
      # applicant.save();
      $meteor("applicants").update({"_id":applicant._id}, {interviews:interviews})

     )}



  $scope.resetEverything = ()->
    Meteor.call("clear")

  $scope.genScoreClass = ( score )->
    return "" if not score = parseInt( score )
    if score > 0 then "success" else "important"


  $scope.sumScore = ( interviews ) ->
    total = 0
    return total if not interviews
    for interview in interviews
      if parseInt(interview.score)
        total += parseInt(interview.score) 
    total

  $scope.genResultClass = ( score )->
    switch result
      when "hire" then "success"
      when "reject" then "important"
      when "observe" then "waring"
      when "backup" then "info"
      else ""

])
.controller 'interview',['$scope','$stateParams','$meteor',( $scope, $stateParams, $meteor)->
  # console.log( $meteor("interviews").find({}),"aaaa" )
  # Deps.autorun ()->
  $scope.interview = $meteor("interviews").findOne({_id:$stateParams.interviewId})
  # $scope.interview = $meteor("interviews").find({})[0]  
  console.log( $scope.interview )

  $scope.updateInterview = () ->
    console.log( $scope.interview )
    $scope.interview.save()

    applicant = $meteor("applicants").findOne({_id:$scope.interview.applicant._id})
    interviewCache = _.find( applicant.interviews, ( interview )->
        interview._id == $scope.interview._id
      )


    if interviewCache 
      updateVal = _.pick( $scope.interview, "score", "comment")
      angular.extend interviewCache, updateVal 
      console.log applicant 
      applicant.save()
    else 
      console.log "interview not find."
    # console.log( updateVal )

    # console.log $meteor("interviews").update({_id:$scope.interview._id},{$set: updateVal});

  ]