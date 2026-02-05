# @markers: pom.xml
dap_bin := ""
dap_args := "--mode cpu"

build:
    mvn package

run:
    mvn exec:java

test:
    mvn test

clean:
    mvn clean
