#  monitoring-with-collectd-jmxtrans-graphite-bootstrap

This repos is a bootstrap for Java Monitoring with Collectd, JMXTrans and Graphite.
Run scripts/start.sh will create and provision an Ubuntu VM and configure & run the tools on a sample project.
You will be allowed to access to the sample web application from the host at [localhost:8091/cocktail-app/](http://localhost:8091/cocktail-app/) and to the Graphite web application at [localhost:8090](http://localhost:8090)


# Prerequisites
 - Shell
 - Vagrant

## Configuration

You can studie all the configuration realized to run up Collectdm JMXTrans and Graphite in the file scripts/provisioning.sh

The configurations to monitor the sample application are specified below.

### Queries

This sample configuration collects a mix metrics

* Application specific queries
 * `classpath:jmxtrans.json` see [src/main/resources/jmxtrans.json](https://github.com/jmxtrans/embedded-jmxtrans-samples/blob/master/embedded-jmxtrans-webapp-coktail/src/main/resources/jmxtrans.json)
* Jmx Exporter internals queries
 * `classpath:org/embedded-jmxtrans/config/jmxtrans-internals.json` provided par embedded-jmxtrans jar. See [embedded-jmxtrans-internals.json](https://github.com/jmxtrans/embedded-jmxtrans/blob/master/src/main/resources/org/embedded-jmxtrans/config/jmxtrans-internals.json)
* [Bundled templates](https://github.com/jmxtrans/embedded-jmxtrans/wiki/Configuration-Templates) for Tomcat and Hotspot JVM
 * `classpath:org/embedded-jmxtrans/config/jvm-sun-hotspot.json` provided par embedded-jmxtrans jar. See [jvm-sun-hotspot.json](https://github.com/jmxtrans/embedded-jmxtrans/blob/master/src/main/resources/org/embedded-jmxtrans/config/jvm-sun-hotspot.json)
 * `classpath:org/embedded-jmxtrans/config/tomcat-6.json` provided par embedded-jmxtrans jar. See [tomcat-6.json](https://github.com/jmxtrans/embedded-jmxtrans/blob/master/src/main/resources/org/embedded-jmxtrans/config/tomcat-6.json)


Extract of `classpath:jmxtrans.json`

```json
"queries": [
  {
    "objectName": "cocktail:type=CocktailManager,name=CocktailManager",
    "resultAlias": "cocktail",
    "attributes": [
      "AddedCommentCount",
      "CreatedCocktailCount",
      "DisplayedCocktailCount",
      "SearchedCocktailCount",
      "UpdatedCocktailCount"
    ]

  }
]
```

### Output Writers

This sample application outputs the metrics to 2 writers: [Slf4jWriter](https://github.com/jmxtrans/embedded-jmxtrans/wiki/Slf4j-Writer) and [GraphiteWriter](https://github.com/jmxtrans/embedded-jmxtrans/wiki/Graphite-Writer).

Extract of `classpath:jmxtrans.json`

```json
{
  "@class": "org.embedded-jmxtrans.output.Slf4jWriter"
},
{
  "@class": "org.embedded-jmxtrans.output.GraphiteWriter",
  "settings": {
    "host": "${graphite.host:localhost}",
    "port": "${graphite.port:2003}",
    "namePrefix":"${graphite.namePrefix:servers.#hostname#.}"
  }
}
```

By default, graphite writer connects to a graphite server on localhost:2003. An alternate configuration can be defined using Java system properties (ie "-D" command line parameters) who can be defined in the "catalina.properties" file of the underlying Tomcat server.

## Spring Integration

In [src/main/webapp/WEB-INF/spring-mvc-servlet.xml](https://github.com/jmxtrans/embedded-jmxtrans-samples/blob/master/embedded-jmxtrans-webapp-coktail/src/main/webapp/WEB-INF/spring-mvc-servlet.xml#L45):
```xml
<beans ...
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:jmxtrans="http://www.jmxtrans.org/schema/embedded"
       xsi:schemaLocation="...
		http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-3.1.xsd
		http://www.jmxtrans.org/schema/embedded http://www.jmxtrans.org/schema/embedded/jmxtrans-1.0.xsd">

    <context:annotation-config/>

    <jmxtrans:jmxtrans>
        <jmxtrans:configuration>classpath:jmxtrans.json</jmxtrans:configuration>
        <jmxtrans:configuration>classpath:org/jmxtrans/embedded/config/tomcat-6.json</jmxtrans:configuration>
        <jmxtrans:configuration>classpath:org/jmxtrans/embedded/config/jmxtrans-internals.json</jmxtrans:configuration>
        <jmxtrans:configuration>classpath:org/jmxtrans/embedded/config/jvm-sun-hotspot.json</jmxtrans:configuration>
    </jmxtrans:jmxtrans>
</beans>
```
**NOTE:** Don't forget to declare `<context:annotation-config/>` to handle embedded-jmxtrans' lifecycle annotation `@PreDestroy` at shutdown.

## Maven Setup

[pom.xml](https://github.com/jmxtrans/embedded-jmxtrans-samples/blob/master/embedded-jmxtrans-webapp-coktail/pom.xml#L114)


```xml
<dependency>
    <groupId>org.jmxtrans.embedded</groupId>
    <artifactId>embedded-jmxtrans</artifactId>
    <version>1.0.8</version>
</dependency>
```
