---
layout: post
title: "Python project structure for automated tests"
description: "The article describes a structure of a Python's project for your automated tests."
tags: [python, project structure]
comments: true
modified: 2018-01-01
---

Once the Python automated tests development is started, need to define a project/repository structure. Usually, each engineer does it in his/her own way. But do we have some common template?

Before we'll look for a template of the project's structure, let's look into ways we can structure the code.

Module
------
A module is a file containing Python definitions and statements. The file name is the _module name_ with the suffix `.py` appended. 

For instance,
```
.
└── login_page.py
``` 
The `login_page.py` file is a module called `login_page`. If this module is required, it can be imported with
```python
import login_page
```

Package
-------
A package is a directory which contains one or more Python's modules and `__init__.py` file. If there is a hierarchy of directories and each of them has to be a package, the `__init__.py` has to be added to each directory.
 
For instance,

```
.
└── pages
    ├── __init__.py
    ├── login.py
    ├── profile.py
    └── settings.py
    
```

The `pages` directory is a Python package. And it's possible to import modules under `pages` package. For instance, if `login` module is required, it can be imported with
```python
from pages import login
```

Structuring the project
-----------------------
The following project structure is a minimal common template for any test automation project:
```
.
├── README.md               <- contains all information need to konw to work with this code
├── my_app_tests            <- is a main package for your code including automated tests
├── requirements.txt        <- contains all required dependencies (packages) of yuor project
└── tests                   <- is a main package for unit tests (not for automated tests)
```

**What are benefits of this structure?**

First of all, this is a common template used by Python community. This means that a lot of people of Python’s world could understand your code quickly. As a result, any knowledge transfer will go faster and you will save a lot of time and efforts.

Additionally, this will simplify integration with the Python’s tooling. Any new integration of [static code analysis](http://extsoft.pro/static-code-analysis-in-python/) or whatever you need will take significantly less time.

Next one, this structure allows easily create a Python package and distribute with PYPI etc. Here only needs to create a configuration for `setuptools`. This can be useful if some common logic has to be shared between several projects.


Conclusion
----------
Please take in mind that the proposed structure is the minimal one. And you could extend this if needed. Anyway, don't try to reinvent the wheel. 

**Further reading**
- [https://docs.python.org/3/tutorial/modules.html](https://docs.python.org/3/tutorial/modules.html)
- [http://docs.python-guide.org/en/latest/writing/structure](http://docs.python-guide.org/en/latest/writing/structure/)
