FROM python

LABEL maintainer = "cbach"

WORKDIR /dir/

RUN apt-get update -y && apt-get upgrade -y && apt-get install -y vim procps locales && \
	sed -i -e 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen && \
	dpkg-reconfigure --frontend=noninteractive locales && pip install -r requirements.txt

ENV LANG ru_RU.UTF-8
ENV LC_ALL ru_RU.UTF-8
ENV auto 0
ENV "CSV_DIR"="/ftps-files/csv-files"

EXPOSE 30010

COPY ./srcs/ .

CMD sh start.sh
