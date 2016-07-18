FROM gcr.io/google_appengine/openjdk8
RUN apt-get update
RUN mkdir /apps 
WORKDIR /apps
RUN wget http://download.eclipse.org/jetty/stable-9/dist/jetty-distribution-9.3.9.v20160517.tar.gz -P /apps/
RUN tar xzf jetty-distribution-9.3.9.v20160517.tar.gz
ADD root-1.0-SNAPSHOT.war  jetty-distribution-9.3.9.v20160517/webapps/root.war
EXPOSE 8080
ENTRYPOINT [ "/apps/jetty-distribution-9.3.9.v20160517/bin/jetty.sh", "run" ]
