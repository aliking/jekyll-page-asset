---
layout: project
title: Some Videos
show_title: true
---

Background video, which autoplays muted by default.

`{% raw %}{% page_asset video hero_vid.mp4 display=background %}{% endraw %}`
{% page_asset video hero_vid.mp4 display=background %}

This is a regular embedded video.

`{% raw %}{% page_asset video hero_vid.mp4 %}{% endraw %}`
{% page_asset video hero_vid.mp4 %}


This is a 'scroll_scrub_video' which advances the video as you scoll the page

`{% raw %}{% page_asset scroll_scrub_video hero_vid.mp4 %}{% endraw %}`
{% page_asset scroll_scrub_video hero_vid.mp4 %}
