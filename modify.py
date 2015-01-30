#!/usr/bin/env python

import random

countries = ['USA', 'USA', 'USA', 'India', 'India', 'China', 'China', 'Russia']
browsers = ['Chromium', 'Chromium', 'Chromium', 'Firefox', 'Firefox', 'Firefox', 'Opera', 'Opera', 'IE']

output = open('output.log', 'w')
for line in open('input.log'):
    tokens = line.split(' ')
    tokens[1] = random.choice(countries)
    tokens[2] = random.choice(browsers)
    output.write(' '.join(tokens))
