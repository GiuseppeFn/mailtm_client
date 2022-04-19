import 'dart:async';
import 'dart:math';

import '/src/models/account.dart';
import '/src/models/domain.dart';
import '/src/requests.dart';

/// All the usable characters for a random username/password
const String _charset =
    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

/// Generate a random string of [length] characters
String randomString(int length) {
  final _random = Random.secure();
  final _codeUnits = List<int>.generate(
    length,
    (index) => _charset.codeUnitAt(_random.nextInt(_charset.length)),
  );
  return String.fromCharCodes(_codeUnits);
}

/// Gets the token for the given [address] and [password] from API
Future<String> getToken(String address, String password) async {
  var jwt = await Requests.post('/token', {
    'address': address,
    'password': password,
  });

  return jwt['token'];
}

/// A map which contains all the accounts and authorizations
Map<String, Auth> auths = {};

/// MailTm client (constant)
class MailTm {
  MailTm._();

  /// Creates an account with the given [username], [password] and [domain]
  /// If they're not set, they'll be randomized with a [randomStringLength] length.
  static Future<TMAccount> register({
    String? username,
    String? password,
    Domain? domain,
    int randomStringLength = 10,
  }) async {
    if (username == null || username.isEmpty) {
      username = randomString(randomStringLength);
    }
    if (password == null || password.isEmpty) {
      password = randomString(randomStringLength);
    }
    domain ??= (await Domain.domains).first;
    String address = username + '@${domain.domain}';

    var data = await Requests.post('/accounts', {
      'address': address,
      'password': password,
    });

    String token = await getToken(data['address'], password);
    var account = accountFromJson(data, password, token);
    auths[data['id']] = Auth(account, token);
    return account;
  }

  /// Gets the account with the given [id] (Retrieved from [auths])
  /// If [auths] doesn't contain the id, then [address] and [password] are required
  /// to load the account from api
  /// if then, the account isn't retrieved and [elseNew] is true a new account is created
  /// or else, an exception is thrown.
  static FutureOr<TMAccount> login({
    String? id,
    String? address,
    String? password,
    bool elseNew: true,
  }) async {
    assert(
      id != null || (address != null && password != null) || elseNew,
      'Either id or address and password must be provided',
    );
    if (id != null && auths.containsKey(id)) {
      return auths[id]!.account;
    }
    TMAccount account;
    if (address != null && password != null) {
      String token = await getToken(address, password);
      account = await accountFromApi(address, password);
      auths[account.id] = Auth(account, token);
      return account;
    }
    if (elseNew) {
      address ??= '';
      account =
          await register(username: address.split('@')[0], password: password);
      String token = await getToken(account.address, account.password);
      auths[account.id] = Auth(account, token);
      return account;
    } else {
      throw MailException('Invalid arguments', -1);
    }
  }

  static List<TMAccount> get accounts =>
      auths.values.map((auth) => auth.account).toList();

  /// Gets the auths Map.
  static Map<String, Map<String, dynamic>> get getAuths {
    return auths.map((key, value) => MapEntry(key, value.toJson()));
  }

  static void loadAuths(Map<String, dynamic> _auths) {
    for (final String id in _auths.keys) {
      auths[id] = Auth(
        accountFromJson(
          _auths[id]['account'],
          _auths[id]['account']['password'],
          _auths[id]['token'],
        ),
        _auths[id]['token'],
      );
    }
  }
}

/// Class for store accounts and relative token
class Auth {
  TMAccount account;
  String token;

  Auth(this.account, this.token);

  Map<String, String> get headers => {'Authorization': 'Bearer $token'};
  Map<String, dynamic> toJson() =>
      {'account': account.toJson(), 'token': token};
  @override
  String toString() => '{"account": $account, "token": "$token}';
}
