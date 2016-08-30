FROM gcr.io/google_appengine/openjdk8
RUN apt-get update
RUN mkdir /apps 
WORKDIR /apps
RUN wget https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/9.3.9.v20160517/jetty-distribution-9.3.9.v20160517.tar.gz -P /apps/
RUN tar xzf jetty-distribution-9.3.9.v20160517.tar.gz
ADD 10-java8-flex-1.0-SNAPSHOT.war  jetty-distribution-9.3.9.v20160517/webapps/root.war
EXPOSE 8080
ENTRYPOINT [ "/apps/jetty-distribution-9.3.9.v20160517/bin/jetty.sh", "run" ]
