
### 什么是Selenium
Selenium 是一个用于Web应用程序测试的工具。他是一款浏览器仿真程序 可以像真正的用户在操作一样操作浏览器。

### 添加浏览器驱动 
不同的浏览器需要下载不同的驱动
Firefox浏览器驱动    https://github.com/mozilla/geckodriver/releases
 
###  java中集成Selenium
maven
```xml
        <dependency>
            <groupId>org.seleniumhq.selenium</groupId>
            <artifactId>selenium-java</artifactId>
            <version>3.141.59</version>
        </dependency>

```

Java代码
```java
public static void main(String[] args) {

        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        String currentDateStr = dateFormat.format(new Date());


        WebDriver driver = null;
        try {


            System.setProperty("webdriver.gecko.driver", "/Users/muluofeng/soft/geckodriver-v0.30.0-macos-aarch64/geckodriver");
            //初始化驱动
            //driver = new ChromeDriver(chromeOptions);
            FirefoxOptions firefoxOptions = new FirefoxOptions();
//            firefoxOptions.setHeadless(true); //设置为无头模式
            driver = new FirefoxDriver(firefoxOptions);

            driver.get("https://t.yicall.com/login");
    
            WebElement usernameEle = driver.findElement(By.id("username"));
            WebElement passwordEle = driver.findElement(By.id("password"));
            usernameEle.sendKeys("你的账号");
            passwordEle.sendKeys("你的密码");


            WebElement loginEle = driver.findElement(By.tagName("button"));

            loginEle.click();

            sleep(1);

            String xpathExpression = "//tbody/tr/td[@title='" + currentDateStr + "']";
            List<WebElement> elementList = driver.findElements(By.xpath(xpathExpression));

            if (elementList.size() == 1) {
                WebElement webElement = elementList.get(0);
                webElement.click();
                WebElement element = driver.findElement(By.cssSelector("button[type=button]"));
                element.click();
                System.out.println();



                List<WebElement> elements = driver.findElements(By.cssSelector("div.ant-spin-container div.ant-form-item-control"));
                elements.get(2).click();
                WebElement element1 = driver.findElement(By.cssSelector("div[title='杭州市拱墅区政府']"));
                sleep(1);
                element1.click();

                elements.get(3).click();


                WebElement projectIdEle = driver.findElement(By.id("projectId"));
                projectIdEle.sendKeys("拱墅区三级数据仓2.0");

                WebElement element2 = driver.findElement(By.cssSelector("div[title='拱墅区三级数据仓2.0']"));
                sleep(1);
                element2.click();

                elements.get(4).click();
                WebElement element3 = driver.findElement(By.cssSelector("div[title='开发']"));
                sleep(1);
                element3.click();



                WebElement contentEle = driver.findElement(By.tagName("textarea"));
                contentEle.sendKeys("1. 测试");



                WebElement submitEle = driver.findElement(By.cssSelector("button[type='button']"));
                submitEle.click();

                System.out.println("执行成功");

            }


        } catch (Exception e) {
            e.printStackTrace();
        } finally {

            //使用完毕，关闭webDriver
            if (driver != null) {

                driver.quit();
            }
        }
    }


    /**
     * 线程睡眠等待页面响应，睡眠时间根据实际响应速度睡
     *
     * @param i
     */
    private static void sleep(int i) {
        try {
            Thread.sleep(i * 1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
```