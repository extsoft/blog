---
layout: post
title: "Establishing lazy connections in Python"
description: "Shows practical examples how to implement lazy connecting using different Python approaches."
tags: [python, architecture, magic methods]
comments: true
---
In [the previous post]({% post_url 2018-01-02-safely-destroying-connections-in-python %}), we looked at the ways how to close connection safely. But there still is one more task: how to connect to a source on in the case when the interaction will happen? This task appears because a lot of connections are designed in a way that you have to `connect` to a source before start using the connection. Let's see how lazy connection can be implemented.

First of all, let's define some connection, for instance, to a spaceship.

```python
class Spaceship:
    def __init__(self):
        self._name = 'Enterprise'

    def connect(self, user: str, pasw: str):
        """ Connects to the spaceship with a given credentials. """
        print('Connect to {} with {}:{}'.format(self._name, user, pasw))

    def execute(self, command: str):
        """ Executes given command using the spaceship.

        :param command: a command to execute
        """
        print('{} executes "{}" command'.format(self._name, command))

    def close(self):
        """ Closes the connection. """
        print('Close connection to {}'.format(self._name))
```

Then, let's design an interface for a connection which will connect to a source automatically. It'll be an adapter for the `Spaceship` connection.
```python
from abc import ABC, abstractmethod


class Connection(ABC):
    """ The connection which can automatically connect to a source before executing a command.
    
    The connection has to be established only once before executions first command.
    """
    
    @abstractmethod
    def execute(self, command: str):
        """ Executes a command on the connection.

        :param command: a command to execute
        """
        pass

    @abstractmethod
    def __del__(self):
        """ Destroys connection automatically. """
        pass
```

We're ready to implement the first obvious approach. Let's do it...

Lazy loading with internal method
=================================
```python
class Connection1(Connection):
    def __init__(self, user: str, pasw: str):
        self._conn = Spaceship()
        self._user = user
        self._pass = pasw
        self._connected = False

    def _connection(self) -> Spaceship:
        if not self._connected:
            self._conn.connect(self._user, self._pass)
            self._connected = True
        return self._conn

    def execute(self, command: str):
        self._connection().execute(command)

    def __del__(self):
        if self._conn:
            self._conn.close()
      
        
conn = Connection1('root', '1234f')
conn.execute('first')
conn.execute('second')

# Output:
# Connect to Enterprise with root:1234f
# Enterprise executes "first" command
# Enterprise executes "second" command
# Close connection to Enterprise
```

Once we call `execute` method, `self._connection()` will be executed to provide the connected connection.

This implementation has two main disadvantages:
1. it is mutable because of `self._connected`
2. it is ambiguous - both `self._conn` and `self._connection()` provide the connection and it's not obvious which one has to be used in `__del__`. 

How to improve this?

Lazy loading through attribute resolving
========================================
```python
class Connection2(Connection):
    def __init__(self, user: str, pasw: str):
        self._user = user
        self._pass = pasw

    def execute(self, command: str):
        self._conn.execute(command)

    def __getattr__(self, name):
        if name == '_conn':
            self._conn = Spaceship()
            self._conn.connect(self._user, self._pass)
            return self._conn
        raise AttributeError(name)

    def __del__(self):
        if self._conn:
            self._conn.close()


conn = Connection2('root', '1234f')
conn.execute('first')
conn.execute('second')
    
# Output:
# Connect to Enterprise with root:1234f
# Enterprise executes "first" command
# Enterprise executes "second" command
# Close connection to Enterprise
```
Once we try to access a `_conn` attribute of the connection, the `__getattr__` method will be invoked. And there is a logic of establishing connection inside the method. Next time when `self._conn` will be invoked, the already defined `_conn` will be returned using `__getattribute__` method (`__getattr__` will be called if `__getattribute__` throws `AttributeError` exception). 

The main disadvantage of the implementation is that a logic of constructing object is located in two places: `__init__` and `__getattr__` methods.

How to improve this?

Lazy loading with wrapper function
==================================
```python
from functools import lru_cache


class Connection3(Connection):
    def __init__(self, user: str, pasw: str):
        @lru_cache(maxsize=1)
        def c() -> Spaceship:
            conn = Spaceship()
            conn.connect(user, pasw)
            return conn

        self._conn = c

    def execute(self, command: str):
        self._conn().execute(command)

    def __del__(self):
        if self._conn.cache_info().hits > 0:
            self._conn().close()


conn = Connection3('root', '1234f')
conn.execute('first')
conn.execute('second')

# Output:
# Connect to Enterprise with root:1234f
# Enterprise executes "first" command
# Enterprise executes "second" command
# Close connection to Enterprise
```

`lru_cache` decorator allows to cache first call of a function and return the result (a connection) any time the function will be invoked again.

The `Connection3` object encapsulates only one attribute (`self._conn`) which is a function. The function call will give back an established connection.

Conclusion
==========
Although the two latest options look not very usual, they are definitely better than first one. I personally prefer the last one. Which one do you like more?
 
**Further reading**
- [https://docs.python.org/3.4/reference/datamodel.html?highlight=getattr#object.__getattribute__](https://docs.python.org/3.4/reference/datamodel.html?highlight=getattr#object.__getattribute__)
- [https://docs.python.org/3.4/reference/datamodel.html?highlight=getattr#object.__getattr__](https://docs.python.org/3.4/reference/datamodel.html?highlight=getattr#object.__getattr__)
