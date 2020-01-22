FROM oracle/graalvm-ce:19.3.0-java8 as graalvm
#FROM oracle/graalvm-ce:19.3.0-java11 as graalvm # For JDK 11
COPY . /home/app/fulfillment
WORKDIR /home/app/fulfillment
RUN gu install native-image
RUN native-image --no-server --static -cp build/libs/fulfillment-*-all.jar

FROM frolvlad/alpine-glibc
EXPOSE 8080
COPY --from=graalvm /home/app/fulfillment/fulfillment /app/fulfillment
ENTRYPOINT ["/app/fulfillment", "-Djava.library.path=/app"]
