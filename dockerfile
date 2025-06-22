FROM public.ecr.aws/amazonlinux/amazonlinux:2023

RUN mkdir -p /lambda/python /lambda/layer

COPY script-for-container.sh .

RUN chmod +x script-for-container.sh

RUN dnf install -y python3.12 tar gzip zip

CMD [ "./script-for-container.sh" ]