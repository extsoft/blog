---
layout: post
title: "Demo mode for Selenium tests"
description: "EventFiringWebDriver and WebDriverEventListener in action. What???"
tags: [selenium, java]
comments: true
---

It's often a demo is required once you created a couple of Selenium tests. And when you run the tests you face a
problem: the tests are executing too fast to see something on the pages. How will you solve this?

`WebDriverEventListener`
=======================
The [`WebDriverEventListener`](https://seleniumhq.github.io/selenium/docs/api/java/org/openqa/selenium/support/events/WebDriverEventListener.html)
allows adding custom logic before or after `WebDriver` actions.

So, let's add some waits after
- an opening of a page
- a clicking on an element
- a changing of element's values

```java
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.events.WebDriverEventListener;

public final class DemoMode implements WebDriverEventListener {
    @Override
    public void beforeNavigateTo(String url, WebDriver driver) {
    }

    @Override
    public void afterNavigateTo(String url, WebDriver driver) {
        sleep(2);
    }

    @Override
    public void beforeNavigateBack(WebDriver driver) {
    }

    @Override
    public void afterNavigateBack(WebDriver driver) {
        sleep(2);
    }

    @Override
    public void beforeNavigateForward(WebDriver driver) {
    }

    @Override
    public void afterNavigateForward(WebDriver driver) {
        sleep(2);
    }

    @Override
    public void beforeNavigateRefresh(WebDriver driver) {
    }

    @Override
    public void afterNavigateRefresh(WebDriver driver) {
        sleep(2);
    }

    @Override
    public void beforeFindBy(By by, WebElement element, WebDriver driver) {
    }

    @Override
    public void afterFindBy(By by, WebElement element, WebDriver driver) {
    }

    @Override
    public void beforeClickOn(WebElement element, WebDriver driver) {
    }

    @Override
    public void afterClickOn(WebElement element, WebDriver driver) {
        sleep(1);
    }

    @Override
    public void beforeChangeValueOf(WebElement element, WebDriver driver, CharSequence[] keysToSend) {
    }

    @Override
    public void afterChangeValueOf(WebElement element, WebDriver driver, CharSequence[] keysToSend) {
        sleep(1);
    }

    @Override
    public void beforeScript(String script, WebDriver driver) {
    }

    @Override
    public void afterScript(String script, WebDriver driver) {
        sleep(1);
    }

    @Override
    public void onException(Throwable throwable, WebDriver driver) {
    }

    private void sleep(int seconds) {
        try {
            Thread.sleep(seconds * 1000);
        } catch (InterruptedException ignored) {
        }
    }
}
```

`EventFiringWebDriver`
======================
Then need to register the `DemoMode` listener with
[`EventFiringWebDriver`](https://seleniumhq.github.io/selenium/docs/api/java/org/openqa/selenium/support/events/EventFiringWebDriver.html).
Will be used an existing instance of a `WebDriver`:

```java
    private WebDriver turnOnDemoMode(WebDriver webDriver) {
        final EventFiringWebDriver eventFiringWebDriver = new EventFiringWebDriver(webDriver);
        eventFiringWebDriver.register(new DemoMode());
        return eventFiringWebDriver;
    }
```

Conclusion
==========
Next run of the tests will be slower and it will be possible to see what happens on the pages.

As you can see, the `WebDriverEventListener` and `EventFiringWebDriver` are powerful instruments. They provide a
great agility in the implementation of any logic on top of the `WebDriver`.
