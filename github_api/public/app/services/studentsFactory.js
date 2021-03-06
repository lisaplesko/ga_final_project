gaApp.factory('studentsFactory', ['$http', '$cacheFactory', function ($http, $cacheFactory) {

  var factory = {};

  factory.getStudents = function() {
    // Return the promise, hand off to controller
    return $http.get('/students', { cache: true });
  };

  factory.getStudent = function(studentId) {
    return $http.get('/students/' + studentId, { cache: true });
  };

  factory.getStudentLanguages = function(studentId) {
    return $http.get('/students/' + studentId + '/total_language', { cache: true });
  };

  return factory;

}]);


