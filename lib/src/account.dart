// ignore_for_file: invalid_use_of_protected_member
import 'dart:async';

import 'requests.dart';
import 'message.dart';

class Account {
  final String id, address, password;
  DateTime _createdAt, _updatedAt;
  bool _isDisabled, _isDeleted;
  int _quota, _used;
  Map<String, String> _authHeaders;

  int get quota => _quota;
  int get used => _used;
  bool get isDisabled => _isDisabled;
  bool get isDeleted => _isDeleted;
  DateTime get createdAt => _createdAt;
  DateTime get updatedAt => _updatedAt;

  Account._({
    required this.id,
    required this.address,
    required this.password,
    required isDisabled,
    required isDeleted,
    required int quota,
    required int used,
    required createdAt,
    required updatedAt,
    required authHeaders,
  })  : _isDisabled = isDisabled,
        _isDeleted = isDeleted,
        _quota = quota,
        _used = used,
        _createdAt = createdAt,
        _updatedAt = updatedAt,
        _authHeaders = authHeaders;

  ///Creates a new account.
  static Future<Account> create({
    required String id,
    required String address,
    required String password,
    int quota: 0,
    int used: 0,
    bool isDisabled: false,
    bool isDeleted: false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) async {
    createdAt ??= DateTime.now();
    updatedAt ??= DateTime.now();
    Map jwt = await Requests.postRequestAccount('token', address, password);

    return Account._(
      id: id,
      address: address,
      password: password,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDisabled: isDisabled,
      isDeleted: isDeleted,
      quota: quota,
      used: used,
      authHeaders: {
        'Authorization': 'Bearer ${jwt["token"]}',
        'Accept': 'application/ld+json',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<bool> delete() async {
    if (_authHeaders.isEmpty)
      await this.update(updateInstance: true, setAuth: true);

    return (await Requests.delete('accounts/$id', _authHeaders)) == 204;
  }

  ///Gets the messages of the account.
  Future<List<Message>> getMessages({int page: 1}) async {
    var response =
        await Requests.getRequest('messages', params: {'page': page});
    final List<Message> messages = [];
    for (var messageData in response['hydra:member']) {
      var message = await Requests.getRequest('messages/${messageData["id"]}');
      messages.add(Message.fromRequests(messageData, message));
    }
    return messages;
  }

  ///Get request using current [Account]'s [_authHeaders]
  ///The request is made to the [endpoint] with the [params]
  ///[error] is the error message to throw if the request fails
  ///[codes] is the list of status codes to accept

  Future<Account> update({
    bool updateInstance: false,
    bool setAuth: false,
  }) async {
    if (setAuth || _authHeaders.isEmpty) {
      Map jwt = await Requests.postRequestAccount('token', address, password);

      this._authHeaders = {
        'Authorization': 'Bearer ${jwt["token"]}',
        'Accept': 'application/ld+json',
        'Content-Type': 'application/json',
      };
    }
    var response = await Requests.getRequest(
      'accounts/$id',
      params: {'id': id},
      error: 'Could not update the account.',
    );

    this._quota = response['quota'];
    this._used = response['used'];
    this._isDeleted = response['isDeleted'];
    this._isDisabled = response['isDisabled'];
    this._updatedAt = DateTime.parse(response['updatedAt']);

    return this.copyWith(
      quota: response['quota'],
      used: response['used'],
      isDeleted: response['isDeleted'],
      isDisabled: response['isDisabled'],
      createdAt: DateTime.parse(response['createdAt']),
      updatedAt: DateTime.parse(response['updatedAt']),
    );
  }

  //copyWith function
  Account copyWith({
    int? quota,
    int? used,
    bool? isDisabled,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account._(
      id: id,
      address: address,
      password: password,
      quota: quota ?? this.quota,
      used: used ?? this.used,
      isDisabled: isDisabled ?? this.isDisabled,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authHeaders: this._authHeaders,
    );
  }

  ///Converts this [Account] to a [Map] object
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

  ///Returns [Account] from a [Map]
  factory Account.fromJson(Map<String, dynamic> json) => Account._(
        id: json['id'],
        address: json['address'],
        password: json['password'],
        isDisabled: json['isDisabled'],
        isDeleted: json['isDeleted'],
        quota: json['quota'],
        used: json['used'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        authHeaders: {},
      );


  ///A stream of messages.
  Stream<Message> get messages async* {
    int start;
    while (true) {
      start = (await getMessages()).length;
      while ((await getMessages()).length == start) {
        await Future.delayed(Duration(seconds: 3));
      }
      yield (await getMessages()).first;
    }
  }

  @override
  String toString() =>
      'Account{id: $id, address: $address, password: $password}';
}
