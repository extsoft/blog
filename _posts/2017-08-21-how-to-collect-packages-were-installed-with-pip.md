---
layout: post
title: "How to collect packages were installed with pip?"
description: "The article describes best ways to generate pip requirements file."
tags: [python, pip, dependency management]
comments: true
---

Once I start a Python's project, I'm starting to add interesting packages with `pip install ...`. And, usually, it's 
enough until I decided to share the project with someone. And there is a question: **How can I collect packages 
were installed and share them?**

Usually, this task is solved using file called `requirements.txt`. The file contains a list of required Python's 
packages. All the packages can be easily installed:
```bash
pip install -r requirements.txt
```
How to create `requirements.txt`?

pip
---
Just run:
```bash
pip freeze > requirements.txt
```
The solution will generate a `requirements.txt` file which contains all packages installed with the `pip`. 
```bash
$ cat requirements.txt
pytest==3.1.2
selenium==3.4.3
```
It works! 

But... **transitive dependencies** of the libraries! For instance, let's install _Appium client_:
```bash
$ pip install Appium-Python-Client==0.24
Collecting Appium-Python-Client==0.24
  Using cached Appium-Python-Client-0.24.tar.gz
Collecting selenium>=2.47.0 (from Appium-Python-Client==0.24)
  Using cached selenium-3.5.0-py2.py3-none-any.whl
Installing collected packages: selenium, Appium-Python-Client
  Running setup.py install for Appium-Python-Client
Successfully installed Appium-Python-Client-0.24 selenium-3.5.0
```

As you can see, `Appium-Python-Client` depends on `selenium` which is the transitive dependency for the 
`Appium-Python-Client`. And `pip freeze` will display both of them:
```bash
$ pip freeze
Appium-Python-Client==0.24
selenium==3.5.0
```

I don't want to manage transitive dependencies, I would delegate it to the `pip`. So, how to skip them?

pipdeptree
----------
The [pipdeptree](https://github.com/naiquevin/pipdeptree) allows to build a packages tree and identify transitive 
dependencies. 

First of all, install:
```bash
pip install pipdeptre
```
Next, display your dependency tree:
```bash
$ pipdeptree --freeze
Appium-Python-Client==0.24
  selenium==3.5.0
pipdeptree==0.10.1
  pip==7.1.2
```

As you can see, there are two top level dependencies: `Appium-Python-Client` and `pipdeptree`. So, you can choose only
required top level dependencies (I would use only `Appium-Python-Client==0.24` for the project's requirements). 

But what if there are dozens of the packages and some of them are redundant dependencies (for instance, were used 
for investigation and aren't required anymore)?

pipreqs
-------
The [pipreqs](https://github.com/bndr/pipreqs) allows to generate pip requirements based on project's imports.

First of all, install:
```bash
pip install pipreqs
```
Next, display the packages were used in the import statements:
```bash
$ pipreqs --print .
selenium==3.5.0
Appium_Python_Client==0.24
```

Great! I use just 2 two dependencies. Stop! But one of them is a [transitive](#pipdeptree)... 

Conclusion
----------
As you may see, it is a small probability to generate the clean `requirements.txt` file using only one approach. But 
a combination of the [pip](#pip) and [pipdeptree](#pipdeptree) and [pipreqs](#pipreqs) can do that. 