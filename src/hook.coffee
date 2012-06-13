class Matcher
  match: (search_string) ->
    needles = search_string.split("")
    regex_pattern = (".*" + needle for needle in needles).concat(".*").join("")
    regex = new RegExp(regex_pattern, "i")
    return (link for link in $("a") when regex.test(link.text))

class Application
  constructor: ->
    this.search_string = ""
    this.matcher = new Matcher()
    
  unhighlight_links: (links) ->
    $(link).removeClass("deadmouse-highlighted") for link in links
    
  highlight_links: (links) ->
    $(link).addClass("deadmouse-highlighted") for link in links
   
  follow_link: (link) ->
    $(link).addClass("deadmouse-clicked")
    $(link).trigger("click")

  keypress: (event) ->
    if document.activeElement == document.body # no input is focused
      this.search_string += String.fromCharCode(event.keyCode)
      matches = this.matcher.match(this.search_string)
      this.unhighlight_links($("a"))
      this.highlight_links(matches)
      if matches.length == 1
        this.follow_link(matches[0])
      return false
    else
      return true
  
  keydown: (event) ->
    if event.keyCode == 27 # Esc pressed
      this.search_string = ""
      this.unhighlight_links $("a")
      return false

app = new Application()

$(window).on "keypress", (e) ->
  return app.keypress(event)

$(window).on "keydown", (e) ->
  return app.keydown(event)
