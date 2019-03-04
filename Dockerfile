FROM nixos/nix:latest
RUN apk add --no-cache git bash
ADD . studio/
RUN nix-channel --update
RUN nix-env -iA cachix -f https://cachix.org/api/v1/install
RUN cachix use studio
RUN studio/run cache
EXPOSE 5901/tcp
ENTRYPOINT ["studio/run"]
CMD [""]