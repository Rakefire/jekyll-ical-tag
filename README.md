[![Actions Status](https://github.com/Rakefire/jekyll-ical-tag/workflows/CI/badge.svg)](https://github.com/Rakefire/jekyll-ical-tag/actions)

# Jekyll ical tag

Author: Ricky Chilcott https://www.rakefire.io

Description: Pull ICS feed and provide a for-like loop of calendar events

## Installation

To your Gemfile:

`gem 'jekyll-ical-tag'`

To your `_config.yml`

```yml
plugins:
  - jekyll-ical-tag
```

## Syntax

```html
  {% ical url: https://space.floern.com/launch.ics reverse: true only_future: true %}
    {{ event.summary }}
    {{ event.description }}
    {{ event.simple_html_description }}
    {{ event.start_time }}
    {{ event.end_time }}
    {{ event.url }}
    {{ event.attendees }}
  {% endical %}
```

## Options

- `reverse` - Defaults to 'false', ordering events by start_time (or reverse start_time).
- `only_past` - Defaults to 'false', limits returned events to start_times before now.
- `only_future` - Defaults to 'false', limits returned events to start_time after now.

- `before_date` - limits returned events to dates before a specific date. This gets parsed with Ruby's Time.parse (e.g. 01-01-2018)
- `after_date` - limits returned events to dates after a specific date. This gets parsed with Ruby's Time.parse (e.g. 01-01-2018).
- `limit` - limits the number of returned events to the first N events matching the specified criteria. For example, `{% ical url: https://example.com/events.ics only_future:true limit:5 %}` returns the first five future events.

- `recurring_start_date` - limits returned events to recurring occurances after a specific date. If you don't have recurring events in your feed, you can ignore it. Deafults to 'today'
- `recurring_end_date` - limits returned events to recurring occurances before a specific date. If you don't have recurring events in your feed, you can ignore it. Deafults to '1 year from today'

## Event Attributes:

All RFC 5545 properties are supported, examples:

- `dtstart` - start time of event
- `dtend` - end time of event
- `summary` - Title or name of event
- `description` - Notes/description of event
- `location` - Location of event
- `url` - url of event, if provided, if not, take the first url from the description.

A few helper properties are also supported:

- `attendees` - [Array] of attendees names/emails
- `simple_html_description` - Notes/description of event with urls auto-linked
- `start_time` - start time of event
- `end_time` - end time of event

# Special Thanks

Special thanks to the following contributors: [@marchehab98](github.com/marchehab98] [@meitar](github.com/meitar) [@whatnotery](github.com/whatnotery)