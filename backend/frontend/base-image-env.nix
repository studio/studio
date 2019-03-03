with import ../..;
runCommandNoCC "studio" { nativeBuildInputs = [ pharo wget xvfb_run ]; } ""
