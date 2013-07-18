angular.module( APP.angular.moduleName )
.directive "ustackAtUser", ( $meteor, $compile ) ->
    restrict : 'A'
    replace : true
    scope : true
    template : 
      """
      <div class="UstackAtUser" ng-init="$_related=[]">
        <div class="relatedUsers" ng-show="$_related.length" >
          <div ng-repeat="user in $_related" class="relatedUser" ng-click="select(user)">{{getName(user)}}</div>
        </div>
        <div class="input"></div>
      </div> 
      """
    link : ( $scope, $elem, $attrs ) ->
      options = angular.extend({
          multiple : false,
          id : "_id",
          nameField : 'profile.name',
        } , JSON.parse( $attrs['ustackAtUser'] || "{}" ) )

      $scope.getName = getName = ( user )->
        ns = options.nameField.split(".")
        ref = user
        for field, i in ns
          if ref?[field] then ref= ref[field]
        ref || ''

      getChildByName = ( obj, name )->
        ns = name.split(".")
        ref = obj
        for field, i in ns
          return ref?[field] if i == ns.length - 1 
          if ref?[field] then ref= ref[field]
        res


      Object.defineProperty $scope, '$_currentSelected',
        $__currentSelected : {}
        set :( user )->
          this.$__currentSelected = user
        get :()->
          return getName(this.$__currentSelected)

      $scope.$_currentSelected = getChildByName( $scope.$parent, $attrs['ngModel'] )

      # console.log( "here the selected", $scope.$_currentSelected, $scope )
      $input = $compile("<input type='text' ng-model='$_currentSelected' placeholder='#{$attrs['placeholder']}' ng-disabled='#{$attrs['ngDisabled']}'/>")($scope)

      showOptions = _.debounce( ()->
        nameFrag = $input.val()
        Deps.autorun( ()->
          reg = new RegExp ".*"+nameFrag+".*"
          related = Meteor.users.find( "profile.name": reg ).fetch()
          if related.length?
            $scope.$_related = related;
            $scope.$digest()

        )
      , 1000 )

      $input.on "input", showOptions
      $elem.find(".input").append($input)

      $scope.select = ( user ) ->
        result = parseToResult user, options
        if options.multiple
          $scope.$parent[$attrs['ngModel']] = []
          $scope.$parent[$attrs['ngModel']].push result
        else
          setChildByName $scope.$parent, $attrs['ngModel'], result 

        console.log "selected" , $scope.$parent
        $scope.$_related = []
        $scope.$_currentSelected = user

      setChildByName = ( obj, name, val )->
        ns = name.split(".")
        ref = obj
        for field, i in ns
          return ref[field] = val if i == ns.length - 1 
          if ref?[field] then ref= ref[field]
        res


      

      parseToResult = ( user, options ) ->
        user[options.id] if options.id 

        if options.fields 
          userNew = {}
          options.fields.map ( field ) -> userNew[field] = user[field] 
          userNew
        
        user
