import 'dart:io';
import 'dart:convert' show jsonEncode, jsonDecode;
import 'dart:math' show Random;
import 'package:path/path.dart' show join;
import 'package:username_gen/username_gen.dart';

import 'account.dart';
import 'requests.dart';
import 'utilities.dart';
import 'domain.dart';

class MailTm {
  static final Random _rand = Random.secure();

  ///[MailTm] api domain
  static String apiAddress = 'https://api.mail.tm';

  ///Default db instance
  static final File db = File(join(homeDir, '.dartmailtm'));

  ///The database used to store accounts
  final File customDb;

  ///If [canSave] is true, the [MailTm] instance will store accounts on either
  ///[db] or [customDb]
  final bool canSave;

  MailTm._(this.customDb) : this.canSave = true;

  MailTm({File? customDb, this.canSave: true})
      : this.customDb = customDb ?? db {
    if (!canSave) {
      return;
    }
    this.customDb.createSync(recursive: true);
  }

  ///Init a new [MailTm] instance
  static Future<MailTm> init({File? customDb, bool canSave: true}) async {
    if (!canSave) {
      return MailTm(canSave: false);
    }
    if (customDb != null && !(await customDb.exists())) {
      await customDb.create(recursive: true);
    }

    if (!(await db.exists())) {
      await db.create(recursive: true);
    }
    return MailTm._(customDb ?? db);
  }

  ///Gets a list of domains.
  static Future<List<Domain>> get getDomainsList async {
    var response = await Requests.getRequest('$apiAddress/domains');
    final List<Domain> res = [];
    response['hydra:member'].forEach(
      (value) => res.add(Domain.fromJson(value)),
    );
    return res;
  }

  ///Creates a new account on MailTm and parses it as [Account], then saves it
  ///using [saveAccount].
  Future<Account> createAccount({String? password}) async {
    String username = UsernameGen().generate().toLowerCase();
    List<Domain> domains = await getDomainsList;
    String domain = domains[_rand.nextInt(domains.length)].domain;
    String address = '$username@$domain';
    password ??= generate_password(6);
    Map response = await Requests.postRequestAccount(
      'accounts',
      address,
      password,
      error: 'Could not get an account.',
    );
    Account account = await Account.create(
      id: response['id'],
      address: response['address'],
      password: password,
      quota: response['quota'],
      used: response['used'],
      isDisabled: response['isDisabled'],
      isDeleted: response['isDeleted'],
      createdAt: DateTime.parse(response['createdAt']),
      updatedAt: DateTime.parse(response['updatedAt']),
    );
    saveAccount(account);
    return account;
  }

  ///Saves a new [Account] to the db, if [canSave] is true
  void saveAccount(Account account) async {
    if (!canSave) {
      return;
    }
    String data = (await customDb.readAsString()).trim();
    List accounts = (data != '' ? jsonDecode(data) : [])..add(account.toJson());
    await customDb.writeAsString(jsonEncode(accounts));
    return;
  }

  ///Loads all the accounts from the [customDb] or [db]
  ///If [canSave] is false, an exception is thrown.
  Future<List<Account>> get loadAccounts async {
    if (!canSave) {
      throw Exception('Cannot load accounts without the "Save" feature.');
    }
    List<dynamic> accounts = jsonDecode(await customDb.readAsString());
    List<Account> result = [];
    for (var account in accounts) {
      result.add(Account.fromJson(account));
    }
    return result;
  }

  ///Deletes the account by doing a DELETE request to the API
  Future<Map<String, bool>> deleteAccount(Account account) async {
    bool isSuccessfulApi = await account.delete();
    bool isSuccessfulDb = false;
    if (isSuccessfulApi && canSave) {
      List<Account> accounts = await loadAccounts;
      accounts..removeWhere((i) => i.id == account.id);
      try {
        await customDb.writeAsString(jsonEncode(accounts));
        isSuccessfulDb = true;
      } catch (e) {}
    }

    return {'api': isSuccessfulApi, 'db': isSuccessfulDb};
  }

  ///Loads the [Account] with the given [index] from [customDb] or [db].
  ///If [canSave] is false, an exception is thrown.
  Future<Account> loadAccount({
    int index: 0,
    String? id,
    String? address,
    String? password,
  }) async {
    final bool forceApi = id != null && address != null && password != null;
    assert(!canSave && !forceApi);
    assert((!canSave || forceApi) &&
        (id != null && address != null && password != null));
    if (!canSave || forceApi) {
      Account account = await Account.create(
        id: id!,
        address: address!,
        password: password!,
      );
      return account.update();
    }
    List<dynamic> data = jsonDecode(await customDb.readAsString());

    return Account.fromJson(data[index]);
  }

  @override
  String toString() {
    return '''MailTm(
      apiAddress: $apiAddress, 
      canSave: $canSave
)''';
  }
}
