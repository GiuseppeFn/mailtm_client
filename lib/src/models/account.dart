import 'dart:async';
import 'dart:convert';
import 'package:mercure_client/mercure_client.dart';

import '../mailtm.dart';
import '../requests.dart';
import 'message.dart';

accountFromApi(String address, String password, [String? token]) =>
    TMAccount._fromApi(address, password);

TMAccount accountFromJson(
        Map<String, dynamic> json, String password, String token) =>
    TMAccount._fromJson(json, password, token);

class TMAccount {
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

  TMAccount._({
    required this.id,
    required this.address,
    required this.password,
    required this.quota,
    required this.used,
    required this.isDisabled,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required Mercure mercure,
  }) : this._mercure = mercure;

  factory TMAccount._fromJson(Map<String, dynamic> json, String password,
          [String? token]) =>
      TMAccount._(
        id: json['id'],
        address: json['address'],
        password: password,
        quota: json['quota'],
        used: json['used'],
        isDisabled: json['isDisabled'],
        isDeleted: json['isDeleted'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        mercure: Mercure(
          url: 'https://mercure.mail.tm/.well-known/mercure',
          topics: ["/accounts/${json['id']}"],
          token: token,
        ),
      );

  /// Retrieves an account from MailTm API
  static Future<TMAccount> _fromApi(String address, String password) async {
    String token = await getToken(address, password);

    var data = await Requests.get<Map>(
      '/me',
      {'Authorization': 'Bearer $token'},
    ) as Map<String, dynamic>;

    TMAccount account = TMAccount._fromJson(data, password);

    auths[data['id']] = Auth(account, token);

    return account;
  }

  /// Deletes the account
  /// Be careful to not use an account after it is been deleted
  Future<bool> delete() async {
    bool r = await Requests.delete('/accounts/$id', auth);
    if (r) {
      auths.remove(id);
    }
    return r;
  }

  /// Returns all the account's messages
  Future<List<TMMessage>> getAllMessages() async {
    var response = await Requests.get<Map>('/messages?page=1', auth, false);
    int iterations = ((response["hydra:totalItems"] / 30) as double).ceil();
    if (iterations == 1) {
      return _getMessages(-1, response);
    }

    final List<TMMessage> result = [];
    for (int page = 2; page <= iterations; ++page) {
      result.addAll(await getMessages(page));
    }
    return result;
  }

  /// Private function, returns one page of the account messages
  /// Private as it accepts a response, to avoid multiple requests from the getAllMessages function
  Future<List<TMMessage>> _getMessages(int page, [Map? response]) async {
    response ??= await Requests.get<Map>('/messages?page=$page ', auth, false);
    final List<TMMessage> result = [];
    var member = response["hydra:member"];
    for (int i = 0; i < member.length; i++) {
      Map<String, dynamic> data = await Requests.get<Map>(
        '/messages/${member[i]['id']}',
        auth,
      ) as Map<String, dynamic>;
      data['intro'] = member[i]['intro'];
      result.add(messageFromJson(data));
    }
    return result;
  }

  /// Returns one page the account's messages (30 per page)
  Future<List<TMMessage>> getMessages([int page = 1]) => _getMessages(page);

  /// Updates the account instance and returns it
  Future<TMAccount> update() async {
    var data = await Requests.get<Map<String, dynamic>>('/me', auth);

    TMAccount account = TMAccount._fromJson(data, password);
    quota = account.quota;
    used = account.used;
    isDisabled = account.isDisabled;
    isDeleted = account.isDeleted;
    updatedAt = account.updatedAt;
    auths[id] = Auth(account, auths[id]!.token);
    return account;
  }

  /// A stream of [TMMessage]
  Stream<TMMessage> get messages {
    late StreamController<TMMessage> controller;
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
          Map<String, dynamic> data = await Requests.get<Map>(
            '/messages/${encodedData['id']}',
            auth,
          ) as Map<String, dynamic>;
          data['intro'] = encodedData['intro'];
          controller.add(messageFromJson(data));
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

    controller = StreamController<TMMessage>(
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
  Map<String, String> get auth => auths[id]!.headers;

  @override
  operator ==(Object other) =>
      identical(this, other) || other is TMAccount && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => address;
}
