---
layout: post
title: "Minimal configuration of static code analysis for a Python project"
description: An overview of Python's tools for static code analysis
tags: [python, static code analysis]
comments: true
---

As is known, people make mistakes. And always, less or more often... And programming is not an exception. Then,
the logical question is how can I protect my code from myself?


The simplest way is a static code analysis. Why? Because of this only requires integration of a tool with
a project. Nothing more.

So, what the Python's world is offering us?


**_pylint_**
============
"[Pylint](https://www.pylint.org/) is a tool that checks for errors in Python code, tries to enforce a coding standard
and looks for code smells. It can also look for certain type errors, it can recommend suggestions about how particular
blocks can be refactored and can offer you details about the code’s complexity." -
[https://pylint.readthedocs.io/en/latest/intro.html]()

The default coding style used by pylint is close to [PEP 008](https://www.python.org/dev/peps/pep-0008/).

Installation
------------
```bash
pip install pylint
```

Configuration
-------------
Add your `.pylintrc` configuration file to customize which errors or conventions are important to you. To do that,
you could simply run
```bash
pylint --generate-rcfile > .pylintrc
```

Visit a [demo project](https://github.com/tatools/demo-python/blob/master/.pylintrc) to get an example.

Usage
-----
Simply run a command by using `pylint path_to_module_or_package` template and you will see:
- all violations you have
- general score for your project like `Your code has been rated at 3.96/10`

The closer to `10` score is, the better code you have.

For instance, the following command runs checking of the project's files excluding `tests` and `vevn` folders:

```bash
pylint $(find . -iname "*.py" -not -path "./tests/*" -not -path "./venv/*")
```


**_flake8_**
============
"[flake8](https://gitlab.com/pycqa/flake8/) is a command-line utility for enforcing style consistency across Python
projects. By default it includes lint checks provided by the PyFlakes project, PEP-0008 inspired style checks provided
by the PyCodeStyle project, and McCabe complexity checking provided by the McCabe project." -
[http://flake8.pycqa.org/en/latest/manpage.html]()


Installation
------------
```bash
pip install flake8
```

**Notice!** _It is very important to install Flake8 on the correct version of Python for your needs. If you want
Flake8 to properly parse new language features in Python 3.5 (for example), you need it to be installed on 3.5
for Flake8 to understand those features. In many ways, Flake8 is tied to the version of Python on which it runs._

Configuration
-------------
Add your `.flake8` configuration file to customize which
[errors](http://flake8.pycqa.org/en/latest/user/error-codes.html) are important to you. To find out more visit
[http://flake8.pycqa.org/en/latest/user/configuration.html]().

Visit a [demo project](https://github.com/tatools/demo-python/blob/master/.flake8) to get an example.

Usage
-----
Simply run a command by using `flake8 --statistic path_to_module_or_package` and the output will be like
```bash
my_pacakge/module1.py:23:25: E126 continuation line over-indented for hanging indent
......
my_pacakge/module12.py:45:26: E126 continuation line over-indented for hanging indent
2     E126 continuation line over-indented for hanging indent
2     E128 continuation line under-indented for visual indent
2     E251 unexpected spaces around keyword / parameter equals
4     E265 block comment should start with '# '
1     F821 undefined name '__class__'
```


**_pydocstyle_**
================
"pydocstyle is a static analysis tool for checking compliance with Python docstring conventions." -
[http://www.pydocstyle.org/en/latest/](). It supports most of [PEP 257](https://www.python.org/dev/peps/pep-0257/)
out of the box.

Installation
------------
```bash
pip install pydocstyle
```

Configuration
-------------
Add your `.pydocstyle` configuration file to customize which
[options](http://www.pydocstyle.org/en/latest/usage.html#available-options) are important to you.

Visit a [demo project](https://github.com/tatools/demo-python/blob/master/.pydocstyle) to get an example.

Usage
-----
Simply run a command like `pydocstyle demo_python_at` and the output will be like
```bash
my_pacakge/module1.py:23 in public method `start`:
        D401: First line should be in imperative mood ('Start', not 'Starts')
my_pacakge/module12.py:33 in public method `stop`:
        D401: First line should be in imperative mood ('Stop', not 'Stops')
```

Conclusion
==========
These tools will significantly reduce a count of the errors in Python’s code. If you would
like to get more insight, just experiment or ask a question in the comments.
