
// login exceptions
class UserNotFoundException implements Exception {}

class WrongPasswordException implements Exception {}

// register exceptions
class WeakPasswordException implements Exception {}

class EmailAlreadyInUseException implements Exception {}

class InvalidEmailException implements Exception {}

// Generics Auth Exceptions
class GenericAuthException implements Exception {}

class UserNotLoggedInException implements Exception {}