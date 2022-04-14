# Estimated reading time: 3 minutes
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
A static class which is mainly needed for storing, creating and loading accounts, you can load all accounts in a session by saving them with getAuths and loading them with loadAuths

#### Create an account


[Go to Account section](#accounts)


To create an account you just need to use the MailTm.register method.

Params

- randomStringLength: will be used to generate a random password and/or username if not provided (10 is the default length)

- username: address' username (abcdqwerty@mail.tm, here, abcdqwerty is the username)
- password: account's password

- domain: address' domain, (like @mail.tm, must be [Domain](#domain) class), if not provided, a random one will be provided.

``await MailTm.register(password: 'ah yes password');``

Returns the ``Future<TMAccount>`` instance (Must be awaited as above!)

#### Loading an account

[Go to Account section](#accounts)

You can load an account by using the MailTm.login method

If you provide the id and it is present in the saved accounts it will return the saved account instance (Useful if you don't want to make another api request)

If you don't, and you provide address and password it will retrieve the account from the api's

If nothing is provided/the provided parameters are not valid and elseNew is true a new account will be returned (Default true)

If nothing is provided and elseNew is false, throws MailError with code -1 (Invalid arguments)

### Account class

##### Class members:

- ``String id, address, and password``: Account's id, address and password.
- ``DateTime createdAt``: The time when the account was created
- ``DateTime updatedAt``: The last time when the account messages were updated 
-  ``bool isDeleted``: Tells whenever the account is deleted
-  ``bool isDisabled ``: Tells whenever the account is disabled
-  ``int quota``: How many bytes can be stored in the messages
-  ``int used``: How many bytes are used from the quota


#### Get Account's messages

[Go to Message section](#messages)

You can use 

``await account.getMessages();``

Returns ``Future<List<Message>>`` (Must be awaited as above!)


#### Update the account instance

You can update the account instance (updatedAt, quota and used) by using:

``await account.update();``

Returns ``Future<TMAccount>`` (Must be awaited as above!) 

#### Delete the account

You can do so by doing 

``await account.delete()``

Returns ``Future<bool>`` (Must be awaited as above!) 

ACHTUNG: Be careful to not use the account after it has been deleted, or else errors will be thrown anytime you will try to use account's methods (Same thing for account's messages)

Only access members! 


#### Listen to messages

[Go to Message section](#messages)

You can do so by using

``account.messages.listen((){})``

account.messages returns a stream of ``Messages``

### Message class

##### Class members

  - ``String`` id: The unique identifier of the message (MailTm DB).

  - ``String`` accountId: The unique identifier of the account.

  - ``String`` msgid: The unique identifier of the message (Global, both the sender service and MailTm will know this).

  - ``String`` intro: The introduction of the message.

  - ``Map<String, dynamic>`` from: The sender of the message.

  - ``List<Map<String, dynamic>>`` to: The recipients of the message.

  - ``List<String>`` cc: The carbon copy recipients of the message.

  - ``List<String>`` bcc: The blind carbon copy recipients of the message.

  - ``String`` subject: The subject of the message.

  - ``bool`` seen: Whether the message has been seen.

  - ``bool`` flagged: Whether the message has been flagged.

  - ``bool`` isDeleted: Whether the message has been deleted.

  - ``List<String>`` verifications: The verifications of the message.

  - ``bool`` retention: If the message has arrived

  - ``DateTime`` retentionDate: The date of the message retention.

  - ``String`` text: The text of the message.

  - ``List<String>`` html: The HTML of the message.

  - ``bool`` hasAttachments: Whether the message has attachments.

  - ``List<Attachment>`` attachments: List of the message.

  - ``int`` size: The size of the message.

  - ``String`` url: The downloadUrl of the message.

  - ``DateTime`` createdAt: The date of the message creation.

  - ``DateTime`` updatedAt: When the message was seen

#### Download the message

As simple as:

``await message.download();``

Returns ``Future<MessageSource>`` (Must be awaited as above!)

#### Delete the message

Simply: 

``await message.delete();``

Returns ``Future<bool>`` (Must be awaited as above!)


#### Mark the message as seen:

You can do so by:

``await message.seen();``

Returns ``Future<bool>`` (Must be awaited as above!)


### Domain

#### Class members

  - ``String`` id: Domain's id

  - ``String`` domain: The domain (example: @mailtm.com)

  - ``bool`` isActive: If the domain is active

  - ``bool`` isPrivate: If the domain is private

  - ``DateTime`` createdAt: When the domain was created

  - ``DateTime`` updatedAt: When the domain was updated
  
#### Get all domains

You can do so by:

``await Domain.domains;``

Returns ``Future<List<Domain>>`` (Must be awaited as above!)

