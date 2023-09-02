// Login Exceptions
class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

// Register Exceptions
class WeakPasswordAuthException implements Exception {}

class EmailAlreadyExistsAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

// generic Exceptions
class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
