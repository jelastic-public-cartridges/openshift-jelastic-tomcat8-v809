# Jelastic Tomcat 8 Cartridge
This cartridge provides [Tomcat 8](http://tomcat.apache.org/) on Jelastic Platform.

**Apache Tomcat** is an open-source software implementation of the Java Servlet and JavaServer Pages technologies from Oracle. It provides a "pure Java" HTTP web server environment for Java code to run. 

Tomcat 8 implements the newer Java EE 7 specification for the Web profile that is Servlet 3.1, JSP 2.3, EL 3.0 and Web Socket 1.0. In addition to that, this server is built upon the improvements made in Tomcat 7 and includes a few important enhancement:
* implementation of the single, common resources in order to replace the multiple resource extension features provided in earlier versions
* embedded remote debugging support
* compatibility with Apache Portable Runtime library, which provides advanced scalability, performance, and better integration with native server technologies

For more details refer to the [Jelastic documentation](http://docs.jelastic.com/tomcat8).

Follow the [link](http://ops-docs.jelastic.com/private-add-cartridge) in order to find out how to enable the current cartridge at Jelastic dashboard.

### What Jelastic cartridge is?

Jelastic [Platform-as-Infrastructure](http://docs.jelastic.com/what-is-platform-as-infrastructure) supports **OpenShift’s cartridge model** to make it easier for independent software vendors (ISVs) offering core services in multiple platforms and for a wider array of cloud ecosystems and marketplaces. This open standard for technology packaging and deployment enables ISVs and end-users to integrate their own middleware, databases, and services into the platform and make them available to PaaS developers building applications.

A **cartridge** is an advanced packaging format. In our case, it is represented with existing OpenShift cartridge specifications, extended with Jelastic configurations, to provide more complex functionality and the ability to make adjustments in Jelastic. This additional tuning is required based on the difference between the architectures of the two platforms (Jelastic and OpenShift).

Such configuration is quite easy - you just need to fork a basic cartridge and add custom settings. Detailed instruction on how to create your own cartridge can be seen [here](http://ops-docs.jelastic.com/create-cartridge).


### How to add a cartridge to Jelastic Cloud?

Ready cartridge (your own or one of those we’ve already prepared for you) can be added to the Jelastic PaI via JCA. After that it should be tested and published in order to become available through the dashboard. Find out the details in [this](http://ops-docs.jelastic.com/private-add-cartridge) instruction.
