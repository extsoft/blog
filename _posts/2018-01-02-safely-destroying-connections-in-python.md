---
layout: post
title: "Safely destroying connections in Python"
description: "Show practical example how to close safely connection using different Python approaches."
tags: [python, architecture, magic methods]
comments: true
modified: 2020-03-06
---

Writing automated tests, we often have to interact with a database or a linux host. Different libraries allow us connecting to desired targets and interacting with them. Usually, a connection has to be created first, then it's possible to implement any desired interactions, and the connection has to be destroyed in the end of the interactions. Looks like everything is very logical and simple. But why there are so many errors in the implementations?

> Note! The examples below work on the Python 3.4. Please double check the documentation for your version of the Python.

First of all, let's prepare an example using [paramiko](http://www.paramiko.org).

```python 
import paramiko

client = paramiko.SSHClient()
client.connect('ssh.example.com', username='strongbad', password='thecheat')
# some interactions
client.exec_command('...')
client.close()
```

As you could say, the code above isn't very good. This is because if something bad happens in the interactions section, then `client` won't be closed properly. And there are a couple of ways to improve the code.
 
`try / finally`
==============
The most obvious way is to use `try / finally` statement. Let's see how it looks.
```python
import paramiko

client = paramiko.SSHClient()
client.connect('ssh.example.com', username='strongbad', password='thecheat')
try:
    # some interactions
    client.exec_command('...')
finally:
    client.close()
```

`finally` allows closing connection independently of interactions section. But this is too verbose - you need to reuse at least 3 lines of code each time you're working with a connection. And, of course, you have to remember to use `try / finally`.

Context manager
===============
A context manager allows reducing the boilerplate code to one line. How does it look like?
First of all, need to create an object which will behave like a context manager. Then, use this object when executing `with` statement.
```python
import paramiko


class SshConnection:
    """ The class is an adapter of a **paramiko.SSHClient**. """
    
    def __init__(self):
        self._client = paramiko.SSHClient()
    
    def __enter__(self):
        """ Enter the runtime context related to this object.
        
        In other words, an instance of this object has to be returned as it'll be used as a SSH connection.
        """
        self._client.connect('ssh.example.com', username='strongbad', password='thecheat')
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """ Exit the runtime context related to this object.
        
        The connection has to be closed here.
        """
        if self._client:
            self._client.close()
            
    def output(self, command, timeout=60):
        return self._client.exec_command(command, timeout=timeout)

with SshConnection() as connection:
    # some interactions
    connection.output('...')
```

The context manager reduces the boilerplate code to one line, but it (boilerplate) still exists.  And, of course, you have to create some instances only using `with`. 

Object finalizer
================
Instance finalization (destruction) happens when instance's reference count reaches zero. And it's possible to customize it with an overriding of `__del__` method of an object.
```python
import paramiko


class SshConnection:
    """ The class is an adapter of a **paramiko.SSHClient**. """
    
    def __init__(self):
        self._client = paramiko.SSHClient()
        self._client.connect('ssh.example.com', username='strongbad', password='thecheat')
    
    def __del__(self):
        """ Called when the instance is about to be destroyed. 
                
        The connection has to be closed here.
        """
        if self._client:
            self._client.close()
                    
    def output(self, command, timeout=60):
        return self._client.exec_command(command, timeout=timeout)
    
connection = SshConnection()
# some interactions
connection.output('...')
```

This example shows how you could safely destroy connection using unified instance creation. You don't need to remember some specific details about each class. Just use them, everything else Python will do for you. But there are two notes. The first, this solution doesn't guarantee that the destructor will be called immediately if a context for the execution of the block of code is exited. The second one, it may not work with cyclic references. Use [weakref module](https://docs.python.org/3.4/library/weakref.html#module-weakref) if you're using **Python < 3.4**. In **Python 3.4 or above** [PEP 442 -- Safe object finalization](https://www.python.org/dev/peps/pep-0442/) is implemented, so, everything has to work fine.

Conclusion
==========
Let's summarize: 
- `try / finally` is the simplest way of safely destroying connections, very verbose and isn't automatically used.
- context manager requires a creation of an adapter object. Although it's less verbose than `try / finally`, it introduces one more type of instantiating the objects and isn't automatically used.
- object finalizer allows destroying connections safely and automatically. But implementations may depend on Python's version.

Choose the one is most relevant to you, document your contribution guide with the selected approach, and use it across all your project code.

**Further reading**
- [https://docs.python.org/3.4/reference/datamodel.html#object.__del__](https://docs.python.org/3.4/reference/datamodel.html#object.__del__)
- [https://docs.python.org/3.4/reference/datamodel.html#with-statement-context-managers](https://docs.python.org/3.4/reference/datamodel.html#with-statement-context-managers)
- [https://www.python.org/dev/peps/pep-0442](https://www.python.org/dev/peps/pep-0442/)
- [https://docs.python.org/3.4/library/weakref.html#module-weakref](https://docs.python.org/3.4/library/weakref.html#module-weakref)
