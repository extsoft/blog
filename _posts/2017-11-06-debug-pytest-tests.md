---
layout: post
title: "pytest: don't comment the code to debug a test"
description: "The simple way to debug a particular 'pytest' test without commenting the code."
tags: [python, pytest, tips & tricks, pycharm]
comments: true
---

Often people comment the code to debug a test. For instance, there is a python’s module with 5 tests. And just one of them has to be used for debugging. So, usually, all other tests will be commented during the debugging or test development. How to improve this experience?

`pytest.mark` decorator
=======================
`pytest.mark` decorator allows assigning specific labels for a test. To find out more details click [here](https://docs.pytest.org/en/latest/mark.html).

How does it look like?
----------------------
```python
# test_something.py
import pytest


@pytest.mark.debug  # this test is marked with "debug" label
def test_one():
    print("Test #1")


def test_two():
    print("Test #2")


def test_three():
    print("Test #3")

```

Okay, and what's next?
----------------------
```bash
$ py.test -v -m debug
  ================================= test session starts ==================================
  platform darwin -- Python 3.6.1, pytest-3.2.5, py-1.5.2, pluggy-0.4.0 -- /Users/extsoft/.pyenv/versions/3.6.1/envs/pytest-mark/bin/python
  cachedir: .cache
  rootdir: /Users/extsoft/data/edu/pytest-mark, inifile:
  collected 3

  test_something.py::test_one PASSED

  ================================== 2 tests deselected ==================================
  ======================== 1 passed, 2 deselected in 0.01 seconds ========================
```
As you can see, the only `debug` test was executed.

Can I use the same from PyCharm?
--------------------------------
<iframe width="560" height="315" src="https://www.youtube.com/embed/jXvRkBZu-hA" frameborader="0" gesture="media" allowfullscreen></iframe>

Conclusion
==========
`@pytest.mark`s allow to save a lot of time during tests development or debugging. Are you still commenting the code?
