#!/usr/bin/env nix-shell
#! nix-shell --run bash -E 'with import ../..; runCommandNoCC "studio" { nativeBuildInputs = [ pharo wget ]; } ""'
set -e
studio="real$(dirname $(readlink -f $0))/../.."
if [ -f GToolkit.image ]; then
    echo "Reusing GToolkit.image"
else
    echo "Downloading GToolkit image.."
    wget https://dl.feenk.com/gt/GToolkitLinux64.zip
    unzip -o GToolkitLinux64.zip
    cp GToolkitLinux64/GToolkit*image GToolkit.image
    cp GToolkitLinux64/GToolkit*changes GToolkit.changes
    cp GToolkitLinux64/Pharo*sources ./
fi
if [ ! -f Studio.image ]; then
    echo "Building Studio base image.."
    [ -f Studio.image ]   && rm Studio.image
    [ -f Studio.changes ] && rm Studio.changes
    #xvfb-run pharo GToolkit.image save Studio --delete-old
    cat > init.st <<EOF
(Delay forSeconds: 10) wait.
IceRepository reset.
Smalltalk saveAs: 'Studio'.
Smalltalk exitSuccess.
EOF
    xvfb-run pharo GToolkit.image st init.st
fi
xvfb-run pharo Studio.image config tonel://$studio/frontend ConfigurationOfStudio --install=development
zip -r Studio.zip Studio.image Studio.changes Pharo*sources

echo "Built Studio base image:"
ls -l Studio.zip
