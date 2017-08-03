# from https://gist.github.com/noahcoad/51934724e0896184a2340217b383af73
import yaml, json, sys
sys.stdout.write(json.dumps(yaml.load(sys.stdin), sort_keys=True, indent=2))
