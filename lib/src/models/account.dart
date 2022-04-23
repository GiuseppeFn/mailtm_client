part of mailtm;

abstract class Account {
  /// Account's id.
  final String id;

  /// Account's address.
  final String address;

  /// Account's password.
  final String password;

  /// Account's quota (To store message data).
  int quota;

  /// Account's quota used.
  int used;

  /// Whether the account is active or not.
  bool isDisabled;

  /// Whenever the account is deleted.
  bool isDeleted;

  /// Account creation date
  final DateTime createdAt;

  /// Account update date
  DateTime updatedAt;

  final Mercure _mercure;

  final String _token;

  final Requests _requests;

  Account._({
    required this.id,
    required this.address,
    required this.password,
    required this.quota,
    required this.used,
    required this.isDisabled,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required Requests requests,
    required Mercure mercure,
    required String token,
  })  : this._mercure = mercure,
        this._token = token,
        this._requests = requests;

  factory Account._fromJson(
    Map<String, dynamic> json,
    String password,
    String token,
    MailService service,
  ) {
    if (service.isTm) {
      return TmAccount._fromJson(json, password, token);
    }
    return GwAccount._fromJson(json, password, token);
  }

  /// Retrieves an account from MailTm API
  static Future<Account> _fromApi(
    String address,
    String password,
    String token,
    MailService service,
  ) async {
    final Requests requests = service.isTm ? tmrequests : gwrequests;
    var data = await requests.get<Map>(
      '/me',
      {'Authorization': 'Bearer $token'},
    ) as Map<String, dynamic>;
    return Account._fromJson(data, password, token, service);
  }

  /// Returns all the account's messages
  Future<List<Message>> getAllMessages() async {
    var response = await _requests.get<Map>('/messages?page=1', _auth, false);
    int iterations = ((response["hydra:totalItems"] / 30) as double).ceil();
    if (iterations == 1) {
      return _getMessages(-1, response);
    }

    final List<Message> result = [];
    for (int page = 2; page <= iterations; ++page) {
      result.addAll(await getMessages(page));
    }
    return result;
  }

  /// Deletes the account
  /// Be careful to not use an account after it is been deleted
  Future<bool> delete() async {
    bool r = await _requests.delete('/accounts/$id', _auth);
    if (r) {
      if (this.runtimeType == TmAccount) {
        MailClient._tmaccounts.remove(this);
      } else {
        MailClient._gwaccounts.remove(this);
      }
    }
    return r;
  }

  /// Private function, returns one page of the account messages
  /// Private as it accepts a response, to avoid multiple requests from the getAllMessages function
  Future<List<Message>> _getMessages(int page, [Map? response]) async {
    response ??=
        await _requests.get<Map>('/messages?page=$page ', _auth, false);
    final List<Message> result = [];
    var member = response["hydra:member"];
    for (int i = 0; i < member.length; i++) {
      Map<String, dynamic> data = await _requests.get<Map>(
        '/messages/${member[i]['id']}',
        _auth,
      ) as Map<String, dynamic>;
      data['intro'] = member[i]['intro'];
      result.add(Message._fromJson(
        data,
        _token,
        runtimeType == TmAccount ? MailService.Tm : MailService.Gw,
      ));
    }
    return result;
  }

  /// Returns one page the account's messages (30 per page)
  Future<List<Message>> getMessages([int page = 1]) => _getMessages(page);

  /// Updates the account instance and returns it
  Future<Account> update() async {
    var data = await _requests.get<Map<String, dynamic>>('/me', _auth);

    Account account = Account._fromJson(
      data,
      password,
      _token,
      runtimeType == TmAccount ? MailService.Tm : MailService.Gw,
    );
    quota = account.quota;
    used = account.used;
    isDisabled = account.isDisabled;
    isDeleted = account.isDeleted;
    updatedAt = account.updatedAt;
    return account;
  }

  /// A stream of [Message]
  Stream<Message> get messages {
    late StreamController<Message> controller;
    bool canYield = true;

    void tick() async {
      var subscription = _mercure.listen((event) async {
        if (controller.isClosed) {
          return;
        }
        try {
          if (!canYield) return;
          var encodedData = jsonDecode(event.data);
          if (encodedData['@type'] == 'Account') {
            quota = encodedData['quota'];
            used = encodedData['used'];
            isDisabled = encodedData['isDisabled'];
            isDeleted = encodedData['isDeleted'];
            updatedAt = DateTime.parse(encodedData['updatedAt']);
            return;
          }
          Map<String, dynamic> data = await _requests.get<Map>(
            '/messages/${encodedData['id']}',
            _auth,
          ) as Map<String, dynamic>;
          data['intro'] = encodedData['intro'];
          controller.add(Message._fromJson(
            data,
            _token,
            runtimeType == TmAccount ? MailService.Tm : MailService.Gw,
          ));
        } catch (e) {
          controller.addError(e);
        }
      });
      Timer.periodic(Duration(seconds: 3), (timer) async {
        if (controller.isClosed) {
          timer.cancel();
          await subscription.cancel();
        }
      });
    }

    tick();
    void listen() {
      canYield = true;
    }

    void pause() {
      canYield = false;
    }

    Future<void> cancel() async {
      canYield = false;
      await controller.close();
      return;
    }

    controller = StreamController<Message>(
      onListen: listen,
      onPause: pause,
      onResume: listen,
      onCancel: cancel,
    );

    return controller.stream;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'address': address,
        'password': password,
        'quota': quota,
        'used': used,
        'isDisabled': isDisabled,
        'isDeleted': isDeleted,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  Map<String, String> get _auth => {'Authorization': 'Bearer $_token'};

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      (other is Account && id == other.id) ||
      (other is String && id == other);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => address;
}

class TmAccount extends Account {
  TmAccount._fromJson(Map<String, dynamic> json, String password, String token)
      : super._(
          id: json['id'],
          address: json['address'],
          password: password,
          quota: json['quota'],
          used: json['used'],
          isDisabled: json['isDisabled'],
          isDeleted: json['isDeleted'],
          createdAt: DateTime.parse(json['createdAt']),
          updatedAt: DateTime.parse(json['updatedAt']),
          token: token,
          mercure: Mercure(
            url: 'https://mercure.mail.tm/.well-known/mercure',
            topics: ["/accounts/${json['id']}"],
            token: token,
          ),
          requests: tmrequests,
        );
}

class GwAccount extends Account {
  GwAccount._fromJson(Map<String, dynamic> json, String password, String token)
      : super._(
          id: json['id'],
          address: json['address'],
          password: password,
          quota: json['quota'],
          used: json['used'],
          isDisabled: json['isDisabled'],
          isDeleted: json['isDeleted'],
          createdAt: DateTime.parse(json['createdAt']),
          updatedAt: DateTime.parse(json['updatedAt']),
          token: token,
          mercure: Mercure(
            url: 'https://api.mail.gw/.well-known/mercure',
            topics: ["/accounts/${json['id']}"],
            token: token,
          ),
          requests: gwrequests,
        );
}
