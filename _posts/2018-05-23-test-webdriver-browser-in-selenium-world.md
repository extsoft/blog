---
layout: post
title: "A test, a WebDriver and a browser in Selenium's world"
description: "We're going to discuss why using of browser-specific implementation of a `WebDriver` is a bad idea."
tags: [selenium, webdriver, architecture]
comments: true
---

There are a couple of ways to design how to work with a real browser while execution automated tests implemented with Selenium. Suppose, we need to use Mozilla Firefox browser to run a WEB test. The most probable way is to initiate an instance of a `FirefoxDriver` and play with it. Looks very easy, isn't? Is it the best way?

Selenium offers two ways of interacting with a browser:
- using a browser-specific implementation - `FirefoxDriver` for Mozilla Firefox (`ChromeDriver` for Google Chrome etc.)
- using an universal implementation - `RemoteWebDriver`

Let’s use mentioned above Java implementations. However, you can apply the info to a language you are working with as Selenium works in the same way everywhere. 

# What is a significant difference between these methods?

The `FirefoxDriver` runs appropriate WebDriver (`GeckoDriver`) server (aka process) and sends Selenium commands to it. The `GeckoDriver` server is going to execute them in an browser window. This means the tests are responsible for preparation of an infrastructure for testing each time you create an instance of `FirefoxDriver`. 

And it works excellent on a single local environment. Once the tests are moved to some another environment, it may stop to work. And there are several reasons for it:
- a `GeckoDriver` is not available in the `PATH`
- a path for `GeckoDriver` is wrong (`webdriver.firefox.driver` property)
- a version of `GeckoDriver` is not compatible with a Mozilla Firefox

The `RemoteWebDriver` just connects to already started WebDriver server and sends Selenium commands to it. This means the tests aren't responsible for an infrastructure. The infrastructure (browsers and webdrivers) has to be ready for tests. It means either WebDriver server or Selenium Hub has to be run before the tests execution. And the tests only send Selenium commands to a specific server which can be found by given URL. That's all!

The `RemoteWebDriver` supports Selenium Hub URL (`http://localhost:4444/wd/hub`) as well as started the `GeckoDriver` executable (`http://localhost:4444`). 

So, instead of `new FirefoxDriver()` use
```java
WebDriver driver = new RemoteWebDriver(
        new URL(System.getProperty("ff-url", "http://localhost:4444")), 
        DesiredCapabilities.firefox()
);
```

# Conclusion
Keep things separated. A preparation of an infrastructure for testing is a task. An execution of Selenium tests is another one. 

Do you want to automate them both? This is one more task which has to be implemented properly. Using `new FirefoxDriver()` is not a proper implementation, is it?
