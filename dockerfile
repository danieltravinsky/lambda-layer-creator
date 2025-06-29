FROM public.ecr.aws/amazonlinux/amazonlinux:2023

RUN mkdir -p /lambda/python /lambda/layer

COPY script-for-container.sh .
COPY requirements.txt .

RUN chmod +x script-for-container.sh

# Windows line breaks may cause problems.. (CRLF vs LF)
RUN sed -i 's/\r$//' script-for-container.sh
RUN sed -i 's/\r$//' requirements.txt

RUN dnf install -y python3.12 tar gzip zip

CMD [ "./script-for-container.sh" ]