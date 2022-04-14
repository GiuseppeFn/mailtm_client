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
  static Future<TMAccount> _fromApi(
    String address,
    String password, [
    String? token,
  ]) async {
    token ??= await getToken(address, password);
    var data = await Requests.get('/me', {'Authorization': 'Bearer $token'});
    return TMAccount._fromJson(data, password);
  }

  /// Deletes the account
  /// Be careful to not use an account after it is been deleted
  Future<bool> delete() async {
    bool r = await Requests.delete('/accounts/$id', auths[id]!.headers);
    if (r) {
      auths.remove(id);
    }
    return r;
  }

  /// Returns the account's messages
  Future<List<Message>> getMessages() async {
    var msgs = await Requests.get<List>('/messages', auths[id]!.headers);
    final List<Message> result = [];
    for (int i = 0; i < msgs.length; ++i) {
      Map<String, dynamic> data = await Requests.get<Map>(
        '/messages/${msgs[i]['id']}',
        auths[id]!.headers,
      ) as Map<String, dynamic>;
      data['intro'] = msgs[i]['intro'];
      result.add(messageFromJson(data));
    }
    return result;
  }

  /// Updates the account instance and returns it
  Future<TMAccount> update() async {
    var data = await Requests.get<Map<String, dynamic>>(
      '/me',
      auths[id]!.headers,
    );

    TMAccount account = TMAccount._fromJson(data, password);
    this.quota = account.quota;
    this.used = account.used;
    this.isDisabled = account.isDisabled;
    this.isDeleted = account.isDeleted;
    this.updatedAt = account.updatedAt;
    auths[id] = Auth(account, auths[id]!.token);
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
            return;
          }
          Map<String, dynamic> data = await Requests.get<Map>(
            '/messages/${encodedData['id']}',
            auths[id]!.headers,
          ) as Map<String, dynamic>;
          data['intro'] = encodedData['intro'];
          controller.add(messageFromJson(data));
        } catch (e) {
          controller.addError(e);
        }
      });
      Timer.periodic(Duration(seconds: 10), (timer) async {
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

  @override
  String toString() => address;
}
