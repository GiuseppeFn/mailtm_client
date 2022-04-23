part of mailtm;

/// MailTm client
abstract class MailClient<AccountT extends Account, DomainT extends Domain> {
  static final Map<String, TmAccount> _tmaccounts = {};
  static final Map<String, GwAccount> _gwaccounts = {};

  final MailService _service;

  final Requests _requests;

  const MailClient(MailService service, Requests requests)
      : _service = service,
        _requests = requests;

  Future<String> _getToken(String address, String password) async {
    var jwt = await _requests.post('/token', {
      'address': address,
      'password': password,
    });

    return jwt['token'];
  }

  Future<List<DomainT>> get domains =>
      (_service.isTm ? TmDomain.domains : GwDomain.domains)
          as Future<List<DomainT>>;

  /// Creates an account with the given [username], [password] and [domain]
  /// If they're not set, they'll be randomized with a [randomStringLength] length.
  Future<AccountT> register({
    String? username,
    String? password,
    DomainT? domain,
    int randomStringLength = 10,
  }) async {
    if (username == null || username.isEmpty) {
      username = randomString(randomStringLength);
    }
    if (password == null || password.isEmpty) {
      password = randomString(randomStringLength);
    }
    domain ??= (await domains).first;
    String address = username + '@${domain.domain}';

    var data = await _requests.post('/accounts', {
      'address': address,
      'password': password,
    });

    String token = await _getToken(data['address'], password);
    var account = Account._fromJson(data, password, token, _service);
    if (_service.isTm) {
      _tmaccounts[account.id] = account as TmAccount;
    } else {
      _gwaccounts[account.id] = account as GwAccount;
    }
    return account as AccountT;
  }

  /// Gets the account with the given [id] (Retrieved from [auths])
  /// If [auths] doesn't contain the id, then [address] and [password] are required
  /// to load the account from api
  /// if then, the account isn't retrieved and [elseNew] is true a new account is created
  /// or else, an exception is thrown.
  FutureOr<AccountT> login({
    String? id,
    String? address,
    String? password,
    bool elseNew: true,
  }) async {
    assert(
      id != null || (address != null && password != null) || elseNew,
      'Either id or address and password must be provided',
    );
    Map<String, Account> auths = _service.isTm ? _tmaccounts : _gwaccounts;
    if (id != null && auths.containsKey(id)) {
      return auths[id]! as AccountT;
    }

    if (address != null && password != null) {
      String token = await _getToken(address, password);
      return Account._fromApi(address, password, token, _service) as AccountT;
    }
    return register(username: address?.split('@')[0], password: password);
  }

  List<TmAccount> get __tmaccounts => _tmaccounts.values.toList();
  List<GwAccount> get __gwaccounts => _gwaccounts.values.toList();

  /// Gets the account string. To load them, you will simply need to use the loadAccounts function
  String get saveAccounts => _service == MailService.Tm
      ? jsonEncode(__tmaccounts)
      : jsonEncode(__gwaccounts);

  void loadAccounts(String json) {
    final List accounts = jsonDecode(json);
    for (final account in accounts) {
      Account _account = Account._fromJson(
        Map<String, dynamic>.from(account),
        account['password'],
        account['token'],
        _service,
      );
      if (_service.isTm) {
        _tmaccounts[account['id']] = _account as TmAccount;
      } else {
        _gwaccounts[account['id']] = _account as GwAccount;
      }
    }
  }
}

class MailTm extends MailClient<TmAccount, TmDomain> {
  MailTm() : super(MailService.Tm, tmrequests);

  List<Account> get accounts => super.__tmaccounts;
}

class MailGw extends MailClient<GwAccount, GwDomain> {
  MailGw() : super(MailService.Gw, gwrequests);
  List<Account> get accounts => super.__gwaccounts;
}
