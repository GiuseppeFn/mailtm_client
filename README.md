# Index
1. [Introduction](#Introduction)
1. [Example](#example)
1. [Usage](#usage)

## Introduction
This package is a simple but complete mail.tm api wrapper, you can use this to save and manage your accounts, as well read all your temporary emails.

## Example
See in [the example folder](example/)

## Documentation

### MailTm class


#### Initiation

To start, you need to instanciate the client, it can accept 2 parameters, ``canSave``, a bool that tells the class if it can save the accounts that will be created.

And ``customDb``, a File, that, if ``canSave`` is true, will be used as custom db to store files, or else it will use a defaut directory ``%home%/.dartmailtm``

``MailTm client = await MailTm.init(canSave: false);``

If you don't need a database, and you don't want to use async/await, you can just

``MailTm(canSave: false)``


#### Create an account


[Go to Account section](#accounts)

Creates an account, if you want, you can also provide a password! (Or not)

``await client.createAccount(password:'ah yes password');``

Returns the ``Account`` instance


#### Save an account to the local database

Saves the ``Account`` instance to the database

``client.saveAccount(account);``

Returns null


#### Load an account

You can load an account from the local database (you can specify the index) by doing this

``await client.loadAccount(index: 4);``

or the id, address and password, and load from API

``await client.loadAccount(id:'',address:'',password:'');``

Returns the loaded ``Account``


#### Load all the account

``await client.loadAccounts``

Returns ``List<Account>``


#### Delete an account

You can delete an account by using

``await client.deleteAccount(account);``

You could also use ``await account.delete()`` if you don't want to delete it from the local database. 

Returns ``Map<String, bool>``, with two keys: ``isSuccessfulApi``, ``isSuccessfulDb``.

``isSuccessfulDb`` will be ``false`` if canSave is ``false``


### Account class

##### Class members:

- ``String id, address, and password``:Account's id, address and password.
- ``DateTime _createdAt``:The time when the account was created
- ``DateTime _updatedAt``:The last time when the account messages were updated 
-  ``bool _isDeleted_``:Tells whenever the account is deleted
-  ``bool isDisabled ``:Tells whenever the account is disabled
-  ``int quota``:How many bytes can be stored in the messages
-  ``int used``:How many bytes are used from the quota


#### Get Account's messages

[Go to Message section](#messages)

You can use 

``await account.getMessages();``

And eventually provide a page argument.

Returns ``List<Message>``


#### Update the account instance

You can update the account instance (For example, updatedAt, etc.) by using:

``await account.update(updateInstance: true);``

If updateInstance is false you can get the new updated value from the returned ``Account`` instance

Returns ``Account``

#### Listen to messages

You can do so by using

``account.messages.listen((){})``

account.messages returns a stream of ``Message``

### Message class

##### Class members

- ``String id, subject, intro, text``:The message's id, subject, intro and text!
- ``Map from``:Who sent the message. Provided as {address:'',name:''}
- ``List to``:All the receivers of the message, as a ``List`` of ``Map``s
- ``List html``:The html. Pretty useless, if you don't want to open it in a web page.
- ``Map data``:Message attachments, like files.

#### Open the message in a web page

You can open the message in a web page by doing:

``message.openWeb()``

Returns null.
