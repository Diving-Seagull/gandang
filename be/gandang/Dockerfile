# 빌드 스테이지
FROM gradle:7.6.1-jdk17 AS build
WORKDIR /home/gradle/src

# 의존성 파일 복사 및 설치
COPY build.gradle settings.gradle /home/gradle/src/
COPY gradle /home/gradle/src/gradle
RUN gradle dependencies --no-daemon

# 소스 복사 및 빌드
COPY --chown=gradle:gradle . .
RUN gradle build --no-daemon -x test

# 실행 스테이지
FROM openjdk:17-jdk-slim

# 시스템 패키지 설치
RUN apt-get update && \
   apt-get install -y --no-install-recommends \
   python3 \
   python3-pip \
   python3-dev \
   build-essential && \
   rm -rf /var/lib/apt/lists/* && \
   pip3 install --no-cache-dir --upgrade pip

WORKDIR /app

# Python 요구사항 설치
COPY requirements.txt /app/
RUN pip3 install --no-cache-dir -r requirements.txt

# Python 스크립트 및 데이터 파일 복사
COPY --from=build /home/gradle/src/src/main/resources/python/* /app/python/

# JAR 파일 복사
COPY --from=build /home/gradle/src/build/libs/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]