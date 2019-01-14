---
layout: post
title: "Selenium: large files upload"
description: "Do you know how does Selenium upload files? Is there a way to upload a huge file without errors?"
tags: [selenium, python]
comments: true
---
Selenium has a pretty easy method of how to upload a file. You need to find a file input element and put a file path via `send keys` method. That's it! But what's about file size? Usually, it is not important, but sometimes size matters. Why?

So, let's look what's under the hood while Selenium uploads the files.

> Please note. I'll use Python for samples below, but you can apply to any programming language that is supported by Selenium.

# File upload mechanism
Sample code looks like
```python
from selenium.webdriver import Firefox

browser = Firefox()
# opening a page with upload window
browser.find_element_by_css_selector('fileinput').send_keys('path/to/my.file'))
```
What happens?
Selenium finds the desired WEB element and assigns a `text` attribute with a given value (`path/to/my.file`). That's all! Meanwhile, `Remote` WebDriver behaves differently. How?

Here is the previous code snippet, modified to support remote WebDriver:
```python
from selenium.webdriver import FirefoxOptions, Remote

browser = Remote(
    command_executor="http://localhost:4444",
    desired_capabilities=FirefoxOptions().to_capabilities()
)
# opening a page with upload window
browser.find_element_by_css_selector('fileinput').send_keys('path/to/my.file'))
```
Selenium checks if an instance of a WebDriver is a remote one. If yes, it starts transferring of a given file (`path/to/my.file`) to a server, where a Firefox instance is running, or to a Selenium Grid node. And if the transferring is successful, Selenium assigns a correct value (some temporary path) to a `text` attribute of the WEB element. So, you don’t have to care about the presence of the file on a remote host. UX matters, isn't it?

**_But what if you need to upload a file with a size of several gigabytes?_** It may happen that the file transport to remove server (node) will fail due to memory limitations, network issues, etc. For instance, here is a [<Errno 32 broken pipe> in Python's code](https://stackoverflow.com/questions/54113674/errno-32-broken-pipe-while-uploading-large-file-via-remote-webdriver)

# How to configure a large file upload with Selenium
The best option is to split this process into two stages:
1. Deliver a file to a server (node) where a browser is running
2. Let Selenium use prepared file

## Stage 1. Deliver a file
There is a bunch of ways how to do that. For instance, you can copy a file over `scp` before running a test. Or, if you run your tests using dockerized browser via `docker-compose`, you can mount a volume to a browser's container which will be responsible for files sharing.

## Stage 2. Let Selenium use prepared file
There is an object called `file detector` which can disable (or enable) transferring of a file to a server while Remote WebDriver is used. Standard Python's library provides `LocalFileDetector` and `UselessFileDetector` classes in `selenium.webdriver.remote.file_detector` module.
The first one is a default one and enables a file transfer. The second one disables file transfer. So, `UselessFileDetector` has to be configured for a WebDriver instance. There are two options.

The first option is to configure it while creating an instance of Remote WebDriver
```python
browser = Remote(
    command_executor="http://localhost:4444",
    desired_capabilities=FirefoxOptions().to_capabilities(),
    file_detector=UselessFileDetector()
)
```
**It's is a preferred way** as it configures a global state of file uploads logic. However, if you want to turn off the file transferring only for some files, you may use a context manager like
```python
with browser.file_detector_context(UselessFileDetector):
    browser.find_element_by_css_selector('fileinput').send_keys('path/to/my.file'))
```

# Conclusion
Looks like `UselessFileDetector` is not a very good name for a class...

Anyway, sometimes `useless` can be very `useful`.
