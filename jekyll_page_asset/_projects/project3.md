---
layout: project
title: "Ext: Rooftop"
show_title: false
hero: "image.png"
---

^^ the image up there is a hero image, referenced in the frontmatter.

This is an embedded script reader. It displays a script in [fountain format](https://fountain.io/){:target="_blank"}

`{% raw %}{% page_asset fountain script.fountain %}{% endraw %}`
{% page_asset fountain script.fountain %}

an image

`{% raw %}{% page_asset image image.png alt="wow what is that?" %}{% endraw %}`
{% page_asset image image.png alt="wow what is that?" %}
