# FROM 빌드 할 이미지가 어떤 이미지를 기반으로 하고있는지를 나타냄
FROM node:12.18-slim AS builder
MAINTAINER GIG

# ENV는 환경설정용
ENV APP_DIR /app
ENV NODE_ENV development

# RUN은 FROM에서 설정한 이미지 위에서 명령을 실행하는 것, 쉽게 말해 shell sciprt와 같다고 보면 됨

RUN apt-get -y update && apt-get -y dist-upgrade
RUN apt-get -y install --no-install-recommends locales locales-all \
    gcc libc6-dev && \
    npm install -g @vue/cli
# apt-get은 pip명령어를 사용하기 위해 install 시키고 업데이트 시키는 것임
ENV LANG ko_KR.UTF-8
ENV LC_ALL ko_KR.UTF-8
ENV LANGUAGE ko_KR.UTF-8

WORKDIR ${APP_DIR}
COPY ./app ${APP_DIR}

RUN npm install && \
    NODE_ENV=production npm run build


# ===============================================================
# Q. FROM이 여러개가 들어오면 한번에 다양한 서비스를 실행시키기 위해 이렇게 하는 것인가? 이 후 FROM으로 가져올 각각의 서비스에 대한 설정을 모두 해주는 것인가?


# 리눅스의 종류중 debian을 선택한 것 둘 다 인터넷에서 .deb 파일을 다운로드하여 직접 설치가능하며 APT를 이용하여 패키지를 관리한다.
# 데비안은 Ubutu에 비해 조금 더 보수적이지만 안정성이 확보된 파일만 사용한다는 점에서는 장점이 있다. 
# 다만 우분투는 데비안과 우분투 용으로 만들어진 .deb파일 둘다 호환이 되는 반면 데비안은 데비안 버전만 허용하고 있다.
# 데비안은 안정성을 중시하기 때문에 검증과정이 굉장히 길며 모든 검증이 끝난 장기버전만을 내놓고 있다. 이런 안정성 때문에 우주정거장에서도 Window XP를 데비안으로 교체한 상태이다.
FROM debian:buster-slim
MAINTAINER GIG

ENV APP_DIR /app

# 관련된 라이브러리들 설치
RUN apt-get -y update && apt-get -y dist-upgrade
RUN apt-get -y install --no-install-recommends locales locales-all \
    gcc libc6-dev supervisor nginx

# 언어체계 맞춰주기
ENV LANG ko_KR.UTF-8
ENV LC_ALL ko_KR.UTF-8
ENV LANGUAGE ko_KR.UTF-8

# WORKDIR : RUN, CMD, ENTRYPOINT의 명령이 실행될 디렉터리를 설정
# Q. 여기가 Root Directory가 되나??
WORKDIR ${APP_DIR}

# 설정된 workdir에서 아래 내용 실행
RUN apt-get purge -y --auto-remove gcc libc6-dev && \
    ldconfig && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* ~/*

COPY --from=builder /app/dist /app

# 서버는 nginx를 이용해 실행
COPY ./.config/nginx.conf /etc/nginx/nginx.conf
COPY ./.config/nginx_app.conf /etc/nginx/sites-available/nginx_app.conf
RUN rm -f /etc/nginx/sites-enabled/* && \
    ln -sf /etc/nginx/sites-available/nginx_app.conf /etc/nginx/sites-enabled/

EXPOSE 80

CMD ["nginx"]
