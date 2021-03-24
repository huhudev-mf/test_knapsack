import sys, json; list([print(x['id']) for x in json.load(sys.stdin)['examples']])
