{ pkgs ? import ../../../nix/pkgs.nix {}
, what } @args:
with pkgs;

{
  raptorjit-auditlog = modules/raptorjit-auditlog.nix args;
  hexdump = import modules/hexdump.nix args;
  pdl     = import modules/pcap2xml.nix args;
  vmprofile = import modules/vmprofile.nix args;
}
