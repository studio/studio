FROM nixos/nix:latest
RUN apk add --no-cache git bash
ADD . studio/
RUN nix-channel --update
RUN studio/run cache
EXPOSE 5901/tcp
ENTRYPOINT ["studio/run"]
CMD [""]