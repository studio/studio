FROM nixos/nix:latest
RUN apk add --no-cache git bash
RUN nix-channel --update
RUN nix-env -iA cachix -f https://cachix.org/api/v1/install
RUN cachix use studio
ADD nix nix/
RUN nix-shell -j 10 --show-trace --run "/bin/sh -c true" nix/precache.nix
ADD . studio/
RUN studio/run cache
EXPOSE 5901/tcp
ENTRYPOINT ["studio/run"]
CMD [""]