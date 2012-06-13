class LinkFinder
  visible: (links) ->
    return (link for link in links when $(link).offset()['top'] > window.scrollY and $(link).offset()['top'] + $(link).height() < window.scrollY + $(window).height())
  
  match: (search_string) ->
    needles = search_string.split("")
    regex_pattern = (".*" + needle for needle in needles).concat(".*").join("")
    regex = new RegExp(regex_pattern, "i")
    return (link for link in $("a") when regex.test(link.text))

class Application
  constructor: ->
    this.activated = false
    this.search_string = ""
    this.link_finder = new LinkFinder()
    
  unhighlight_links: (links) ->
    $(link).removeClass("deadmouse-highlighted") for link in links
    
  highlight_links: (links) ->
    $(link).addClass("deadmouse-highlighted") for link in links
    
  unfocus_links: (links) ->
    $(link).removeClass("deadmouse-focused") for link in links
    
  focus_first_visible_link: (links) ->
    visible_links = this.link_finder.visible links
    $(visible_links[0]).addClass("deadmouse-focused")
   
  follow_link: (link) ->
    $(link).addClass("deadmouse-clicked")
    $(link).trigger("click")

  keypress: (event) ->
    if document.activeElement == document.body # no input is focused
      this.activated = true
      this.search_string += String.fromCharCode(event.keyCode)
      matches = this.link_finder.match(this.search_string)
      this.unhighlight_links($("a"))
      this.highlight_links(matches)
      this.unfocus_links(matches)
      this.focus_first_visible_link(matches)
      if matches.length == 1
        this.follow_link(matches[0])
      return false
    else
      return true
  
  keydown: (event) ->
    if event.keyCode == 27 # Esc pressed
      this.activated = false
      this.search_string = ""
      this.unhighlight_links $("a")
      this.unfocus_links($("a"))
      return false
    else if this.activated and event.keyCode == 9 # Tab pressed
      if event.shiftKey
        console.log "shift+tab"
      else
        console.log "tab"
      return false

app = new Application()

$(window).on "keypress", (e) ->
  return app.keypress(event)

$(window).on "keydown", (e) ->
  return app.keydown(event)
